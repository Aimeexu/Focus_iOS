//
//  GoogleSignInService.swift
//  Focus
//
//  Created by Kiro on 2025/10/16.
//

import Foundation
import GoogleSignIn
import SwiftUI

// MARK: - Google登录请求模型
struct GoogleSignInRequest: Codable {
    let operateDate: String
    let timeZone: String
    let idToken: String
    let accessToken: String
    let userID: String
    let email: String?
    let fullName: String?
    let givenName: String?
    let familyName: String?
    let deviceId: String?
    
    enum CodingKeys: String, CodingKey {
        case operateDate
        case timeZone
        case idToken = "id_token"
        case accessToken = "access_token"
        case userID = "user_id"
        case email
        case fullName = "full_name"
        case givenName = "given_name"
        case familyName = "family_name"
        case deviceId
    }
}

// MARK: - Google登录服务
@MainActor
class GoogleSignInService: NSObject, ObservableObject {
    static let shared = GoogleSignInService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private override init() {
        super.init()
        configureGoogleSignIn()
    }
    
    // MARK: - 配置Google登录
    private func configureGoogleSignIn() {
        // 首先尝试从GoogleService-Info.plist获取客户端ID
        var clientId: String?
        
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let googleClientId = plist["CLIENT_ID"] as? String {
            clientId = googleClientId
            print("✅ 从GoogleService-Info.plist获取客户端ID")
        } else if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path),
                  let infoClientId = plist["GIDClientID"] as? String {
            clientId = infoClientId
            print("✅ 从Info.plist获取客户端ID")
        }
        
        guard let validClientId = clientId else {
            print("❌ 无法获取Google客户端ID")
            print("请确保以下之一已配置:")
            print("1. GoogleService-Info.plist文件中的CLIENT_ID")
            print("2. Info.plist文件中的GIDClientID")
            return
        }
        
        let config = GIDConfiguration(clientID: validClientId)
        GIDSignIn.sharedInstance.configuration = config
        print("✅ Google登录配置成功，客户端ID: \(validClientId.prefix(20))...")
    }
    
    // MARK: - 开始Google登录流程
    func signInWithGoogle() async throws -> AuthResponse {
        print("🔍 开始Google登录流程")
        
        guard let presentingViewController = await getRootViewController() else {
            throw NetworkError.networkError("无法获取根视图控制器")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
                Task { @MainActor in
                    if let error = error {
                        print("❌ Google登录失败: \(error.localizedDescription)")
                        continuation.resume(throwing: NetworkError.networkError("Google登录失败: \(error.localizedDescription)"))
                        return
                    }
                    
                    guard let result = result else {
                        print("❌ Google登录结果为空")
                        continuation.resume(throwing: NetworkError.networkError("Google登录结果为空"))
                        return
                    }
                    
                    do {
                        let authResponse = try await self?.handleGoogleSignInResult(result)
                        continuation.resume(returning: authResponse ?? AuthResponse(success: false, message: "处理Google登录结果失败", data: nil, code: 500))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    // MARK: - 处理Google登录结果
    private func handleGoogleSignInResult(_ result: GIDSignInResult) async throws -> AuthResponse {
        let user = result.user
        
        print("🔍 Google登录用户信息:")
        print("   userID: \(user.userID ?? "nil")")
        print("   email: \(user.profile?.email ?? "nil")")
        print("   name: \(user.profile?.name ?? "nil")")
        
        guard let idToken = user.idToken?.tokenString else {
            throw NetworkError.networkError("无法获取Google ID Token")
        }
        
        let accessToken = user.accessToken.tokenString
        
        // 获取当前日期和时区信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier
        
        let googleSignInRequest = GoogleSignInRequest(
            operateDate: operateDate,
            timeZone: timeZone,
            idToken: idToken,
            accessToken: accessToken,
            userID: user.userID ?? "",
            email: user.profile?.email,
            fullName: user.profile?.name,
            givenName: user.profile?.givenName,
            familyName: user.profile?.familyName,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        )
        
        // 调用后端API验证Google登录
        return try await sendGoogleSignInToServer(googleSignInRequest)
    }
    
    // MARK: - 发送Google登录信息到服务器
    private func sendGoogleSignInToServer(_ request: GoogleSignInRequest) async throws -> AuthResponse {
        let baseURL = "http://ds2.tapgame.cn"
        
        let parameters: [String: Any] = [
            "idToken": request.idToken,
            "accessToken": request.accessToken,
            "userID": request.userID,
            "email": request.email ?? "",
            "fullName": request.fullName ?? "",
            "givenName": request.givenName ?? "",
            "familyName": request.familyName ?? "",
            "deviceId": request.deviceId ?? "",
            "operateDate": request.operateDate,
            "timeZone": request.timeZone
        ]
        
        do {
            print("🔍 发送Google登录请求到服务器...")
            print("   URL: \(baseURL)/app/user/login/google")
            print("   参数: \(parameters)")
            
            let googleResponse: AchievementLoginResponse = try await NetworkManager.shared.post(
                url: "\(baseURL)/app/user/login/google",
                parameters: parameters,
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ],
                responseType: AchievementLoginResponse.self
            )
            
            print("🔍 服务器响应解析成功:")
            print("   status: '\(googleResponse.status)'")
            print("   data存在: \(googleResponse.data != nil)")
            print("   code: '\(googleResponse.code)'")
            print("   message: '\(googleResponse.message)'")
            
            // 转换为AuthResponse格式
            let authResponse: AuthResponse
            
            if googleResponse.status == "success", let googleLoginData = googleResponse.data {
                print("✅ Google登录成功判断通过")
                
                // 将 AchievementUser 转换为 UserInfo
                let userInfo = UserInfo(
                    account: googleLoginData.user.account,
                    phone: googleLoginData.user.phone,
                    channel: Channel(
                        channelType: googleLoginData.user.channel.channelType,
                        description: googleLoginData.user.channel.description,
                        uuid: googleLoginData.user.channel.uuid
                    ),
                    nickname: googleLoginData.user.nickname ?? googleLoginData.user.account,
                    userSettings: UserSettings(
                        backgroundMusic: googleLoginData.user.userSettings.backgroundMusic
                    ),
                    uuid: googleLoginData.user.uuid,
                    userStuffs: [], // 简化处理
                    createTime: googleLoginData.user.createTime
                )
                
                let authData = AuthData(
                    token: googleLoginData.accessToken,
                    user: userInfo,
                    expiresIn: 3600
                )
                
                authResponse = AuthResponse(
                    success: true,
                    message: googleResponse.message.isEmpty ? "Google登录成功" : googleResponse.message,
                    data: authData,
                    code: 200
                )
                
                // 保存认证信息
                UserManager.shared.saveGoogleLoginData(googleLoginData, loginMethod: "google")
                
            } else {
                print("❌ Google登录成功判断失败:")
                print("   status == 'success': \(googleResponse.status == "success")")
                print("   data != nil: \(googleResponse.data != nil)")
                
                authResponse = AuthResponse(
                    success: false,
                    message: googleResponse.message.isEmpty ? "Google登录失败" : googleResponse.message,
                    data: nil,
                    code: Int(googleResponse.code) ?? 400
                )
            }
            
            return authResponse
            
        } catch NetworkError.serverError(let statusCode) {
            throw NetworkError.serverError(statusCode)
        } catch {
            throw error
        }
    }
    
    // MARK: - 获取根视图控制器
    private func getRootViewController() async -> UIViewController? {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first else {
            return nil
        }
        return await window.rootViewController
    }
    
    // MARK: - 登出Google账户
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        print("✅ Google账户已登出")
    }
}
