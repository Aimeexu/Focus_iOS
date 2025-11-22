//
//  NotificationManager.swift
//  Focus
//
//  Created by Kiro on 2025/11/22.
//

import Foundation
import UserNotifications

// MARK: - 本地通知管理器
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - 请求通知权限
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print(granted ? "✅ 通知权限已授予" : "❌ 通知权限被拒绝")
            return granted
        } catch {
            print("❌ 请求通知权限失败: \(error)")
            return false
        }
    }
    
    // MARK: - 处理前台通知显示
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 即使应用在前台也显示通知
        completionHandler([.banner, .sound, .badge])
        print("📬 前台显示通知")
    }
    
    // MARK: - 处理通知点击
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("👆 用户点击了通知")
        completionHandler()
    }
    
    // MARK: - 检查通知权限状态
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        print("📋 通知权限状态: \(settings.authorizationStatus.rawValue)")
        return settings.authorizationStatus
    }
    
    // MARK: - 发送专注完成通知
    func sendFocusCompletionNotification() {
        Task {
            let status = await checkAuthorizationStatus()
            
            guard status == .authorized || status == .provisional else {
                print("⚠️ 通知权限未授予，无法发送通知")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Focus"
            content.body = "A new pal has joined your collection!"
            content.sound = .default
            
            // 立即触发通知
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "focusCompletion", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ 发送通知失败: \(error)")
                } else {
                    print("✅ 通知已成功添加到通知中心")
                }
            }
        }
    }
    
    // MARK: - 取消所有待发送的通知
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ 已取消所有待发送的通知")
    }
    
    // MARK: - 测试通知（用于调试）
    func sendTestNotification() {
        Task {
            let status = await checkAuthorizationStatus()
            print("🧪 测试通知 - 权限状态: \(status.rawValue)")
            
            if status == .notDetermined {
                print("⚠️ 权限未确定，正在请求...")
                let granted = await requestAuthorization()
                if !granted {
                    print("❌ 用户拒绝了通知权限")
                    return
                }
            } else if status != .authorized && status != .provisional {
                print("❌ 通知权限未授予")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "测试通知"
            content.body = "如果你看到这条通知，说明通知功能正常工作！"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ 测试通知发送失败: \(error)")
                } else {
                    print("✅ 测试通知已发送")
                }
            }
        }
    }
}
