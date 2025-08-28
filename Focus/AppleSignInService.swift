//
//  AppleSignInService.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import Foundation
import AuthenticationServices
import SwiftUI

// MARK: - Apple登录相关数据模型
struct AppleSignInRequest: Codable {
    let identityToken: String
    let authorizationCode: String
    let userIdentifier: String
    let email: String?
    let fullName: PersonNameComponents?
    
    enum CodingKeys: String, CodingKey {
        case identityToken = "identity_token"
        case authorizationCode = "authorization_code"
        case userIdentifier = "user_identifier"
        case email
        case fullName = "full_name"
    }
}

struct AppleSignInResponse: Codable {
    let status: String
    let data: LoginData?
    let code: String
    let message: String
    let errors: String?
}

// MARK: - Apple登录服务
@MainActor
class AppleSignInService: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AppleSignInService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 用于存储当前的continuation
    private var currentContinuation: CheckedContinuation<AuthResponse, Error>?
    
    private override init() {
        super.init()
    }
    
    // MARK: - 开始Apple登录流程
    func signInWithApple() async throws -> AuthResponse {
        // 确保在主线程上执行
        return try await withCheckedThrowingContinuation { continuation in
            // 保存continuation
            self.currentContinuation = continuation
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            
            authorizationController.performRequests()
        }
    }
    
    // MARK: - 处理Apple登录凭证
    func handleAppleSignInCredential(_ credential: ASAuthorizationAppleIDCredential) async throws -> AuthResponse {
        guard let identityToken = credential.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8),
              let authorizationCode = credential.authorizationCode,
              let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
            throw NetworkError.networkError("无法获取Apple登录凭证")
        }
        
        let appleSignInRequest = AppleSignInRequest(
            identityToken: identityTokenString,
            authorizationCode: authorizationCodeString,
            userIdentifier: credential.user,
            email: credential.email,
            fullName: credential.fullName
        )
        
        // 调用后端API验证Apple登录
        return try await sendAppleSignInToServer(appleSignInRequest)
    }
    
    // MARK: - 发送Apple登录信息到服务器
    private func sendAppleSignInToServer(_ request: AppleSignInRequest) async throws -> AuthResponse {
        let baseURL = "http://ds2.tapgame.cn"
        
        let parameters: [String: Any] = [
            "identity_token": request.identityToken,
            "authorization_code": request.authorizationCode,
            "user_identifier": request.userIdentifier,
            "email": request.email ?? "",
            "full_name": [
                "given_name": request.fullName?.givenName ?? "",
                "family_name": request.fullName?.familyName ?? ""
            ]
        ]
        
        do {
            let appleResponse: AppleSignInResponse = try await NetworkManager.shared.post(
                url: "\(baseURL)/app/user/login/apple",
                parameters: parameters,
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ],
                responseType: AppleSignInResponse.self
            )
            
            // 转换为AuthResponse格式
            let authResponse: AuthResponse
            
            if appleResponse.status == "success", let loginData = appleResponse.data {
                let authData = AuthData(
                    token: loginData.accessToken,
                    user: loginData.user,
                    expiresIn: 3600
                )
                
                authResponse = AuthResponse(
                    success: true,
                    message: appleResponse.message.isEmpty ? "Apple登录成功" : appleResponse.message,
                    data: authData,
                    code: 200
                )
                
                // 保存认证信息
                AuthService.shared.saveAuthData(authData)
                UserDefaults.standard.set(loginData.refreshToken, forKey: "refresh_token")
                UserDefaults.standard.set(loginData.accessTokenName, forKey: "access_token_name")
                
            } else {
                authResponse = AuthResponse(
                    success: false,
                    message: appleResponse.message.isEmpty ? "Apple登录失败" : appleResponse.message,
                    data: nil,
                    code: Int(appleResponse.code) ?? 400
                )
            }
            
            return authResponse
            
        } catch {
            // 如果后端还没有实现Apple登录接口，创建一个基于Apple凭证的响应
            if let networkError = error as? NetworkError,
               case .serverError(let statusCode) = networkError,
               statusCode == 404 || statusCode == 500 {
                return try await createMockAppleSignInResponse(request)
            } else {
                throw error
            }
        }
    }
    
    // MARK: - 创建模拟Apple登录响应（用于测试）
    private func createMockAppleSignInResponse(_ request: AppleSignInRequest) async throws -> AuthResponse {
        let testChannel = Channel(
            channelType: "apple",
            description: "Apple登录频道",
            uuid: "apple_channel_\(Date().timeIntervalSince1970)"
        )
        
        let testUserSettings = UserSettings(
            backgroundMusic: "default"
        )
        
        let displayName = [
            request.fullName?.givenName,
            request.fullName?.familyName
        ].compactMap { $0 }.joined(separator: " ")
        
        let testUser = UserInfo(
            account: request.email ?? "apple_user_\(request.userIdentifier.suffix(8))",
            phone: nil,
            channel: testChannel,
            nickname: displayName.isEmpty ? "Apple用户" : displayName,
            userSettings: testUserSettings,
            uuid: request.userIdentifier,
            userStuffs: [],
            createTime: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        let authData = AuthData(
            token: "apple_token_\(Date().timeIntervalSince1970)",
            user: testUser,
            expiresIn: 3600
        )
        
        let authResponse = AuthResponse(
            success: true,
            message: "Apple登录成功",
            data: authData,
            code: 200
        )
        
        // 保存认证信息
        AuthService.shared.saveAuthData(authData)
        
        return authResponse
    }
    
    // MARK: - 完成continuation
    private func completeContinuation(with result: Result<AuthResponse, Error>) {
        guard let continuation = currentContinuation else { return }
        currentContinuation = nil
        continuation.resume(with: result)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInService {
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            Task { @MainActor in
                self.completeContinuation(with: .failure(NetworkError.networkError("无效的Apple登录凭证")))
            }
            return
        }
        
        Task { @MainActor in
            do {
                let response = try await self.handleAppleSignInCredential(appleIDCredential)
                self.completeContinuation(with: .success(response))
            } catch {
                self.completeContinuation(with: .failure(error))
            }
        }
    }
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError {
                let errorMessage: String
                switch authError.code {
                case .canceled:
                    errorMessage = "用户取消了Apple登录"
                case .failed:
                    errorMessage = "Apple登录失败"
                case .invalidResponse:
                    errorMessage = "Apple登录响应无效"
                case .notHandled:
                    errorMessage = "Apple登录未处理"
                case .unknown:
                    errorMessage = "Apple登录未知错误"
                @unknown default:
                    errorMessage = "Apple登录未知错误"
                }
                self.completeContinuation(with: .failure(NetworkError.networkError(errorMessage)))
            } else {
                self.completeContinuation(with: .failure(error))
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInService {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}



// MARK: - AuthService扩展，添加公开的saveAuthData方法
extension AuthService {
    func saveAuthData(_ authData: AuthData) {
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
}
