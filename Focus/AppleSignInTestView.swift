//
//  AppleSignInTestView.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import SwiftUI

struct AppleSignInTestView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var userInfo: UserInfo?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Apple登录测试")
                .font(.largeTitle)
                .padding()
            
            // Apple登录按钮
            CustomAppleSignInButton(
                action: testAppleSignIn,
                isLoading: isLoading
            )
            .padding(.horizontal)
            
            // 错误信息
            if let errorMessage = errorMessage {
                Text("错误: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            // 成功信息
            if let successMessage = successMessage {
                Text("成功: \(successMessage)")
                    .foregroundColor(.green)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            // 用户信息显示
            if let userInfo = userInfo {
                VStack(alignment: .leading, spacing: 8) {
                    Text("用户信息:")
                        .font(.headline)
                    
                    Text("昵称: \(userInfo.nickname)")
                    Text("账户: \(userInfo.account)")
                    Text("UUID: \(userInfo.uuid)")
                    
                    if let phone = userInfo.phone {
                        Text("电话: \(phone)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            // 清除按钮
            Button("清除信息") {
                clearInfo()
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
    
    private func testAppleSignIn() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        userInfo = nil
        
        Task {
            do {
                let response = try await AppleSignInService.shared.signInWithApple()
                
                await MainActor.run {
                    if response.success {
                        successMessage = response.message
                        userInfo = response.data?.user
                        print("✅ Apple登录测试成功")
                    } else {
                        errorMessage = response.message
                        print("❌ Apple登录测试失败: \(response.message)")
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    print("❌ Apple登录测试错误: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
    
    private func clearInfo() {
        errorMessage = nil
        successMessage = nil
        userInfo = nil
        AuthService.shared.clearAuthData()
    }
}

#Preview {
    AppleSignInTestView()
}