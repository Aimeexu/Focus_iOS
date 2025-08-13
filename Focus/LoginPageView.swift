//
//  LoginPageView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

// MARK: - 通知名称扩展
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}

struct LoginPageView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isLoggedIn = false
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("login_background") // 替换成你的背景图片名称
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                
                // 白色卡片容器
                VStack(spacing: 24) {
                    // Continue with Apple 按钮
                    Button(action: {
                        testLogin()
                    }) {
                        HStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Text(isLoading ? "登录中..." : "Continue with Apple")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.Semantic.darkBrown)
                        .cornerRadius(20)
                        .disabled(isLoading)
                    }
                    
                    // 错误信息显示
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Semantic.error)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 分隔线和"or"文字
                    HStack {
                        Rectangle()
                            .fill(AppColors.Brand.primary)
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Brand.primary)
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(AppColors.Brand.primary)
                            .frame(height: 1)
                    }
                    
                    // 社交登录按钮
                    HStack(spacing: 50) {
                        // Facebook按钮
                        Button(action: {
                            // Facebook登录逻辑
                        }) {
                            Image("facebook_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        }
                        
                        // Google按钮
                        Button(action: {
                            // Google登录逻辑
                        }) {
                            Image("google_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .shadow(color: AppColors.Neutral.gray100, radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(32)
                .background(AppColors.Background.card)
                .cornerRadius(25)
                .shadow(color: AppColors.Neutral.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
                .padding(.bottom, 80) // 给底部留出安全区域空间
            }
        }
        .onChange(of: isLoggedIn) { _, newValue in
            if newValue {
                // 登录成功，发送通知让ContentView刷新状态
                NotificationCenter.default.post(name: .userDidLogin, object: nil)
            }
        }
    }
    
    // MARK: - 测试登录方法
    private func testLogin() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 使用测试账号和密码
                let response = try await AuthService.shared.login(
                    account: "测试1", // 这里用email字段传account
                    password: "111"
                )
                
                await MainActor.run {
                    if response.success {
                        isLoggedIn = true
                        print("登录成功: \(response.message)")
                    } else {
                        errorMessage = response.message
                        print("登录失败: \(response.message)")
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "登录失败: \(error.localizedDescription)"
                    print("登录错误: \(error)")
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    LoginPageView()
}
