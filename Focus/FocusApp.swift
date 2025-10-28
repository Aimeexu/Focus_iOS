//
//  FocusApp.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI
import FBSDKCoreKit
import GoogleSignIn
import Bugly

@main
struct FocusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        @StateObject private var userManager = UserManager.shared

    init() {
        // 初始化Google Sign-In
        configureGoogleSignIn()
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
                    let facebookHandled = ApplicationDelegate.shared.application(
                        UIApplication.shared,
                        open: url,
                        sourceApplication: nil,
                        annotation: [UIApplication.OpenURLOptionsKey.annotation]
                    )
                    
                    // 处理Google登录回调
                    let googleHandled = GIDSignIn.sharedInstance.handle(url)
                    
                    // 如果两个都没有处理，可以添加其他URL处理逻辑
                    if !facebookHandled && !googleHandled {
                        print("⚠️ URL未被任何登录服务处理: \(url)")
                    }
                }
        }
    }
    
    // MARK: - 配置Google Sign-In
    private func configureGoogleSignIn() {
        // 首先尝试从GoogleService-Info.plist获取客户端ID
        var clientId: String?
        
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let googleClientId = plist["CLIENT_ID"] as? String {
            clientId = googleClientId
            print("✅ 从GoogleService-Info.plist获取客户端ID")
        } else if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path),
                  let infoClientId = plist["GIDClientID"] as? String {
            clientId = infoClientId
            print("✅ 从Info.plist获取客户端ID")
        }
        
        guard let validClientId = clientId else {
            print("❌ 无法获取Google客户端ID")
            print("请确保以下之一已配置:")
            print("1. GoogleService-Info.plist文件中的CLIENT_ID")
            print("2. Info.plist文件中的GIDClientID")
            return
        }
        
        let config = GIDConfiguration(clientID: validClientId)
        GIDSignIn.sharedInstance.configuration = config
        print("✅ Google Sign-In配置成功，客户端ID: \(validClientId.prefix(20))...")
    }
}

// ✅ 把 Bugly 和 Facebook 的初始化放在 AppDelegate 里
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // 初始化 Facebook SDK
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // 初始化 Bugly（尽量放最前）
        BuglyLog.initLogger(BuglyLogLevel.info, consolePrint: true )
        Bugly.start(withAppId: "f498a348d2")

        return true
    }
}
