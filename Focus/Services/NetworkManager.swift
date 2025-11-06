//
//  NetworkManager.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import Foundation
import Alamofire
import SwiftyJSON

// MARK: - 网络错误类型
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "没有数据"
        case .decodingError:
            return "数据解析失败"
        case .serverError(let code):
            return "服务器错误: \(code)"
        case .networkError(let message):
            return "网络错误: \(message)"
        }
    }
}

// MARK: - HTTP方法
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - 网络管理器
class NetworkManager {
    static let shared = NetworkManager()

    private let session: Session

    private init() {
        // 配置Session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = Session(configuration: configuration)
    }

    // MARK: - 通用请求方法
    func request<T: Codable>(
        url: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {

        guard let url = URL(string: url) else {
            printLog("❌ 请求失败: URL无效 - \(url)")
            throw NetworkError.invalidURL
        }

        // 转换HTTP方法
        let alamofireMethod: Alamofire.HTTPMethod
        switch method {
        case .GET:
            alamofireMethod = .get
        case .POST:
            alamofireMethod = .post
        case .PUT:
            alamofireMethod = .put
        case .DELETE:
            alamofireMethod = .delete
        case .PATCH:
            alamofireMethod = .patch
        }

        // 构建headers
        var httpHeaders: HTTPHeaders = []
        if let headers = headers {
            for (key, value) in headers {
                httpHeaders.add(name: key, value: value)
            }
        }

        // 添加Cookie到headers
        if let cookies = cookies, !cookies.isEmpty {
            let cookieString = cookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
            httpHeaders.add(name: "Cookie", value: cookieString)
        }

        // 打印请求日志
        printRequestLog(url: url.absoluteString, method: method.rawValue, parameters: parameters, headers: headers, cookies: cookies)

        return try await withCheckedThrowingContinuation { continuation in
            _ = session.request(
                url,
                method: alamofireMethod,
                parameters: parameters,
                encoding: method == .GET ? URLEncoding.default : JSONEncoding.default,
                headers: httpHeaders
            )
            .response { response in
                // 打印响应日志
                self.printResponseLog(response: response)

                // 检查HTTP状态码
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        // HTTP 200 表示成功，尝试解析响应数据
                        guard let data = response.data else {
                            continuation.resume(throwing: NetworkError.noData)
                            return
                        }

                        // 增强的SwiftyJSON解析处理
                        do {
                            // 先打印原始响应内容用于调试
                            if let responseString = String(data: data, encoding: .utf8) {
                                print("🔍 原始响应内容: \(responseString)")
                            }

                            // 检查Content-Type
                            let contentType = response.response?.allHeaderFields["Content-Type"] as? String ?? ""
                            print("📋 Content-Type: \(contentType)")

                            // 尝试多种解析策略
                            let result = try self.parseResponseData(data: data, targetType: T.self, contentType: contentType)
                            continuation.resume(returning: result)

                        } catch {
                            print("❌ 所有解析方法都失败: \(error)")
                            continuation.resume(throwing: NetworkError.decodingError)
                        }

                    } else {
                        // 非200状态码，抛出服务器错误
                        continuation.resume(throwing: NetworkError.serverError(statusCode))
                    }
                } else {
                    // 没有状态码，网络错误
                    if let error = response.error {
                        continuation.resume(throwing: NetworkError.networkError(error.localizedDescription))
                    } else {
                        continuation.resume(throwing: NetworkError.networkError("未知网络错误"))
                    }
                }
            }
        }
    }

    // MARK: - GET请求
    func get<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            url: url,
            method: .GET,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: responseType
        )
    }

    // MARK: - POST请求
    func post<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            url: url,
            method: .POST,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: responseType
        )
    }

    // MARK: - PUT请求
    func put<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            url: url,
            method: .PUT,
            parameters: parameters,
            headers: headers,
            responseType: responseType
        )
    }

    // MARK: - DELETE请求
    func delete<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            url: url,
            method: .DELETE,
            parameters: parameters,
            headers: headers,
            responseType: responseType
        )
    }

    // MARK: - SwiftyJSON专用请求方法

    /// 使用SwiftyJSON解析的通用请求方法
    func requestWithJSON(
        url: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil
    ) async throws -> JSON {

        guard let url = URL(string: url) else {
            printLog("❌ 请求失败: URL无效 - \(url)")
            throw NetworkError.invalidURL
        }

        // 转换HTTP方法
        let alamofireMethod: Alamofire.HTTPMethod
        switch method {
        case .GET:
            alamofireMethod = .get
        case .POST:
            alamofireMethod = .post
        case .PUT:
            alamofireMethod = .put
        case .DELETE:
            alamofireMethod = .delete
        case .PATCH:
            alamofireMethod = .patch
        }

        // 构建headers
        var httpHeaders: HTTPHeaders = []
        if let headers = headers {
            for (key, value) in headers {
                httpHeaders.add(name: key, value: value)
            }
        }

        // 添加Cookie到headers
        if let cookies = cookies, !cookies.isEmpty {
            let cookieString = cookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
            httpHeaders.add(name: "Cookie", value: cookieString)
        }

        // 打印请求日志
        printRequestLog(url: url.absoluteString, method: method.rawValue, parameters: parameters, headers: headers, cookies: cookies)

        return try await withCheckedThrowingContinuation { continuation in
            _ = session.request(
                url,
                method: alamofireMethod,
                parameters: parameters,
                encoding: method == .GET ? URLEncoding.default : JSONEncoding.default,
                headers: httpHeaders
            )
            .response { response in
                // 打印响应日志
                self.printResponseLog(response: response)

                // 检查HTTP状态码
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        // HTTP 200 表示成功，使用SwiftyJSON解析响应数据
                        guard let data = response.data else {
                            continuation.resume(throwing: NetworkError.noData)
                            return
                        }

                        do {
                            let json = try JSON(data: data)
                            print("✅ SwiftyJSON解析成功")
                            continuation.resume(returning: json)
                        } catch {
                            print("❌ SwiftyJSON解析失败: \(error)")
                            continuation.resume(throwing: NetworkError.decodingError)
                        }

                    } else {
                        // 非200状态码，抛出服务器错误
                        continuation.resume(throwing: NetworkError.serverError(statusCode))
                    }
                } else {
                    // 没有状态码，网络错误
                    if let error = response.error {
                        continuation.resume(throwing: NetworkError.networkError(error.localizedDescription))
                    } else {
                        continuation.resume(throwing: NetworkError.networkError("未知网络错误"))
                    }
                }
            }
        }
    }

    /// SwiftyJSON GET请求
    func getJSON(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil
    ) async throws -> JSON {
        return try await requestWithJSON(
            url: url,
            method: .GET,
            parameters: parameters,
            headers: headers,
            cookies: cookies
        )
    }

    /// SwiftyJSON POST请求
    func postJSON(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil
    ) async throws -> JSON {
        return try await requestWithJSON(
            url: url,
            method: .POST,
            parameters: parameters,
            headers: headers,
            cookies: cookies
        )
    }

    // MARK: - 增强的数据解析方法
    private func parseResponseData<T: Codable>(data: Data, targetType: T.Type, contentType: String) throws -> T {
        print("🔧 开始增强解析，目标类型: \(targetType)")

        // 策略1: 直接使用SwiftyJSON解析
        do {
            let json = try JSON(data: data)
            print("✅ SwiftyJSON解析成功")

            // 如果目标类型是String，返回JSON字符串
            if T.self == String.self {
                if let jsonString = json.rawString() {
                    print("📄 返回JSON字符串")
                    return jsonString as! T
                }
            }

            // 尝试直接从原始数据解码
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                print("✅ 直接解码成功")
                return decodedData
            } catch {
                print("⚠️ 直接解码失败: \(error)")
                if let decodingError = error as? DecodingError {
                    printDetailedDecodingError(decodingError)
                }
            }

            // 尝试从SwiftyJSON重新生成数据后解码
            if let jsonData = try? json.rawData() {
                let decoder = JSONDecoder()
                if let decodedData = try? decoder.decode(T.self, from: jsonData) {
                    print("✅ SwiftyJSON重新生成数据解码成功")
                    return decodedData
                }
            }

            // 检查是否是嵌套的JSON字符串
            if let responseString = json.string {
                print("🔍 检测到字符串响应: \(responseString)")
                return try parseNestedJSONString(responseString, targetType: targetType)
            }

            // 检查是否是数组中的单个JSON字符串
            if let arrayValue = json.array, arrayValue.count == 1 {
                if let firstElement = arrayValue.first?.string {
                    print("🔍 检测到数组中的JSON字符串")
                    return try parseNestedJSONString(firstElement, targetType: targetType)
                }
            }

        } catch {
            print("⚠️ SwiftyJSON解析失败: \(error)")
        }

        // 策略2: 处理不同的Content-Type
        if contentType.contains("text/") {
            return try parseTextResponse(data: data, targetType: targetType)
        }

        // 策略3: 尝试修复常见的JSON格式问题
        return try parseWithJSONFix(data: data, targetType: targetType)
    }

    private func parseNestedJSONString<T: Codable>(_ jsonString: String, targetType: T.Type) throws -> T {
        print("🔧 解析嵌套JSON字符串")

        // 如果目标就是String类型，直接返回
        if T.self == String.self {
            return jsonString as! T
        }

        // 尝试解析嵌套的JSON
        if jsonString.hasPrefix("{") || jsonString.hasPrefix("[") {
            if let nestedData = jsonString.data(using: .utf8) {
                let decoder = JSONDecoder()
                if let decodedData = try? decoder.decode(T.self, from: nestedData) {
                    print("✅ 嵌套JSON解析成功")
                    return decodedData
                }

                // 尝试使用SwiftyJSON解析嵌套内容
                do {
                    let nestedJson = try JSON(data: nestedData)
                    if let reEncodedData = try? nestedJson.rawData(),
                       let decodedData = try? decoder.decode(T.self, from: reEncodedData) {
                        print("✅ SwiftyJSON嵌套解析成功")
                        return decodedData
                    }
                } catch {
                    print("⚠️ SwiftyJSON嵌套解析失败: \(error)")
                }
            }
        }

        throw NetworkError.decodingError
    }

    private func parseTextResponse<T: Codable>(data: Data, targetType: T.Type) throws -> T {
        print("🔧 解析文本响应")

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingError
        }

        // 如果目标是String类型，直接返回
        if T.self == String.self {
            return responseString as! T
        }

        // 尝试将文本作为JSON解析
        let cleanedString = responseString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")

        if let cleanedData = cleanedString.data(using: .utf8) {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(T.self, from: cleanedData) {
                print("✅ 清理后的文本解析成功")
                return decodedData
            }
        }

        throw NetworkError.decodingError
    }

    private func parseWithJSONFix<T: Codable>(data: Data, targetType: T.Type) throws -> T {
        print("🔧 尝试修复JSON格式问题")

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingError
        }

        // 常见的JSON修复策略
        var fixedString = responseString

        // 移除BOM标记
        if fixedString.hasPrefix("\u{FEFF}") {
            fixedString = String(fixedString.dropFirst())
        }

        // 移除前后的引号（如果整个响应被包装在引号中）
        if fixedString.hasPrefix("\"") && fixedString.hasSuffix("\"") {
            fixedString = String(fixedString.dropFirst().dropLast())
            // 反转义引号
            fixedString = fixedString.replacingOccurrences(of: "\\\"", with: "\"")
        }

        // 尝试解析修复后的JSON
        if let fixedData = fixedString.data(using: .utf8) {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(T.self, from: fixedData) {
                print("✅ JSON修复后解析成功")
                return decodedData
            }

            // 使用SwiftyJSON再次尝试
            do {
                let json = try JSON(data: fixedData)
                if let reEncodedData = try? json.rawData(),
                   let decodedData = try? decoder.decode(T.self, from: reEncodedData) {
                    print("✅ SwiftyJSON修复后解析成功")
                    return decodedData
                }
            } catch {
                print("⚠️ SwiftyJSON修复解析失败: \(error)")
            }
        }

        throw NetworkError.decodingError
    }

    /// 打印详细的解码错误信息
    private func printDetailedDecodingError(_ error: DecodingError) {
        print("🔍 详细解码错误:")

        switch error {
        case .keyNotFound(let key, let context):
            print("   🔑 缺少键: \(key.stringValue)")
            print("   📍 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("   💬 描述: \(context.debugDescription)")

        case .typeMismatch(let type, let context):
            print("   🔄 类型不匹配: 期望 \(type)")
            print("   📍 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("   💬 描述: \(context.debugDescription)")

        case .valueNotFound(let type, let context):
            print("   ❓ 值未找到: \(type)")
            print("   📍 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("   💬 描述: \(context.debugDescription)")

        case .dataCorrupted(let context):
            print("   💥 数据损坏")
            print("   📍 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("   💬 描述: \(context.debugDescription)")

        @unknown default:
            print("   ❓ 未知解码错误: \(error)")
        }
    }

    // MARK: - 日志打印方法
    private func printLog(_ message: String) {
        print("🌐 NetworkManager: \(message)")
    }

    private func printRequestLog(url: String, method: String, parameters: [String: Any]?, headers: [String: String]?, cookies: [String: String]? = nil) {
        print("\n" + String(repeating: "=", count: 60))
        print("🚀 网络请求开始")
        print(String(repeating: "=", count: 60))
        print("📍 URL: \(url)")
        print("🔧 Method: \(method)")

        if let headers = headers, !headers.isEmpty {
            print("📋 Headers:")
            for (key, value) in headers {
                // 隐藏敏感信息
                let displayValue = key.lowercased().contains("authorization") ? "Bearer ***" : value
                print("   \(key): \(displayValue)")
            }
        }

        if let parameters = parameters, !parameters.isEmpty {
            print("📦 Parameters:")
            for (key, value) in parameters {
                // 隐藏密码等敏感信息
                let displayValue = key.lowercased().contains("password") ? "***" : "\(value)"
                print("   \(key): \(displayValue)")
            }
        }

        if let cookies = cookies, !cookies.isEmpty {
            print("🍪 Cookies:")
            for (key, value) in cookies {
                // 对于token类型的Cookie，显示前6位和后4位，中间显示长度
                let displayValue: String
                if key.lowercased().contains("token") && value.count > 10 {
                    let prefix = String(value.prefix(6))
                    let suffix = String(value.suffix(4))
                    let middleLength = value.count - 10
                    displayValue = "\(prefix)***(\(middleLength)字符)***\(suffix)"
                } else {
                    displayValue = value
                }
                print("   \(key): \(displayValue)")
            }
        }

        print("⏰ 请求时间: \(getCurrentTimeString())")
        print(String(repeating: "=", count: 60))
    }

    private func printUploadLog(url: String, fileName: String, fileSize: Int, parameters: [String: Any]?, headers: [String: String]?) {
        print("\n" + String(repeating: "=", count: 60))
        print("📤 文件上传请求开始")
        print(String(repeating: "=", count: 60))
        print("📍 URL: \(url)")
        print("📁 文件名: \(fileName)")
        print("📏 文件大小: \(formatFileSize(fileSize))")

        if let headers = headers, !headers.isEmpty {
            print("📋 Headers:")
            for (key, value) in headers {
                let displayValue = key.lowercased().contains("authorization") ? "Bearer ***" : value
                print("   \(key): \(displayValue)")
            }
        }

        if let parameters = parameters, !parameters.isEmpty {
            print("📦 Parameters:")
            for (key, value) in parameters {
                print("   \(key): \(value)")
            }
        }

        print("⏰ 请求时间: \(getCurrentTimeString())")
        print(String(repeating: "=", count: 60))
    }

    private func printResponseLog(response: DataResponse<Data?, AFError>) {
        print("\n" + String(repeating: "-", count: 60))
        print("📥 网络响应")
        print(String(repeating: "-", count: 60))

        if let httpResponse = response.response {
            let statusCode = httpResponse.statusCode
            let statusEmoji = getStatusEmoji(statusCode)
            print("\(statusEmoji) 状态码: \(statusCode)")
            print("🌐 URL: \(httpResponse.url?.absoluteString ?? "Unknown")")

            // 打印Content-Type
            if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                print("📋 Content-Type: \(contentType)")
            }
        }

        if let headers = response.response?.allHeaderFields {
            print("📋 响应Headers:")
            for (key, value) in headers {
                print("   \(key): \(value)")
            }
        }

        // 打印响应数据
        if let data = response.data {
            print("📊 响应数据大小: \(formatFileSize(data.count))")

            // 尝试打印响应内容
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 响应内容:")

                // 尝试格式化JSON
                if let jsonData = responseString.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                   let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
                    print(prettyJsonString)
                } else {
                    // 如果不是有效JSON，直接打印原始内容
                    print("原始响应: \(responseString)")
                }
            } else {
                print("📄 响应内容: [二进制数据，无法显示为文本]")
            }
        }

        // 打印错误信息
        if let error = response.error {
            print("❌ 错误信息: \(error.localizedDescription)")
            if let underlyingError = error.underlyingError {
                print("🔍 底层错误: \(underlyingError.localizedDescription)")
            }
        }

        print("⏰ 响应时间: \(getCurrentTimeString())")
        print("⏱️ 请求耗时: \(String(format: "%.3f", response.metrics?.taskInterval.duration ?? 0))秒")
        print(String(repeating: "-", count: 60) + "\n")
    }

    private func getStatusEmoji(_ statusCode: Int) -> String {
        switch statusCode {
        case 200...299:
            return "✅"
        case 300...399:
            return "🔄"
        case 400...499:
            return "⚠️"
        case 500...599:
            return "❌"
        default:
            return "❓"
        }
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    private func getCurrentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    // MARK: - 上传文件
    func upload<T: Codable>(
        url: String,
        data: Data,
        fileName: String,
        mimeType: String = "image/jpeg",
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {

        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }

        var httpHeaders: HTTPHeaders = []
        if let headers = headers {
            for (key, value) in headers {
                httpHeaders.add(name: key, value: value)
            }
        }

        // 打印上传请求日志
        printUploadLog(url: url.absoluteString, fileName: fileName, fileSize: data.count, parameters: parameters, headers: headers)

        return try await withCheckedThrowingContinuation { continuation in
            session.upload(
                multipartFormData: { multipartFormData in
                    // 添加文件
                    multipartFormData.append(
                        data,
                        withName: "file",
                        fileName: fileName,
                        mimeType: mimeType
                    )

                    // 添加其他参数
                    if let parameters = parameters {
                        for (key, value) in parameters {
                            if let stringValue = "\(value)".data(using: .utf8) {
                                multipartFormData.append(stringValue, withName: key)
                            }
                        }
                    }
                },
                to: url,
                headers: httpHeaders
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                // 打印响应日志

                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        continuation.resume(throwing: NetworkError.serverError(statusCode))
                    } else {
                        continuation.resume(throwing: NetworkError.networkError(error.localizedDescription))
                    }
                }
            }
        }
    }

    // MARK: - 认证相关方法
    func getAuthHeaders() -> [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        // 添加Cookie认证
        if let cookieInfo = AuthService.shared.getAuthCookie() {
            headers["Cookie"] = "\(cookieInfo.name)=\(cookieInfo.value)"
        }

        return headers
    }

    // 获取物品列表
    func getStuffList() async throws -> StuffListResponse {
        let baseURL = "http://ds2.tapgame.cn"

        return try await postWithAutoRefresh(
            url: "\(baseURL)/app/user/stuff/base/list",
            parameters: ["body" : "{}"],
            headers: getAuthHeaders(),
            responseType: StuffListResponse.self
        )
    }
}

// MARK: - 响应模型示例
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let code: Int?
}

// MARK: - 使用示例的数据模型
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// 这个LoginResponse已经在AuthService中重新定义，这里保留作为示例
struct NetworkLoginResponse: Codable {
    let token: String
    let user: User
}

// MARK: - 专注计时相关API
extension NetworkManager {

    /// 开始专注计时
    /// - Parameters:
    ///   - duration: 专注时长（分钟）
    /// - Returns: 专注计时开始响应
    func startConcentration(duration: Int, concentrationPlanTag: String) async throws -> ConcentrationStartResponse {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/concentration/start"
        let url = baseURL + endpoint

        // 获取当前日期和时区信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier

        let parameters: [String: Any] = [
            "operateDate": operateDate,
            "timeZone": timeZone,
            "duration": duration,
            "concentrationPlanTag": concentrationPlanTag
        ]

        print("🎯 开始专注计时API请求:")
        print("   operateDate: \(operateDate)")
        print("   timeZone: \(timeZone)")
        print("   duration: \(duration)")

        let headers = [
            "Content-Type": "application/json"
        ]

        // 获取Cookie信息
        var cookies: [String: String] = [:]
        if let authCookie = AuthService.shared.getAuthCookie() {
            cookies[authCookie.name] = authCookie.value
        }

        return try await postWithAutoRefresh(
            url: url,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: ConcentrationStartResponse.self
        )
    }

    /// 结束专注计时
    /// - Parameters:
    ///   - id: 专注计划ID
    /// - Returns: 专注计时结束响应
    func endConcentration(id: String) async throws -> ConcentrationEndResponse {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/concentration/finish"
        let url = baseURL + endpoint

        // 获取当前日期和时区信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier

        let parameters: [String: Any] = [
            "operateDate": operateDate,
            "timeZone": timeZone,
            "id": id
        ]

        print("🏁 结束专注计时API请求:")
        print("   operateDate: \(operateDate)")
        print("   timeZone: \(timeZone)")
        print("   id: \(id)")

        let headers = [
            "Content-Type": "application/json"
        ]

        // 获取Cookie信息
        var cookies: [String: String] = [:]
        if let authCookie = AuthService.shared.getAuthCookie() {
            cookies[authCookie.name] = authCookie.value
        }

        return try await postWithAutoRefresh(
            url: url,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: ConcentrationEndResponse.self
        )
    }

    /// 使用SwiftyJSON开始专注计时
    /// - Parameters:
    ///   - duration: 专注时长（分钟）
    ///   - concentrationPlanTag: 专注计划标签
    /// - Returns: SwiftyJSON对象
    func startConcentrationWithJSON(duration: Int, concentrationPlanTag: String) async throws -> JSON {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/concentration/start"
        let url = baseURL + endpoint

        // 获取当前日期和时区信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier

        let parameters: [String: Any] = [
            "operateDate": operateDate,
            "timeZone": timeZone,
            "duration": duration,
            "concentrationPlanTag": concentrationPlanTag
        ]

        print("🎯 开始专注计时API请求 (SwiftyJSON):")
        print("   operateDate: \(operateDate)")
        print("   timeZone: \(timeZone)")
        print("   duration: \(duration)")

        let headers = [
            "Content-Type": "application/json"
        ]

        // 获取Cookie信息
        var cookies: [String: String] = [:]
        if let authCookie = AuthService.shared.getAuthCookie() {
            cookies[authCookie.name] = authCookie.value
        }

        return try await postJSON(
            url: url,
            parameters: parameters,
            headers: headers,
            cookies: cookies
        )
    }

    /// 检查海报兑换资格
    /// - Parameter posterId: 海报ID
    /// - Returns: SwiftyJSON对象
    func checkPosterExchange() async throws -> PosterExchangeCheckResponse {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/stuff/poster/exchange/check"
        let url = baseURL + endpoint

        // 获取当前日期和时区信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier

        let parameters: [String: Any] = [
            "operateDate": operateDate,
            "timeZone": timeZone,
        ]

        print("🎫 海报兑换资格检查API请求 (SwiftyJSON):")
        print("   operateDate: \(operateDate)")
        print("   timeZone: \(timeZone)")

        let headers = [
            "Content-Type": "application/json"
        ]

        // 获取Cookie信息
        var cookies: [String: String] = [:]
        if let authCookie = AuthService.shared.getAuthCookie() {
            cookies[authCookie.name] = authCookie.value
        }

        return try await post(
            url: url,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: PosterExchangeCheckResponse.self
        )
    }

    /// 兑换海报
    /// - Parameter posterId: 海报ID
    /// - Returns: SwiftyJSON对象
    func exchangePoster() async throws -> UserPosterStuffResponse {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/stuff/poster/exchange"
        let url = baseURL + endpoint

        // 当前日期和时区
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier

        let parameters: [String: Any] = [
            "operateDate": operateDate,
            "timeZone": timeZone,
        ]

        print("🎫 海报兑换API请求 (SwiftyJSON):")
        print("   operateDate: \(operateDate)")
        print("   timeZone: \(timeZone)")

        let headers = ["Content-Type": "application/json"]

        // 获取Cookie信息
        var cookies: [String: String] = [:]
        if let authCookie = AuthService.shared.getAuthCookie() {
            cookies[authCookie.name] = authCookie.value
        }

        return try await post(
            url: url,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: UserPosterStuffResponse.self
        )
    }

    /// 获取专注统计数据
    /// - Parameters:
    ///   - period: 统计周期，如 "MONTH"、"WEEK"、"DAY"
    ///   - month: 月份
    ///   - year: 年份
    /// - Returns: SwiftyJSON对象
    func getConcentrationStatistics(period: String, month: Int, year: Int, operateDate: String? = nil) async throws -> ConcentrationStatisticsResponse {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/concentration/statistics"
        let url = baseURL + endpoint

//        // 当前日期和时区
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var finalOperateDate = operateDate ?? dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier

        let calendar = Calendar.current
        let today = Date()

        let parameters: [String: Any] = [
            "operateDate": finalOperateDate,
            "timeZone": timeZone,
            "period": period == "DAY" ? "TODAY" : period,
            "month": month,
            "year": year
        ]

        print("📊 获取专注统计API请求 (SwiftyJSON):")
        print("   operateDate: \(finalOperateDate)")
        print("   timeZone: \(timeZone)")
        print("   period: \(period), month: \(month), year: \(year)")

        let headers = ["Content-Type": "application/json"]

        // 获取Cookie信息
        var cookies: [String: String] = [:]
        if let authCookie = AuthService.shared.getAuthCookie() {
            cookies[authCookie.name] = authCookie.value
        }

        return try await post(
            url: url,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: ConcentrationStatisticsResponse.self
        )
    }

}

// MARK: - 物品相关API
extension NetworkManager {

    /// 获取用户物品基础列表
    /// - Returns: 物品列表响应
    func getUserStuffBaseList() async throws -> StuffListResponse {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/stuff/base/list"
        let url = baseURL + endpoint

        return try await post(
            url: url,
            parameters: ["body" : "{}"],
            headers: getAuthHeaders(),
            responseType: StuffListResponse.self
        )
    }

    /// 使用SwiftyJSON获取用户物品基础列表
    /// - Returns: SwiftyJSON对象
    func getUserStuffBaseListWithJSON() async throws -> JSON {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/stuff/base/list"
        let url = baseURL + endpoint

        // 获取Cookie信息
        var cookies: [String: String] = [:]
        if let authCookie = AuthService.shared.getAuthCookie() {
            cookies[authCookie.name] = authCookie.value
        }

        return try await postJSON(
            url: url,
            parameters: ["body" : "{}"],
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            cookies: cookies
        )
    }
}

// MARK: - Apple登录相关API
extension NetworkManager {

    /// Apple登录
    /// - Parameters:
    ///   - operateDate: 操作日期
    ///   - timeZone: 时区
    ///   - identityToken: Apple身份令牌
    /// - Returns: Apple登录响应
    func appleLogin(operateDate: String, timeZone: String, identityToken: String) async throws -> AchievementLoginResponse {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/login/apple"
        let url = baseURL + endpoint

        let parameters: [String: Any] = [
            "operateDate": operateDate,
            "timeZone": timeZone,
            "identityToken": identityToken
        ]

        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        print("🍎 Apple登录API请求:")
        print("   URL: \(url)")
        print("   参数: \(parameters)")

        return try await post(
            url: url,
            parameters: parameters,
            headers: headers,
            responseType: AchievementLoginResponse.self
        )
    }

    /// 使用SwiftyJSON进行Apple登录
    /// - Parameters:
    ///   - operateDate: 操作日期
    ///   - timeZone: 时区
    ///   - identityToken: Apple身份令牌
    /// - Returns: SwiftyJSON对象
    func appleLoginWithJSON(operateDate: String, timeZone: String, identityToken: String) async throws -> JSON {
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/login/apple"
        let url = baseURL + endpoint

        let parameters: [String: Any] = [
            "operateDate": operateDate,
            "timeZone": timeZone,
            "identityToken": identityToken
        ]

        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        print("🍎 Apple登录API请求 (SwiftyJSON):")
        print("   URL: \(url)")
        print("   参数: \(parameters)")

        return try await postJSON(
            url: url,
            parameters: parameters,
            headers: headers
        )
    }
}
