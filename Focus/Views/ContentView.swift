//
//  ContentView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false // 测试

    var body: some View {
        Group {
            if isLoggedIn {
                // 已登录，显示主界面
                CustomTabBarView()
            } else {
                // 未登录，显示登录页面
                LoginPageView()
            }
        }
        .onAppear {
            checkLoginStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { _ in
            isLoggedIn = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            isLoggedIn = false
        }
    }
    
    private func checkLoginStatus() {
        // 检查用户是否已经登录（使用UserDefaults模拟）
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        print("检查登录状态: \(isLoggedIn)")
    }
}

#Preview {
    ContentView()
}
