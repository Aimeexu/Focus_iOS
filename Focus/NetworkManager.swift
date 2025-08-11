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
        responseType: T.Type
    ) async throws -> T {
        
        guard let url = URL(string: url) else {
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
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: alamofireMethod,
                parameters: parameters,
                encoding: method == .GET ? URLEncoding.default : JSONEncoding.default,
                headers: httpHeaders
            )
            .validate()
            .responseDecodable(of: T.self) { response in
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
    
    // MARK: - GET请求
    func get<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            url: url,
            method: .GET,
            parameters: parameters,
            headers: headers,
            responseType: responseType
        )
    }
    
    // MARK: - POST请求
    func post<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            url: url,
            method: .POST,
            parameters: parameters,
            headers: headers,
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

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}