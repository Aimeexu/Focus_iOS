//
//  DebugCookie.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/28.
//

import Foundation

// 调试Cookie功能
class DebugCookie {
    static func printCurrentCookieInfo() {
        print("🔍 当前Cookie调试信息:")
        
        let tokenName = UserDefaults.standard.string(forKey: "access_token_name")
        let tokenValue = UserDefaults.standard.string(forKey: "auth_token")
        
        print("存储的 access_token_name: \(tokenName ?? "nil")")
        print("存储的 auth_token: \(tokenValue ?? "nil")")
        
        if let authCookie = AuthService.shared.getAuthCookie() {
            print("✅ Cookie获取成功:")
            print("  名称: \(authCookie.name)")
            print("  值: \(authCookie.value)")
            print("  完整Cookie: \(authCookie.name)=\(authCookie.value)")
        } else {
            print("❌ Cookie获取失败")
        }
        
        print("登录状态: \(AuthService.shared.isLoggedIn())")
    }
    
    static func simulateConcentrationRequest() async {
        print("🧪 模拟专注计时请求...")
        
        // 打印当前Cookie信息
        printCurrentCookieInfo()
        
        // 手动构建Cookie进行测试
        if let authCookie = AuthService.shared.getAuthCookie() {
            let cookies = [authCookie.name: authCookie.value]
            print("准备发送的Cookie: \(cookies)")
            
            // 这里可以添加实际的网络请求测试
            do {
                let response = try await NetworkManager.shared.startConcentration(duration: 25)
                print("✅ 请求成功: \(response.status)")
            } catch {
                print("❌ 请求失败: \(error)")
            }
        }
    }
}