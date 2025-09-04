//
//  NetworkManager.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import Foundation
import Alamofire

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
                        
                        // 首先尝试直接解码
                        if let decodedData = try? JSONDecoder().decode(T.self, from: data) {
                            continuation.resume(returning: decodedData)
                            return
                        }
                        
                        // 如果直接解码失败，检查是否是文本响应
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("🔍 原始响应内容: \(responseString)")
                            
                            // 尝试处理可能的文本响应
                            if T.self == String.self {
                                continuation.resume(returning: responseString as! T)
                                return
                            }
                            
                            // 检查是否是包装在引号中的JSON字符串
                            if responseString.hasPrefix("\"") && responseString.hasSuffix("\"") {
                                let unquotedString = String(responseString.dropFirst().dropLast())
                                if let unquotedData = unquotedString.data(using: .utf8),
                                   let decodedData = try? JSONDecoder().decode(T.self, from: unquotedData) {
                                    continuation.resume(returning: decodedData)
                                    return
                                }
                            }
                            
                            // 尝试修复常见的JSON格式问题
                            let cleanedString = responseString
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: "\n", with: "")
                                .replacingOccurrences(of: "\r", with: "")
                            
                            if let cleanedData = cleanedString.data(using: .utf8),
                               let decodedData = try? JSONDecoder().decode(T.self, from: cleanedData) {
                                continuation.resume(returning: decodedData)
                                return
                            }
                        }
                        
                        // 所有解码尝试都失败
                        print("❌ 响应解码失败，原始数据长度: \(data.count)")
                        
                        // 尝试解析为通用JSON来查看结构
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                            print("🔍 JSON结构预览: \(jsonObject)")
                        }
                        
                        continuation.resume(throwing: NetworkError.networkError("数据解析失败"))
                        
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
        
        return try await post(
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
    func startConcentration(duration: Int) async throws -> ConcentrationStartResponse {
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
            "duration": duration
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
        
        return try await post(
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
        
        return try await post(
            url: url,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: ConcentrationEndResponse.self
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
}

// MARK: - Apple登录相关API
extension NetworkManager {
    
    /// Apple登录
    /// - Parameters:
    ///   - operateDate: 操作日期
    ///   - timeZone: 时区
    ///   - identityToken: Apple身份令牌
    /// - Returns: Apple登录响应
    func appleLogin(operateDate: String, timeZone: String, identityToken: String) async throws -> AppleSignInResponse {
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
            responseType: AppleSignInResponse.self
        )
    }
}
