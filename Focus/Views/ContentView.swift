//
//  ContentView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        Group {
            if userManager.isLoggedIn {
                // 已登录，显示主界面
                CustomTabBarView()
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
    }
}

#Preview {
    ContentView()
}
