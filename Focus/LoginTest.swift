//
//  LoginTest.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/28.
//

import Foundation

// 测试登录功能
class LoginTest {
    static func testLogin() async {
        print("🧪 开始测试登录功能...")
        
        do {
            let response = try await AuthService.shared.login(
                account: "test@example.com",
                password: "testpassword"
            )
            
            if response.success {
                print("✅ 登录测试成功")
                print("Token: \(response.data?.token ?? "无token")")
                print("用户名: \(response.data?.user.nickname ?? "无用户名")")
            } else {
                print("❌ 登录测试失败: \(response.message ?? "未知错误")")
            }
        } catch {
            print("❌ 登录测试网络错误: \(error.localizedDescription)")
        }
    }
}