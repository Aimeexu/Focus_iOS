//
//  FacebookSignInService.swift
//  Focus
//
//  Created by Kiro on 2025/10/10.
//

import Foundation
import SwiftUI
import FBSDKLoginKit
import FBSDKCoreKit

// MARK: - Facebook登录请求模型
struct FacebookSignInRequest: Codable {
    let operateDate: String
    let timeZone: String
    let accessToken: String
    let userID: String
    let email: String?
    let name: String?
    let deviceId: String?
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case operateDate
        case timeZone
        case accessToken = "access_token"
        case userID = "user_id"
        case email
        case name
        case deviceId
        case state
    }
}

// MARK: - Facebook登录服务
@MainActor
class FacebookSignInService: ObservableObject {
    static let shared = FacebookSignInService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - 开始Facebook登录流程
    func signInWithFacebook() async throws -> AuthResponse {
        print("📘 开始Facebook登录流程")
        
        return try await withCheckedThrowingContinuation { continuation in
            let loginManager = LoginManager()
            
            // 配置登录权限
            let permissions = ["public_profile", "email"]
            
            print("📘 Facebook登录请求配置:")
            print("   permissions: \(permissions)")
            
            // 执行登录
            loginManager.logIn(permissions: permissions, from: nil) { result, error in
                Task { @MainActor in
                    if let error = error {
                        print("❌ Facebook登录错误: \(error.localizedDescription)")
                        continuation.resume(throwing: NetworkError.networkError("Facebook登录失败: \(error.localizedDescription)"))
                        return
                    }
                    
                    guard let result = result, !result.isCancelled else {
                        print("📘 用户取消了Facebook登录")
                        continuation.resume(throwing: NetworkError.networkError("用户取消了Facebook登录"))
                        return
                    }
                    
                    guard let accessToken = result.token?.tokenString else {
                        print("❌ 无法获取Facebook访问令牌")
                        continuation.resume(throwing: NetworkError.networkError("无法获取Facebook访问令牌"))
                        return
                    }
                    
                    print("✅ 成功获取Facebook访问令牌")
                    
                    do {
                        let authResponse = try await self.handleFacebookCredential(accessToken: accessToken)
                        continuation.resume(returning: authResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    // MARK: - 处理Facebook登录凭证
    private func handleFacebookCredential(accessToken: String) async throws -> AuthResponse {
        print("📘 处理Facebook登录凭证")
        
        // 获取用户信息
        let userInfo = try await fetchFacebookUserInfo(accessToken: accessToken)
        
        // 获取当前日期和时区信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier
        
        let facebookSignInRequest = FacebookSignInRequest(
            operateDate: operateDate,
            timeZone: timeZone,
            accessToken: accessToken,
            userID: userInfo.userID,
            email: userInfo.email,
            name: userInfo.name,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            state: UUID().uuidString
        )
        
        // 调用后端API验证Facebook登录
        return try await sendFacebookSignInToServer(facebookSignInRequest)
    }
    
    // MARK: - 获取Facebook用户信息
    private func fetchFacebookUserInfo(accessToken: String) async throws -> (userID: String, email: String?, name: String?) {
        return try await withCheckedThrowingContinuation { continuation in
            let request = GraphRequest(graphPath: "me", parameters: ["fields": "id,name,email"])
            
            request.start { _, result, error in
                if let error = error {
                    print("❌ 获取Facebook用户信息失败: \(error.localizedDescription)")
                    continuation.resume(throwing: NetworkError.networkError("获取Facebook用户信息失败"))
                    return
                }
                
                guard let result = result as? [String: Any],
                      let userID = result["id"] as? String else {
                    print("❌ Facebook用户信息格式错误")
                    continuation.resume(throwing: NetworkError.networkError("Facebook用户信息格式错误"))
                    return
                }
                
                let email = result["email"] as? String
                let name = result["name"] as? String
                
                print("📘 成功获取Facebook用户信息:")
                print("   userID: \(userID)")
                print("   email: \(email ?? "nil")")
                print("   name: \(name ?? "nil")")
                
                continuation.resume(returning: (userID: userID, email: email, name: name))
            }
        }
    }
    
    // MARK: - 发送Facebook登录信息到服务器
    private func sendFacebookSignInToServer(_ request: FacebookSignInRequest) async throws -> AuthResponse {
        let baseURL = "http://ds2.tapgame.cn"

        let parameters: [String: Any] = [
            "accessToken": request.accessToken,
            "userID": request.userID,
            "email": request.email ?? "",
            "name": request.name ?? "",
            "state": request.state ?? "",
            "deviceId": request.deviceId ?? "",
            "operateDate": request.operateDate,
            "timeZone": request.timeZone
        ]
        
        do {
            print("📘 发送Facebook登录请求到服务器...")
            print("   URL: \(baseURL)/app/user/login/facebook")
            print("   参数: \(parameters)")
            
            // 使用AchievementLoginResponse
            let facebookResponse: AchievementLoginResponse = try await NetworkManager.shared.post(
                url: "\(baseURL)/app/user/login/facebook",
                parameters: parameters,
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ],
                responseType: AchievementLoginResponse.self
            )
            
            print("📘 服务器响应解析成功:")
            print("   status: '\(facebookResponse.status)'")
            print("   data存在: \(facebookResponse.data != nil)")
            print("   code: '\(facebookResponse.code)'")
            print("   message: '\(facebookResponse.message)'")
            
            // 转换为AuthResponse格式
            let authResponse: AuthResponse
            
            if facebookResponse.status == "success", let facebookLoginData = facebookResponse.data {
                print("✅ Facebook登录成功判断通过")
                
                // 将 AchievementUser 转换为 UserInfo
                let userInfo = UserInfo(
                    account: facebookLoginData.user.account,
                    phone: facebookLoginData.user.phone,
                    channel: Channel(
                        channelType: facebookLoginData.user.channel.channelType,
                        description: facebookLoginData.user.channel.description,
                        uuid: facebookLoginData.user.channel.uuid
                    ),
                    nickname: facebookLoginData.user.nickname ?? facebookLoginData.user.account,
                    userSettings: UserSettings(
                        backgroundMusic: facebookLoginData.user.userSettings.backgroundMusic
                    ),
                    uuid: facebookLoginData.user.uuid,
                    userStuffs: [], // 需要从AchievementUserStuffs转换为[UserStuff]，这里简化处理
                    createTime: facebookLoginData.user.createTime
                )
                
                let authData = AuthData(
                    token: facebookLoginData.accessToken,
                    user: userInfo,
                    expiresIn: 3600
                )
                
                authResponse = AuthResponse(
                    success: true,
                    message: facebookResponse.message.isEmpty ? "Facebook登录成功" : facebookResponse.message,
                    data: authData,
                    code: 200
                )
                
                // 保存认证信息
                UserManager.shared.saveFacebookLoginData(facebookLoginData, loginMethod: "facebook")
                
            } else {
                print("❌ Facebook登录成功判断失败:")
                print("   status == 'success': \(facebookResponse.status == "success")")
                print("   data != nil: \(facebookResponse.data != nil)")
                
                authResponse = AuthResponse(
                    success: false,
                    message: facebookResponse.message.isEmpty ? "Facebook登录失败" : facebookResponse.message,
                    data: nil,
                    code: Int(facebookResponse.code) ?? 400
                )
            }
            
            return authResponse
            
        } catch NetworkError.serverError(let statusCode) {
            throw NetworkError.serverError(statusCode)
        } catch {
            throw error
        }
    }
}