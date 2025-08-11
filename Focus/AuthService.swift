//
//  AuthService.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import Foundation

// MARK: - 认证相关数据模型
struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let confirmPassword: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case email
        case password
        case confirmPassword = "confirm_password"
    }
}

struct LoginRequest: Codable {
    let account: String
    let password: String
}

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let data: AuthData?
    let code: Int
}

struct AuthData: Codable {
    let token: String
    let user: UserInfo
    let expiresIn: Int?
    
    enum CodingKeys: String, CodingKey {
        case token
        case user
        case expiresIn = "expires_in"
    }
}

struct UserInfo: Codable {
    let id: Int
    let username: String
    let email: String
    let avatar: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case avatar
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - 认证服务
class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // 基础URL - 稍后你可以替换
    private let baseURL = "http://ds2.tapgame.cn"

    // MARK: - 用户注册
    func register(
        username: String,
        email: String,
        password: String,
        confirmPassword: String
    ) async throws -> AuthResponse {
        let registerRequest = RegisterRequest(
            username: username,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        let parameters: [String: Any] = [
            "username": registerRequest.username,
            "email": registerRequest.email,
            "password": registerRequest.password,
            "confirm_password": registerRequest.confirmPassword
        ]
        
        let response: AuthResponse = try await NetworkManager.shared.post(
            url: "\(baseURL)/auth/register",
            parameters: parameters,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            responseType: AuthResponse.self
        )
        
        // 如果注册成功，保存用户信息
        if response.success, let authData = response.data {
            saveAuthData(authData)
        }
        
        return response
    }
    
    // MARK: - 用户登录
    func login(account: String, password: String) async throws -> AuthResponse {
        let loginRequest = LoginRequest(account: account, password: password)
        
        let parameters: [String: Any] = [
            "account": loginRequest.account,
            "password": loginRequest.password
        ]
        
        let response: AuthResponse = try await NetworkManager.shared.post(
            url: "\(baseURL)/app/user/login",
            parameters: parameters,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            responseType: AuthResponse.self
        )
        
        // 如果登录成功，保存用户信息
        if response.success, let authData = response.data {
            saveAuthData(authData)
        }
        
        return response
    }
    
    // MARK: - 获取用户信息
    func getUserProfile() async throws -> UserInfo {
        guard let token = getAuthToken() else {
            throw NetworkError.networkError("未找到认证token")
        }
        
        let response: APIResponse<UserInfo> = try await NetworkManager.shared.get(
            url: "\(baseURL)/user/profile",
            headers: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            responseType: APIResponse<UserInfo>.self
        )
        
        guard let userInfo = response.data else {
            throw NetworkError.noData
        }
        
        return userInfo
    }
    
    // MARK: - 用户登出
    func logout() async throws -> APIResponse<String> {
        guard let token = getAuthToken() else {
            throw NetworkError.networkError("未找到认证token")
        }
        
        let response: APIResponse<String> = try await NetworkManager.shared.post(
            url: "\(baseURL)/auth/logout",
            headers: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            responseType: APIResponse<String>.self
        )
        
        // 清除本地存储的认证信息
        clearAuthData()
        
        return response
    }
    
    // MARK: - 刷新Token
    func refreshToken() async throws -> AuthResponse {
        guard let token = getAuthToken() else {
            throw NetworkError.networkError("未找到认证token")
        }
        
        let response: AuthResponse = try await NetworkManager.shared.post(
            url: "\(baseURL)/auth/refresh",
            headers: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            responseType: AuthResponse.self
        )
        
        // 如果刷新成功，更新token
        if response.success, let authData = response.data {
            saveAuthData(authData)
        }
        
        return response
    }
    
    // MARK: - 上传头像
    func uploadAvatar(imageData: Data) async throws -> APIResponse<String> {
        guard let token = getAuthToken() else {
            throw NetworkError.networkError("未找到认证token")
        }
        
        let response: APIResponse<String> = try await NetworkManager.shared.upload(
            url: "\(baseURL)/user/avatar",
            data: imageData,
            fileName: "avatar.jpg",
            mimeType: "image/jpeg",
            headers: [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json"
            ],
            responseType: APIResponse<String>.self
        )
        
        return response
    }
    
    // MARK: - 修改密码
    func changePassword(
        currentPassword: String,
        newPassword: String,
        confirmPassword: String
    ) async throws -> APIResponse<String> {
        guard let token = getAuthToken() else {
            throw NetworkError.networkError("未找到认证token")
        }
        
        let parameters: [String: Any] = [
            "current_password": currentPassword,
            "new_password": newPassword,
            "confirm_password": confirmPassword
        ]
        
        let response: APIResponse<String> = try await NetworkManager.shared.put(
            url: "\(baseURL)/user/password",
            parameters: parameters,
            headers: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            responseType: APIResponse<String>.self
        )
        
        return response
    }
    
    // MARK: - 本地存储管理
    private func saveAuthData(_ authData: AuthData) {
        UserDefaults.standard.set(authData.token, forKey: "auth_token")
        
        // 保存用户信息
        if let userData = try? JSONEncoder().encode(authData.user) {
            UserDefaults.standard.set(userData, forKey: "user_info")
        }
        
        // 保存过期时间
        if let expiresIn = authData.expiresIn {
            let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
            UserDefaults.standard.set(expirationDate, forKey: "token_expiration")
        }
    }
    
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "auth_token")
    }
    
    private func clearAuthData() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "user_info")
        UserDefaults.standard.removeObject(forKey: "token_expiration")
    }
    
    // MARK: - 检查登录状态
    func isLoggedIn() -> Bool {
        guard let token = getAuthToken() else { return false }
        
        // 检查token是否过期
        if let expirationDate = UserDefaults.standard.object(forKey: "token_expiration") as? Date {
            return Date() < expirationDate
        }
        
        return !token.isEmpty
    }
    
    // MARK: - 获取当前用户信息
    func getCurrentUser() -> UserInfo? {
        guard let userData = UserDefaults.standard.data(forKey: "user_info") else { return nil }
        return try? JSONDecoder().decode(UserInfo.self, from: userData)
    }
}

// MARK: - SwiftUI中的使用示例
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isLoggedIn = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("登录")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                TextField("邮箱", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("密码", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("登录")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading || email.isEmpty || password.isEmpty)
        }
        .padding()
        .fullScreenCover(isPresented: $isLoggedIn) {
            // 登录成功后的主界面
            Text("登录成功！")
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await AuthService.shared.login(
                    account: email,
                    password: password
                )
                
                await MainActor.run {
                    if response.success {
                        isLoggedIn = true
                    } else {
                        errorMessage = response.message
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct RegisterView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("注册")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                TextField("用户名", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("邮箱", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("密码", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("确认密码", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            Button(action: register) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("注册")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading || !isFormValid)
        }
        .padding()
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && 
        password == confirmPassword && password.count >= 6
    }
    
    private func register() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let response = try await AuthService.shared.register(
                    username: username,
                    email: email,
                    password: password,
                    confirmPassword: confirmPassword
                )
                
                await MainActor.run {
                    if response.success {
                        successMessage = "注册成功！"
                        // 清空表单
                        username = ""
                        email = ""
                        password = ""
                        confirmPassword = ""
                    } else {
                        errorMessage = response.message
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
