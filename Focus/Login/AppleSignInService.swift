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
    let operateDate: String
    let timeZone: String
    let identityToken: String
    
    // 保留原有字段用于内部处理
    let authorizationCode: String?
    let userIdentifier: String?
    let email: String?
    let fullName: PersonNameComponents?
    let deviceId: String?
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case operateDate
        case timeZone
        case identityToken
        case authorizationCode = "authorization_code"
        case userIdentifier = "user_identifier"
        case email
        case fullName = "full_name"
        case deviceId
        case state
    }
}

struct AppleSignInResponse: Codable {
    let status: String
    let data: AppleLoginData?
    let code: String
    let message: String
    let errors: String?
}

struct AppleLoginData: Codable {
    let user: AppleUserInfo
    let accessTokenName: String
    let accessToken: String
    let refreshToken: String
}

struct AppleUserInfo: Codable {
    let uuid: String
    let account: String
    let nickname: String?
    let phone: String?
    let channel: AppleChannel
    let userSettings: AppleUserSettings
    let userStuffs: UserStuffsContainer
    let createTime: Int64
}

struct AppleChannel: Codable {
    let uuid: String
    let channelType: String
    let description: String
}

struct AppleUserSettings: Codable {
    let backgroundMusic: String
}

struct AppleUserStuff: Codable {
    let amount: Int
    let userStuffBaseId: String
    let userStuffBase: AppleUserStuffBase?
    let createTime: String?
    let updateTime: String?
}

// Apple登录响应中的UserStuffBase结构
struct AppleUserStuffBase: Codable {
    let uuid: String
    let userStuffType: String
    let userStuffScene: String
    let icon: String
    let name: String
    let description: String
    let attachment: StuffAttachment?
    let stuffPrices: [AppleStuffPrice]
}

// Apple登录响应中的StuffPrice结构
struct AppleStuffPrice: Codable {
    let stuffId: String
    let amount: Int
}

// 用户物品容器，按场景分组
struct UserStuffsContainer: Codable {
    let iceSands: [AppleUserStuff?]?
    let calmFields: [AppleUserStuff?]?
    let tropicalWilds: [AppleUserStuff?]?
    
    enum CodingKeys: String, CodingKey {
        case iceSands = "IceSands"
        case calmFields = "CalmFields"
        case tropicalWilds = "TropicalWilds"
    }
    
    // 获取所有非空的用户物品
    var allUserStuffs: [AppleUserStuff] {
        let allStuffs = (iceSands ?? []) + (calmFields ?? []) + (tropicalWilds ?? [])
        return allStuffs.compactMap { $0 }
    }
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
        print("🍎 开始Apple登录流程")
        
        // 确保在主线程上执行
        return try await withCheckedThrowingContinuation { continuation in
            // 保存continuation
            self.currentContinuation = continuation
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            // 生成随机的nonce和state用于安全验证
            let nonce = UUID().uuidString
            request.nonce = nonce
            request.state = "apple_signin_\(Date().timeIntervalSince1970)"
            
            print("🍎 Apple登录请求配置:")
            print("   requestedScopes: \(request.requestedScopes ?? [])")
            print("   nonce: \(nonce)")
            print("   state: \(request.state ?? "nil")")
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            
            authorizationController.performRequests()
        }
    }
    
    // MARK: - 处理Apple登录凭证
    func handleAppleSignInCredential(_ credential: ASAuthorizationAppleIDCredential) async throws -> AuthResponse {
        // 详细的调试信息
        print("🍎 Apple登录凭证调试:")
        print("   identityToken存在: \(credential.identityToken != nil)")
        print("   authorizationCode存在: \(credential.authorizationCode != nil)")
        print("   user: \(credential.user)")
        print("   email: \(credential.email ?? "nil")")
        
        guard let identityToken = credential.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            throw NetworkError.networkError("无法获取Apple身份令牌")
        }
        
        // 处理授权码，某些情况下可能为空
        let authorizationCodeString: String
        if let authorizationCode = credential.authorizationCode,
           let codeString = String(data: authorizationCode, encoding: .utf8), !codeString.isEmpty {
            authorizationCodeString = codeString
            print("✅ 成功获取授权码")
        } else {
            // 如果授权码为空，这是正常情况（特别是在重复登录时）
            print("ℹ️ 授权码为空（这在某些情况下是正常的）")
            authorizationCodeString = ""
        }
        
        print("🍎 成功获取凭证:")
        print("   identityToken长度: \(identityTokenString.count)")
        print("   authorizationCode长度: \(authorizationCodeString.count)")
        
        // 获取当前日期和时区信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier
        
        let appleSignInRequest = AppleSignInRequest(
            operateDate: operateDate,
            timeZone: timeZone,
            identityToken: identityTokenString,
            authorizationCode: authorizationCodeString,
            userIdentifier: credential.user,
            email: credential.email,
            fullName: credential.fullName,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            state: UUID().uuidString
        )
        
        // 调用后端API验证Apple登录
        return try await sendAppleSignInToServer(appleSignInRequest)
    }
    
    // MARK: - 发送Apple登录信息到服务器
    private func sendAppleSignInToServer(_ request: AppleSignInRequest) async throws -> AuthResponse {
        let baseURL = "http://ds2.tapgame.cn"

        let parameters: [String: Any] = [
            "identityToken": request.identityToken,
            "authorizationCode": request.authorizationCode ?? "",
            "userIdentifier": request.userIdentifier ?? "",
            "email": request.email ?? "",
            "givenName": request.fullName?.givenName ?? "",
            "familyName": request.fullName?.familyName ?? "",
            "state": request.state ?? "",
            "deviceId": request.deviceId ?? "",
            "operateDate": request.operateDate,
            "timeZone": request.timeZone
        ]
        
        do {
            print("🍎 发送Apple登录请求到服务器...")
            print("   URL: \(baseURL)/app/user/login/apple")
            print("   参数: \(parameters)")
            
            // 首先尝试标准的AppleSignInResponse解析
            let appleResponse: AppleSignInResponse = try await NetworkManager.shared.post(
                url: "\(baseURL)/app/user/login/apple",
                parameters: parameters,
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ],
                responseType: AppleSignInResponse.self
            )
            
            print("🍎 服务器响应解析成功:")
            print("   status: '\(appleResponse.status)'")
            print("   data存在: \(appleResponse.data != nil)")
            print("   code: '\(appleResponse.code)'")
            print("   message: '\(appleResponse.message)'")
            
            // 转换为AuthResponse格式
            let authResponse: AuthResponse
            
            if appleResponse.status == "success", let appleLoginData = appleResponse.data {
                print("✅ 苹果登录成功判断通过")
                
                // 将 AppleUserInfo 转换为 UserInfo
                let userInfo = UserInfo(
                    account: appleLoginData.user.account,
                    phone: appleLoginData.user.phone,
                    channel: Channel(
                        channelType: appleLoginData.user.channel.channelType,
                        description: appleLoginData.user.channel.description,
                        uuid: appleLoginData.user.channel.uuid
                    ),
                    nickname: appleLoginData.user.nickname ?? appleLoginData.user.account,
                    userSettings: UserSettings(
                        backgroundMusic: appleLoginData.user.userSettings.backgroundMusic
                    ),
                    uuid: appleLoginData.user.uuid,
                    userStuffs: appleLoginData.user.userStuffs.allUserStuffs.map { appleStuff in
                        UserStuff(
                            amount: appleStuff.amount,
                            createTime: appleStuff.createTime ?? "",
                            userStuffBaseId: appleStuff.userStuffBaseId,
                            updateTime: appleStuff.updateTime ?? ""
                        )
                    },
                    createTime: appleLoginData.user.createTime
                )
                
                let authData = AuthData(
                    token: appleLoginData.accessToken,
                    user: userInfo,
                    expiresIn: 3600
                )
                
                authResponse = AuthResponse(
                    success: true,
                    message: appleResponse.message.isEmpty ? "Apple登录成功" : appleResponse.message,
                    data: authData,
                    code: 200
                )
                
                // 保存认证信息
                UserManager.shared.saveAppleLoginData(appleLoginData, loginMethod: "apple")
                
            } else {
                print("❌ 苹果登录成功判断失败:")
                print("   status == 'success': \(appleResponse.status == "success")")
                print("   data != nil: \(appleResponse.data != nil)")
                
                authResponse = AuthResponse(
                    success: false,
                    message: appleResponse.message.isEmpty ? "Apple登录失败" : appleResponse.message,
                    data: nil,
                    code: Int(appleResponse.code) ?? 400
                )
            }
            
            return authResponse
            
        } catch NetworkError.serverError(let statusCode) {
            throw NetworkError.serverError(statusCode)
        } catch {
            throw error
        }
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
                case .notInteractive:
                    errorMessage = "Apple登录不可交互"
                case .matchedExcludedCredential:
                    errorMessage = "Apple登录凭证被排除"
                case .credentialImport:
                    errorMessage = "Apple登录凭证导入失败"
                case .credentialExport:
                    errorMessage = "Apple登录凭证导出失败"
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
        return ASPresentationAnchor()
    }
}



// MARK: - AuthService扩展已移至 UserManager.swift
