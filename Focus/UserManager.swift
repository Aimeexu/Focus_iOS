//
//  UserManager.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import Foundation
import SwiftUI

// MARK: - 用户信息管理器
class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var isLoggedIn = false
    @Published var currentUser: UserInfo?
    
    private init() {
        loadUserData()
    }
    
    // MARK: - UserDefaults Keys
    private struct Keys {
        // 认证相关
        static let authToken = "auth_token"
        static let refreshToken = "refresh_token"
        static let accessTokenName = "access_token_name"
        static let tokenExpiration = "token_expiration"
        
        // 用户基本信息
        static let userInfo = "user_info"
        static let userUUID = "user_uuid"
        static let userAccount = "user_account"
        static let userNickname = "user_nickname"
        static let userPhone = "user_phone"
        static let userCreateTime = "user_create_time"
        
        // 频道信息
        static let channelUUID = "channel_uuid"
        static let channelType = "channel_type"
        static let channelDescription = "channel_description"
        
        // 用户设置
        static let backgroundMusic = "background_music"
        static let selectedLocation = "selected_location"
        static let selectedMusic = "selected_music"
        static let selectedMinutes = "selected_minutes"
        
        // 用户物品
        static let userStuffs = "user_stuffs"
        
        // 登录状态
        static let isLoggedIn = "is_logged_in"
        static let lastLoginDate = "last_login_date"
        static let loginMethod = "login_method" // "apple" 或 "email"
    }
    
    // MARK: - 保存登录信息
    func saveLoginData(_ authData: AuthData, loginMethod: String = "email") {
        let userDefaults = UserDefaults.standard
        
        // 保存认证信息
        userDefaults.set(authData.token, forKey: Keys.authToken)
        
        if let expiresIn = authData.expiresIn {
            let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
            userDefaults.set(expirationDate, forKey: Keys.tokenExpiration)
        }
        
        // 保存用户基本信息
        let user = authData.user
        userDefaults.set(user.uuid, forKey: Keys.userUUID)
        userDefaults.set(user.account, forKey: Keys.userAccount)
        userDefaults.set(user.nickname, forKey: Keys.userNickname)
        userDefaults.set(user.phone, forKey: Keys.userPhone)
        userDefaults.set(user.createTime, forKey: Keys.userCreateTime)
        
        // 保存频道信息
        userDefaults.set(user.channel.uuid, forKey: Keys.channelUUID)
        userDefaults.set(user.channel.channelType, forKey: Keys.channelType)
        userDefaults.set(user.channel.description, forKey: Keys.channelDescription)
        
        // 保存用户设置
        userDefaults.set(user.userSettings.backgroundMusic, forKey: Keys.backgroundMusic)
        
        // 保存用户物品信息
        if let userStuffsData = try? JSONEncoder().encode(user.userStuffs) {
            userDefaults.set(userStuffsData, forKey: Keys.userStuffs)
        }
        
        // 保存完整的用户信息对象
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: Keys.userInfo)
        }
        
        // 保存登录状态和方式
        userDefaults.set(true, forKey: Keys.isLoggedIn)
        userDefaults.set(Date(), forKey: Keys.lastLoginDate)
        userDefaults.set(loginMethod, forKey: Keys.loginMethod)
        
        // 更新内存中的状态
        DispatchQueue.main.async {
            self.currentUser = user
            self.isLoggedIn = true
        }
        
        print("✅ 用户登录信息已保存到 UserDefaults")
        printSavedUserInfo()
    }
    
    // MARK: - 保存Apple登录信息
    func saveAppleLoginData(_ appleLoginData: AppleLoginData, loginMethod: String = "apple") {
        let userDefaults = UserDefaults.standard
        
        // 保存认证信息
        userDefaults.set(appleLoginData.accessToken, forKey: Keys.authToken)
        userDefaults.set(appleLoginData.refreshToken, forKey: Keys.refreshToken)
        userDefaults.set(appleLoginData.accessTokenName, forKey: Keys.accessTokenName)
        
        // 设置默认过期时间（1小时）
        let expirationDate = Date().addingTimeInterval(3600)
        userDefaults.set(expirationDate, forKey: Keys.tokenExpiration)
        
        // 保存用户基本信息
        let user = appleLoginData.user
        userDefaults.set(user.uuid, forKey: Keys.userUUID)
        userDefaults.set(user.account, forKey: Keys.userAccount)
        userDefaults.set(user.nickname ?? user.account, forKey: Keys.userNickname)
        userDefaults.set(user.phone, forKey: Keys.userPhone)
        userDefaults.set(user.createTime, forKey: Keys.userCreateTime)
        
        // 保存频道信息
        userDefaults.set(user.channel.uuid, forKey: Keys.channelUUID)
        userDefaults.set(user.channel.channelType, forKey: Keys.channelType)
        userDefaults.set(user.channel.description, forKey: Keys.channelDescription)
        
        // 保存用户设置
        userDefaults.set(user.userSettings.backgroundMusic, forKey: Keys.backgroundMusic)
        
        // 转换Apple用户物品为标准格式并保存
        let standardUserStuffs = user.userStuffs.allUserStuffs.map { appleStuff in
            UserStuff(
                amount: appleStuff.amount,
                createTime: appleStuff.createTime ?? "",
                userStuffBaseId: appleStuff.userStuffBaseId,
                updateTime: appleStuff.updateTime ?? ""
            )
        }
        
        if let userStuffsData = try? JSONEncoder().encode(standardUserStuffs) {
            userDefaults.set(userStuffsData, forKey: Keys.userStuffs)
        }
        
        // 转换为标准UserInfo格式并保存
        let standardUserInfo = UserInfo(
            account: user.account,
            phone: user.phone,
            channel: Channel(
                channelType: user.channel.channelType,
                description: user.channel.description,
                uuid: user.channel.uuid
            ),
            nickname: user.nickname ?? user.account,
            userSettings: UserSettings(
                backgroundMusic: user.userSettings.backgroundMusic
            ),
            uuid: user.uuid,
            userStuffs: standardUserStuffs,
            createTime: user.createTime
        )
        
        if let userData = try? JSONEncoder().encode(standardUserInfo) {
            userDefaults.set(userData, forKey: Keys.userInfo)
        }
        
        // 保存登录状态和方式
        userDefaults.set(true, forKey: Keys.isLoggedIn)
        userDefaults.set(Date(), forKey: Keys.lastLoginDate)
        userDefaults.set(loginMethod, forKey: Keys.loginMethod)
        
        // 更新内存中的状态
        DispatchQueue.main.async {
            self.currentUser = standardUserInfo
            self.isLoggedIn = true
        }
        
        print("✅ Apple登录信息已保存到 UserDefaults")
        printSavedUserInfo()
    }
    
    // MARK: - 加载用户数据
    func loadUserData() {
        let userDefaults = UserDefaults.standard
        
        // 检查登录状态
        let savedIsLoggedIn = userDefaults.bool(forKey: Keys.isLoggedIn)
        
        // 检查token是否过期
        var tokenValid = false
        if let expirationDate = userDefaults.object(forKey: Keys.tokenExpiration) as? Date {
            tokenValid = Date() < expirationDate
        }
        
        // 如果已登录且token有效，加载用户信息
        if savedIsLoggedIn && tokenValid {
            if let userData = userDefaults.data(forKey: Keys.userInfo),
               let user = try? JSONDecoder().decode(UserInfo.self, from: userData) {
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isLoggedIn = true
                }
                print("✅ 从 UserDefaults 加载用户信息成功")
            } else {
                // 如果无法加载完整用户信息，尝试从单独字段重建
                reconstructUserInfo()
            }
        } else {
            // 登录状态无效，清除数据
            if !tokenValid {
                print("⚠️ Token已过期，清除登录状态")
            }
            clearUserData()
        }
    }
    
    // MARK: - 重建用户信息
    private func reconstructUserInfo() {
        let userDefaults = UserDefaults.standard
        
        guard let uuid = userDefaults.string(forKey: Keys.userUUID),
              let account = userDefaults.string(forKey: Keys.userAccount) else {
            print("❌ 无法重建用户信息，缺少必要字段")
            clearUserData()
            return
        }
        
        // 重建频道信息
        let channel = Channel(
            channelType: userDefaults.string(forKey: Keys.channelType),
            description: userDefaults.string(forKey: Keys.channelDescription) ?? "",
            uuid: userDefaults.string(forKey: Keys.channelUUID) ?? ""
        )
        
        // 重建用户设置
        let userSettings = UserSettings(
            backgroundMusic: userDefaults.string(forKey: Keys.backgroundMusic) ?? "default"
        )
        
        // 重建用户物品
        var userStuffs: [UserStuff] = []
        if let userStuffsData = userDefaults.data(forKey: Keys.userStuffs),
           let stuffs = try? JSONDecoder().decode([UserStuff].self, from: userStuffsData) {
            userStuffs = stuffs
        }
        
        // 重建用户信息
        let userInfo = UserInfo(
            account: account,
            phone: userDefaults.string(forKey: Keys.userPhone),
            channel: channel,
            nickname: userDefaults.string(forKey: Keys.userNickname) ?? account,
            userSettings: userSettings,
            uuid: uuid,
            userStuffs: userStuffs,
            createTime: userDefaults.object(forKey: Keys.userCreateTime) as? Int64 ?? 0
        )
        
        DispatchQueue.main.async {
            self.currentUser = userInfo
            self.isLoggedIn = true
        }
        
        print("✅ 用户信息重建成功")
    }
    
    // MARK: - 获取用户信息
    func getUserUUID() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userUUID)
    }
    
    func getUserAccount() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userAccount)
    }
    
    func getUserNickname() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userNickname)
    }
    
    func getUserPhone() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userPhone)
    }
    
    func getBackgroundMusic() -> String {
        return UserDefaults.standard.string(forKey: Keys.backgroundMusic) ?? "default"
    }
    
    func getSelectedLocation() -> String {
        return UserDefaults.standard.string(forKey: Keys.selectedLocation) ?? "Read"
    }
    
    func getSelectedMusic() -> String {
        return UserDefaults.standard.string(forKey: Keys.selectedMusic) ?? "silent"
    }
    
    func getSelectedMinutes() -> Int {
        return UserDefaults.standard.object(forKey: Keys.selectedMinutes) as? Int ?? 25
    }
    
    func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: Keys.authToken)
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: Keys.refreshToken)
    }
    
    func getAccessTokenName() -> String? {
        return UserDefaults.standard.string(forKey: Keys.accessTokenName)
    }
    
    func getLoginMethod() -> String? {
        return UserDefaults.standard.string(forKey: Keys.loginMethod)
    }
    
    func getLastLoginDate() -> Date? {
        return UserDefaults.standard.object(forKey: Keys.lastLoginDate) as? Date
    }
    
    func getUserStuffs() -> [UserStuff] {
        guard let userStuffsData = UserDefaults.standard.data(forKey: Keys.userStuffs),
              let stuffs = try? JSONDecoder().decode([UserStuff].self, from: userStuffsData) else {
            return []
        }
        return stuffs
    }
    
    // MARK: - 更新用户信息
    func updateUserNickname(_ nickname: String) {
        UserDefaults.standard.set(nickname, forKey: Keys.userNickname)
        
        // 更新内存中的用户信息
        if var user = currentUser {
            user = UserInfo(
                account: user.account,
                phone: user.phone,
                channel: user.channel,
                nickname: nickname,
                userSettings: user.userSettings,
                uuid: user.uuid,
                userStuffs: user.userStuffs,
                createTime: user.createTime
            )
            
            // 保存更新后的完整用户信息
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: Keys.userInfo)
            }
            
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }
    }
    
    func updateBackgroundMusic(_ music: String) {
        UserDefaults.standard.set(music, forKey: Keys.backgroundMusic)
        
        // 更新内存中的用户信息
        if var user = currentUser {
            let updatedSettings = UserSettings(backgroundMusic: music)
            user = UserInfo(
                account: user.account,
                phone: user.phone,
                channel: user.channel,
                nickname: user.nickname,
                userSettings: updatedSettings,
                uuid: user.uuid,
                userStuffs: user.userStuffs,
                createTime: user.createTime
            )
            
            // 保存更新后的完整用户信息
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: Keys.userInfo)
            }
            
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }
    }
    
    func updateSelectedLocation(_ location: String) {
        UserDefaults.standard.set(location, forKey: Keys.selectedLocation)
    }
    
    func updateSelectedMusic(_ music: String) {
        UserDefaults.standard.set(music, forKey: Keys.selectedMusic)
    }
    
    func updateSelectedMinutes(_ minutes: Int) {
        UserDefaults.standard.set(minutes, forKey: Keys.selectedMinutes)
    }
    
    func updateUserStuffs(_ stuffs: [UserStuff]) {
        if let userStuffsData = try? JSONEncoder().encode(stuffs) {
            UserDefaults.standard.set(userStuffsData, forKey: Keys.userStuffs)
        }
        
        // 更新内存中的用户信息
        if var user = currentUser {
            user = UserInfo(
                account: user.account,
                phone: user.phone,
                channel: user.channel,
                nickname: user.nickname,
                userSettings: user.userSettings,
                uuid: user.uuid,
                userStuffs: stuffs,
                createTime: user.createTime
            )
            
            // 保存更新后的完整用户信息
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: Keys.userInfo)
            }
            
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }
    }
    
    // MARK: - 清除用户数据
    func clearUserData() {
        let userDefaults = UserDefaults.standard
        
        // 清除所有用户相关数据
        let keysToRemove = [
            Keys.authToken, Keys.refreshToken, Keys.accessTokenName, Keys.tokenExpiration,
            Keys.userInfo, Keys.userUUID, Keys.userAccount, Keys.userNickname, Keys.userPhone, Keys.userCreateTime,
            Keys.channelUUID, Keys.channelType, Keys.channelDescription,
            Keys.backgroundMusic, Keys.selectedLocation, Keys.selectedMusic, Keys.selectedMinutes, Keys.userStuffs,
            Keys.isLoggedIn, Keys.lastLoginDate, Keys.loginMethod
        ]
        
        for key in keysToRemove {
            userDefaults.removeObject(forKey: key)
        }
        
        // 更新内存中的状态
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn = false
        }
        
        print("✅ 用户数据已清除")
    }
    
    // MARK: - 检查登录状态
    func checkLoginStatus() -> Bool {
        let userDefaults = UserDefaults.standard
        let savedIsLoggedIn = userDefaults.bool(forKey: Keys.isLoggedIn)
        
        // 检查token是否过期
        if let expirationDate = userDefaults.object(forKey: Keys.tokenExpiration) as? Date {
            let tokenValid = Date() < expirationDate
            return savedIsLoggedIn && tokenValid
        }
        
        return false
    }
    
    // MARK: - 获取认证Cookie信息
    func getAuthCookie() -> (name: String, value: String)? {
        guard let tokenName = getAccessTokenName(),
              let tokenValue = getAuthToken() else {
            return nil
        }
        return (name: tokenName, value: tokenValue)
    }
    
    // MARK: - 调试方法
    private func printSavedUserInfo() {
        print("📊 已保存的用户信息:")
        print("   UUID: \(getUserUUID() ?? "nil")")
        print("   账号: \(getUserAccount() ?? "nil")")
        print("   昵称: \(getUserNickname() ?? "nil")")
        print("   手机: \(getUserPhone() ?? "nil")")
        print("   背景音乐: \(getBackgroundMusic())")
        print("   登录方式: \(getLoginMethod() ?? "nil")")
        print("   最后登录: \(getLastLoginDate()?.description ?? "nil")")
        print("   用户物品数量: \(getUserStuffs().count)")
        print("   Token存在: \(getAuthToken() != nil)")
        print("   RefreshToken存在: \(getRefreshToken() != nil)")
    }
    
    func printAllUserDefaults() {
        print("🔍 所有用户相关的 UserDefaults 数据:")
        let userDefaults = UserDefaults.standard
        
        let allKeys = [
            Keys.authToken, Keys.refreshToken, Keys.accessTokenName, Keys.tokenExpiration,
            Keys.userInfo, Keys.userUUID, Keys.userAccount, Keys.userNickname, Keys.userPhone, Keys.userCreateTime,
            Keys.channelUUID, Keys.channelType, Keys.channelDescription,
            Keys.backgroundMusic, Keys.selectedLocation, Keys.selectedMusic, Keys.selectedMinutes, Keys.userStuffs,
            Keys.isLoggedIn, Keys.lastLoginDate, Keys.loginMethod
        ]
        
        for key in allKeys {
            let value = userDefaults.object(forKey: key)
            if key.contains("token") || key.contains("Token") {
                // 对于token类型的数据，只显示是否存在
                print("   \(key): \(value != nil ? "[已设置]" : "[未设置]")")
            } else {
                print("   \(key): \(value ?? "[未设置]")")
            }
        }
    }
}

// MARK: - AuthService 扩展，集成 UserManager
extension AuthService {
    func saveAuthData(_ authData: AuthData) {
        // 使用 UserManager 保存数据
        UserManager.shared.saveLoginData(authData, loginMethod: "email")
    }
    
    func getCurrentUser() -> UserInfo? {
        return UserManager.shared.currentUser
    }
    
    func isLoggedIn() -> Bool {
        return UserManager.shared.checkLoginStatus()
    }
    
    func getAuthToken() -> String? {
        return UserManager.shared.getAuthToken()
    }
    
    func clearAuthData() {
        UserManager.shared.clearUserData()
    }
    
    func getAuthCookie() -> (name: String, value: String)? {
        return UserManager.shared.getAuthCookie()
    }
}

// MARK: - AppleSignInService 扩展，集成 UserManager
extension AppleSignInService {
    func saveAppleAuthData(_ appleLoginData: AppleLoginData) {
        UserManager.shared.saveAppleLoginData(appleLoginData, loginMethod: "apple")
    }
}