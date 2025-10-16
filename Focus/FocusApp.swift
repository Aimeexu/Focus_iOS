//
//  FocusApp.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI
import FBSDKCoreKit

@main
struct FocusApp: App {
    @StateObject private var userManager = UserManager.shared
    
    init() {
        // 初始化Facebook SDK
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .onAppear {
                    // 应用启动时加载用户数据
                    userManager.loadUserData()
                }
                .onOpenURL { url in
                    // 处理Facebook登录回调
                    ApplicationDelegate.shared.application(
                        UIApplication.shared,
                        open: url,
                        sourceApplication: nil,
                        annotation: [UIApplication.OpenURLOptionsKey.annotation]
                    )
                }
        }
    }
}
