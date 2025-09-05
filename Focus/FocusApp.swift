//
//  FocusApp.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

@main
struct FocusApp: App {
    @StateObject private var userManager = UserManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .onAppear {
                    // 应用启动时加载用户数据
                    userManager.loadUserData()
                }
        }
    }
}
