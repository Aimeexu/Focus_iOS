//
//  LoginPageView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI
import Lottie
import AuthenticationServices

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
    @State private var isFacebookLoading = false
    @State private var isGoogleLoading = false
    @State private var errorMessage: String?
    @State private var isLoggedIn = false
    @StateObject private var appleSignInService = AppleSignInService.shared
    @StateObject private var facebookSignInService = FacebookSignInService.shared
    @StateObject private var googleSignInService = GoogleSignInService.shared

    @State private var isActive = false

    var body: some View {
        ZStack {
            Image("launch")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LottieView(name: "loading", loopMode: .playOnce)
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            if isActive {
                
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
                            CustomAppleSignInButton(
                                action: signInWithApple,
                                isLoading: isLoading
                            )
                            
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
                                FacebookIconButton(
                                    action: signInWithFacebook,
                                    isLoading: isFacebookLoading
                                )
                                
                                // Google按钮
                                GoogleIconButton(
                                    action: signInWithGoogle,
                                    isLoading: isGoogleLoading
                                )
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
                .transition(.opacity)

            }
        }
        .onAppear() {
            // 动画时长后切换主页面
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // 页面加载完后，让它淡入
                withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                    isActive = true
                }
            }
        }
        .onChange(of: isLoggedIn) { _, newValue in
            if newValue {
                // 登录成功，发送通知让ContentView刷新状态
                NotificationCenter.default.post(name: .userDidLogin, object: nil)
            }
        }
    }
    
    // MARK: - Apple登录方法
    private func signInWithApple() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await AppleSignInService.shared.signInWithApple()
                
                await MainActor.run {
                    if response.success {
                        isLoggedIn = true
                        print("✅ Apple登录成功: \(response.message)")
                        
                        // 登录状态已由 UserManager 自动处理
                        // 发送登录成功通知
                        NotificationCenter.default.post(name: .userDidLogin, object: nil)
                    } else {
                        errorMessage = response.message
                        print("❌ Apple登录失败: \(response.message)")
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Apple登录错误: \(error.localizedDescription)"
                    print("❌ Apple登录网络错误: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Facebook登录方法
    private func signInWithFacebook() {
        isFacebookLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await FacebookSignInService.shared.signInWithFacebook()
                
                await MainActor.run {
                    if response.success {
                        isLoggedIn = true
                        print("✅ Facebook登录成功: \(response.message)")
                        
                        // 登录状态已由 UserManager 自动处理
                        // 发送登录成功通知
                        NotificationCenter.default.post(name: .userDidLogin, object: nil)
                    } else {
                        errorMessage = response.message
                        print("❌ Facebook登录失败: \(response.message)")
                    }
                    isFacebookLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Facebook登录错误: \(error.localizedDescription)"
                    print("❌ Facebook登录网络错误: \(error.localizedDescription)")
                    isFacebookLoading = false
                }
            }
        }
    }
    
    // MARK: - Google登录方法
    private func signInWithGoogle() {
        isGoogleLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await GoogleSignInService.shared.signInWithGoogle()
                
                await MainActor.run {
                    if response.success {
                        isLoggedIn = true
                        print("✅ Google登录成功: \(response.message)")
                        
                        // 登录状态已由 UserManager 自动处理
                        // 发送登录成功通知
                        NotificationCenter.default.post(name: .userDidLogin, object: nil)
                    } else {
                        errorMessage = response.message
                        print("❌ Google登录失败: \(response.message)")
                    }
                    isGoogleLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Google登录错误: \(error.localizedDescription)"
                    print("❌ Google登录网络错误: \(error.localizedDescription)")
                    isGoogleLoading = false
                }
            }
        }
    }
    
    // MARK: - 测试登录方法（保留用于调试）
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
                        print("✅ 登录成功: \(response.message)")
                        
                        // 登录状态已由 UserManager 自动处理
                        // 发送登录成功通知
                        NotificationCenter.default.post(name: .userDidLogin, object: nil)
                    } else {
                        errorMessage = response.message
                        print("❌ 登录失败: \(response.message)")
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
