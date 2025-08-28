//
//  LoginPageView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI
import Lottie

// MARK: - 通知名称扩展
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}

// Lottie动画视图包装器
struct OwlLottieView: UIViewRepresentable {
    let animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        let animationView = LottieAnimationView(name: animationName)
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
        
        containerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 不需要更新
    }
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
                
                // 白色卡片容器和猫头鹰的组合
                ZStack {
                    // 猫头鹰动画 - 位于白色卡片右上方，图层在后面
                    OwlLottieView(animationName: "owl")
                        .frame(width: 160, height: 160)
                        .offset(x: 88, y: -100) // 向右上方移动更多

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
                                    .font(.appBody(size: 18))
                                    .foregroundColor(.white)
                            }
                            
                            Text(isLoading ? "登录中..." : "Continue with Apple")
                                .font(.appButton(size: 16))
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
                            .font(.appBody(size: 14))
                            .foregroundColor(AppColors.Semantic.error)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 分隔线和"or"文字
                    HStack {
                        Rectangle()
                            .fill(AppColors.Brand.primary)
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.appBody(size: 14))
                            .foregroundColor(AppColors.Brand.primary)
                            .padding(.horizontal, 4)
                        
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
                        }
                    }
                    }
                    .padding(32)
                    .background(AppColors.Background.card)
                    .cornerRadius(25)
                    .shadow(color: AppColors.Neutral.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
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
    
    // MARK: - 真实登录方法
    private func testLogin() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 使用测试账号和密码调用真实API
                let response = try await AuthService.shared.login(
                    account: "测试1",
                    password: "111"
                )
                
                await MainActor.run {
                    if response.success {
                        isLoggedIn = true
                        print("✅ 登录成功: \(response.message ?? "")")
                        
                        // 保存登录状态到本地
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        if let user = response.data?.user {
                            UserDefaults.standard.set(user.nickname, forKey: "username")
                        }
                    } else {
                        errorMessage = response.message ?? "登录失败"
                        print("❌ 登录失败: \(response.message ?? "未知错误")")
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "网络错误: \(error.localizedDescription)"
                    print("❌ 登录网络错误: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    LoginPageView()
}
