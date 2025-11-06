//
//  TokenManager.swift
//  Focus
//
//  Created by Kiro on 2025/11/6.
//

import Foundation

// MARK: - Token续期响应模型
struct TokenRefreshResponse: Codable {
    let status: String
    let data: TokenRefreshData?
    let code: String
    let message: String
    let errors: String?
}

struct TokenRefreshData: Codable {
    let accessToken: String
    let refreshToken: String
    let accessTokenName: String
}

// MARK: - Token管理器
class TokenManager {
    static let shared = TokenManager()
    
    private init() {}
    
    // MARK: - UserDefaults Keys
    private struct Keys {
        static let tokenSaveTime = "token_save_time"
        static let lastRefreshTime = "last_refresh_time"
    }
    
    // 24小时的时间间隔（秒）
    private let tokenRefreshInterval: TimeInterval = 24 * 60 * 60

    // MARK: - 保存Token时间
    func saveTokenTime() {
        let currentTime = Date()
        UserDefaults.standard.set(currentTime, forKey: Keys.tokenSaveTime)
        UserDefaults.standard.set(currentTime, forKey: Keys.lastRefreshTime)
        print("✅ Token保存时间已记录: \(currentTime)")
    }
    
    // MARK: - 检查是否需要续期Token
    func shouldRefreshToken() -> Bool {
        guard let tokenSaveTime = UserDefaults.standard.object(forKey: Keys.tokenSaveTime) as? Date else {
            print("⚠️ 未找到Token保存时间，需要续期")
            return true
        }
        
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(tokenSaveTime)
        
        print("🕐 Token保存时间: \(tokenSaveTime)")
        print("🕐 当前时间: \(currentTime)")
        print("⏱️ 时间间隔: \(timeInterval)秒 (约\(timeInterval/3600)小时)")
        
        if timeInterval >= tokenRefreshInterval {
            print("⚠️ Token已超过24小时，需要续期")
            return true
        } else {
            print("✅ Token仍在有效期内")
            return false
        }
    }
    
    // MARK: - 续期Token
    func refreshToken() async throws -> Bool {
        print("🔄 开始续期Token...")
        
        guard let refreshToken = UserManager.shared.getRefreshToken() else {
            print("❌ 未找到refreshToken")
            throw NetworkError.networkError("未找到refreshToken")
        }
        
        guard let accessToken = UserManager.shared.getAuthToken() else {
            print("❌ 未找到accessToken")
            throw NetworkError.networkError("未找到accessToken")
        }
        
        let baseURL = "http://ds2.tapgame.cn"
        let endpoint = "/app/user/renew"
        let url = baseURL + endpoint
        
        // 获取当前日期和时区信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier
        
        let parameters: [String: Any] = [
            "operateDate": operateDate,
            "timeZone": timeZone,
            "accessToken": accessToken,
            "refreshToken": refreshToken
        ]
        
        print("🔄 续期Token请求参数:")
        print("   operateDate: \(operateDate)")
        print("   timeZone: \(timeZone)")
        print("   accessToken: \(accessToken.prefix(10))...")
        print("   refreshToken: \(refreshToken.prefix(10))...")
        
        do {
            let response: TokenRefreshResponse = try await NetworkManager.shared.post(
                url: url,
                parameters: parameters,
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ],
                responseType: TokenRefreshResponse.self
            )
            
            if response.status == "success", let tokenData = response.data {
                // 更新Token信息
                updateTokens(
                    accessToken: tokenData.accessToken,
                    refreshToken: tokenData.refreshToken,
                    accessTokenName: tokenData.accessTokenName
                )
                
                print("✅ Token续期成功")
                return true
            } else {
                print("❌ Token续期失败: \(response.message)")
                throw NetworkError.serverError(Int(response.code) ?? 400)
            }
            
        } catch {
            print("❌ Token续期请求失败: \(error)")
            throw error
        }
    }
    
    // MARK: - 更新Token信息
    private func updateTokens(accessToken: String, refreshToken: String, accessTokenName: String) {
        let userDefaults = UserDefaults.standard
        
        // 更新Token
        userDefaults.set(accessToken, forKey: UserManager.Keys.authToken)
        userDefaults.set(refreshToken, forKey: UserManager.Keys.refreshToken)
        userDefaults.set(accessTokenName, forKey: UserManager.Keys.accessTokenName)
        
        // 更新过期时间（默认1小时）
        let expirationDate = Date().addingTimeInterval(3600)
        userDefaults.set(expirationDate, forKey: UserManager.Keys.tokenExpiration)
        
        // 更新Token保存时间
        saveTokenTime()
        
        print("✅ Token信息已更新")
    }
    
    // MARK: - 检查Token过期错误并自动续期
    func handleTokenExpiredError() async throws -> Bool {
        print("🔄 检测到Token过期，尝试自动续期...")
        
        do {
            let success = try await refreshToken()
            if success {
                print("✅ Token自动续期成功")
                return true
            } else {
                print("❌ Token自动续期失败")
                return false
            }
        } catch {
            print("❌ Token自动续期异常: \(error)")
            throw error
        }
    }
    
    // MARK: - 应用启动时检查Token
    func checkTokenOnAppLaunch() async {
        print("🚀 应用启动，检查Token状态...")
        
        // 检查用户是否有登录记录（不检查Token是否过期）
        let userDefaults = UserDefaults.standard
        let hasLoginRecord = userDefaults.bool(forKey: UserManager.Keys.isLoggedIn)
        let hasTokens = UserManager.shared.getAuthToken() != nil && UserManager.shared.getRefreshToken() != nil
        
        guard hasLoginRecord && hasTokens else {
            print("ℹ️ 用户未登录或缺少Token，跳过Token检查")
            return
        }
        
        print("📊 用户已登录，检查Token状态...")
        
        // 检查Token是否过期或需要续期
        let tokenExpired = checkTokenExpired()
        let shouldRefreshByTime = shouldRefreshToken()
        
        if tokenExpired || shouldRefreshByTime {
            let reason = tokenExpired ? "Token已过期" : "超过24小时"
            print("🔄 \(reason)，开始续期Token...")
            
            do {
                let success = try await refreshToken()
                if success {
                    print("✅ 应用启动时Token续期成功")
                    
                    // 发送续期成功通知
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .tokenRefreshSuccess, object: nil)
                    }
                } else {
                    print("❌ 应用启动时Token续期失败")
                    handleTokenRefreshFailure()
                }
            } catch {
                print("❌ 应用启动时Token续期异常: \(error)")
                handleTokenRefreshFailure()
            }
        } else {
            print("✅ Token状态正常，无需续期")
        }
    }
    
    // MARK: - 检查Token是否过期
    private func checkTokenExpired() -> Bool {
        guard let expirationDate = UserDefaults.standard.object(forKey: UserManager.Keys.tokenExpiration) as? Date else {
            print("⚠️ 未找到Token过期时间，视为已过期")
            return true
        }
        
        let isExpired = Date() >= expirationDate
        if isExpired {
            print("⚠️ Token已过期，过期时间: \(expirationDate)")
        } else {
            let remainingTime = expirationDate.timeIntervalSinceNow
            print("✅ Token未过期，剩余时间: \(remainingTime/60)分钟")
        }
        
        return isExpired
    }
    
    // MARK: - 处理Token续期失败
    private func handleTokenRefreshFailure() {
        print("⚠️ Token续期失败，清除登录状态")
        
        // 清除登录状态但保留个人设置
        UserManager.shared.clearUserDataExceptSettings()
        
        // 发送通知让UI更新
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .tokenRefreshFailed, object: nil)
        }
        
        print("📢 已发送Token续期失败通知，UI应该引导用户重新登录")
    }
    
    // MARK: - 获取最后续期时间
    func getLastRefreshTime() -> Date? {
        return UserDefaults.standard.object(forKey: Keys.lastRefreshTime) as? Date
    }
    
    // MARK: - 获取Token保存时间
    func getTokenSaveTime() -> Date? {
        return UserDefaults.standard.object(forKey: Keys.tokenSaveTime) as? Date
    }
    
    // MARK: - 清除Token时间记录
    func clearTokenTimes() {
        UserDefaults.standard.removeObject(forKey: Keys.tokenSaveTime)
        UserDefaults.standard.removeObject(forKey: Keys.lastRefreshTime)
        print("✅ Token时间记录已清除")
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let tokenRefreshFailed = Notification.Name("tokenRefreshFailed")
    static let tokenRefreshSuccess = Notification.Name("tokenRefreshSuccess")
}

// MARK: - NetworkManager扩展 - 自动处理Token过期
extension NetworkManager {
    
    /// 带自动Token续期的请求方法
    func requestWithAutoRefresh<T: Codable>(
        url: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil,
        responseType: T.Type,
        maxRetries: Int = 1
    ) async throws -> T {
        
        var currentRetries = 0
        
        while currentRetries <= maxRetries {
            do {
                // 尝试正常请求
                return try await request(
                    url: url,
                    method: method,
                    parameters: parameters,
                    headers: headers,
                    cookies: cookies,
                    responseType: responseType
                )
                
            } catch NetworkError.serverError(let statusCode) {
                // 检查是否是Token过期错误（通常是401或403）
                if (statusCode == 401 || statusCode == 403) && currentRetries < maxRetries {
                    print("🔄 检测到Token过期错误(状态码: \(statusCode))，尝试续期...")
                    
                    do {
                        let refreshSuccess = try await TokenManager.shared.handleTokenExpiredError()
                        if refreshSuccess {
                            print("✅ Token续期成功，重试请求...")
                            currentRetries += 1
                            continue // 重试请求
                        } else {
                            print("❌ Token续期失败")
                            throw NetworkError.serverError(statusCode)
                        }
                    } catch {
                        print("❌ Token续期异常: \(error)")
                        throw error
                    }
                } else {
                    throw NetworkError.serverError(statusCode)
                }
                
            } catch {
                throw error
            }
        }
        
        throw NetworkError.networkError("请求重试次数已达上限")
    }
    
    /// 带自动Token续期的GET请求
    func getWithAutoRefresh<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await requestWithAutoRefresh(
            url: url,
            method: .GET,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: responseType
        )
    }
    
    /// 带自动Token续期的POST请求
    func postWithAutoRefresh<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        cookies: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await requestWithAutoRefresh(
            url: url,
            method: .POST,
            parameters: parameters,
            headers: headers,
            cookies: cookies,
            responseType: responseType
        )
    }
}
