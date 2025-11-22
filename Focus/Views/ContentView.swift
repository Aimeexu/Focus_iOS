//
//  ContentView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    var speed: CGFloat = 1.0   // 加这个
    var onComplete: (() -> Void)?

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed   // 设置速度

        animationView.play { finished in
            if finished { onComplete?() }
        }

        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) { }
}

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var isActive = false

    var body: some View {
        Group {
            if userManager.isLoggedIn {
                // 已登录，显示主界面
                ZStack {
                    if isActive {
                        // ✅ 主页面
                        CustomTabBarView()
                    } else {
                        // ✅ 启动画面
                        ZStack {
                            Image("launch")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()

                            LottieView(name: "loading", loopMode: .playOnce)
                                .aspectRatio(contentMode: .fill)
                                .ignoresSafeArea()
                        }
                        .onAppear {
                            // 动画时长后切换主页面
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                isActive = true
                            }
                        }
                    }
                }
            } else {
                // 未登录，显示登录页面
                LoginPageView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { _ in
            // 通知登录成功，重新加载用户数据
            userManager.loadUserData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            // 通知登出，清除用户数据但保留个人设置
            userManager.clearUserDataExceptSettings()
        }
        .onReceive(NotificationCenter.default.publisher(for: .tokenRefreshFailed)) { _ in
            // Token续期失败，强制用户重新登录
            print("🔄 收到Token续期失败通知，强制用户重新登录")
            userManager.logout()
        }
    }
}

#Preview {
    ContentView()
}
