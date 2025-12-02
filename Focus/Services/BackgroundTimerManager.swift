//
//  BackgroundTimerManager.swift
//  Focus
//
//  Created by Kiro on 2025/10/23.
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - 后台计时管理器
@MainActor
class BackgroundTimerManager: ObservableObject {
    static let shared = BackgroundTimerManager()
    
    @Published var isTimerRunning = false
    @Published var isPaused = false
    @Published var remainingTime: Int = 0
    @Published var showCompletionMessage = false
    
    private var backgroundTime: Date?
    private var originalDuration: Int = 0
    private var timer: Timer?
    
    private init() {
        setupNotificationObservers()
    }
    
    // MARK: - 设置通知观察者
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    // MARK: - 开始计时
    func startTimer(duration: Int) {
        isTimerRunning = true
        remainingTime = duration
        originalDuration = duration
        showCompletionMessage = false
        
        startLocalTimer()
        print("⏰ 开始计时，时长: \(duration) 秒")
    }
    
    // MARK: - 暂停计时
    func pauseTimer() {
        guard isTimerRunning && !isPaused else { return }
        
        isPaused = true
        timer?.invalidate()
        timer = nil
        print("⏸️ 计时已暂停，剩余时间: \(remainingTime) 秒")
    }
    
    // MARK: - 恢复计时
    func resumeTimer() {
        guard isTimerRunning && isPaused else { return }
        
        isPaused = false
        startLocalTimer()
        print("▶️ 计时已恢复，剩余时间: \(remainingTime) 秒")
    }
    
    // MARK: - 停止计时
    func stopTimer() {
        isTimerRunning = false
        isPaused = false
        remainingTime = 0
        backgroundTime = nil
        timer?.invalidate()
        timer = nil
        showCompletionMessage = false
        
        // 取消所有待发送的通知
        cancelScheduledNotification()
        
        print("⏹️ 计时已停止")
    }
    
    // MARK: - 启动本地计时器
    private func startLocalTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    // 计时结束
                    self.handleTimerCompletion()
                }
            }
        }
    }
    
    // MARK: - 处理计时完成
    private func handleTimerCompletion() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        showCompletionMessage = true
        
        print("✅ 计时完成")
        
        // 触发声音反馈（如果设置已启用）
        playCompletionSound()
        
        // 触发震动反馈（如果设置已启用）
        triggerHapticFeedback()
        
        // 发送本地通知
        NotificationManager.shared.sendFocusCompletionNotification()

        // 通知外部计时完成
        NotificationCenter.default.post(name: .timerCompleted, object: nil)

        // 2秒后隐藏完成消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showCompletionMessage = false
        }
    }
    
    // MARK: - 播放完成声音
    private func playCompletionSound() {
        let isSoundEnabled = UserDefaults.standard.bool(forKey: "endOfFocusSounds")
        
        if isSoundEnabled {
            // 播放本地音效文件 success.mp3
            AudioManager.shared.playSoundEffect(fileName: "success")
            print("🔔 播放完成提示音")
        } else {
            print("🔇 声音反馈已禁用")
        }
    }
    
    // MARK: - 触发震动反馈
    private func triggerHapticFeedback() {
        let isHapticsEnabled = UserDefaults.standard.bool(forKey: "endOfFocusHaptics")
        
        if isHapticsEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            print("📳 触发震动反馈")
        } else {
            print("🔇 震动反馈已禁用")
        }
    }
    
    // MARK: - 应用进入后台
    @objc private func appDidEnterBackground() {
        guard isTimerRunning else { return }
        
        backgroundTime = Date()
        timer?.invalidate()
        timer = nil
        
        print("📱 应用进入后台，记录时间: \(backgroundTime!)")
        print("   剩余时间: \(remainingTime) 秒")
        
        // 安排本地通知，在剩余时间后触发
        scheduleCompletionNotification(after: TimeInterval(remainingTime))
    }
    
    // MARK: - 应用回到前台
    @objc private func appWillEnterForeground() {
        guard isTimerRunning, let backgroundTime = backgroundTime else { return }
        
        // 取消之前安排的通知（因为App已回到前台）
        cancelScheduledNotification()
        
        let foregroundTime = Date()
        let backgroundDuration = Int(foregroundTime.timeIntervalSince(backgroundTime))
        
        print("📱 应用回到前台")
        print("   后台时长: \(backgroundDuration) 秒")
        print("   之前剩余时间: \(remainingTime) 秒")
        
        // 计算新的剩余时间
        let newRemainingTime = remainingTime - backgroundDuration
        
        if newRemainingTime <= 0 {
            // 计时已经结束
            remainingTime = 0
            showCompletionMessage = true
            
            print("⏰ 计时在后台已完成，显示完成消息")
            
            // 触发声音反馈（如果设置已启用）
            playCompletionSound()
            
            // 触发震动反馈（如果设置已启用）
            triggerHapticFeedback()
            
            // 2秒后隐藏完成消息并执行完成逻辑
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showCompletionMessage = false
                self.isTimerRunning = false
                // 通知外部计时完成
                NotificationCenter.default.post(name: .timerCompletedInBackground, object: nil)
            }
        } else {
            // 更新剩余时间并继续计时
            remainingTime = newRemainingTime
            startLocalTimer()
            
            print("⏰ 继续计时，新的剩余时间: \(remainingTime) 秒")
        }
        
        // 清除后台时间记录
        self.backgroundTime = nil
    }
    
    // MARK: - 格式化时间显示
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    // MARK: - 获取进度百分比
    func progressPercentage() -> Double {
        guard originalDuration > 0 else { return 0 }
        let elapsed = originalDuration - remainingTime
        return Double(elapsed) / Double(originalDuration)
    }
    
    // MARK: - 安排完成通知
    private func scheduleCompletionNotification(after timeInterval: TimeInterval) {
        // 先取消之前的通知
        cancelScheduledNotification()
        
        Task {
            let status = await NotificationManager.shared.checkAuthorizationStatus()
            
            guard status == .authorized || status == .provisional else {
                print("⚠️ 通知权限未授予，无法安排后台通知")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Focus"
            content.body = "A new pal has joined your collection!"
            content.sound = .default
            content.badge = 1
            
            // 设置触发时间
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(
                identifier: "focusCompletionScheduled",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ 安排后台通知失败: \(error)")
                } else {
                    print("✅ 后台通知已安排，将在 \(timeInterval) 秒后触发")
                }
            }
        }
    }
    
    // MARK: - 取消安排的通知
    private nonisolated func cancelScheduledNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["focusCompletionScheduled"]
        )
        print("🗑️ 已取消安排的后台通知")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        cancelScheduledNotification()
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let timerCompletedInBackground = Notification.Name("timerCompletedInBackground")
    static let timerCompleted = Notification.Name("timerCompleted")
}
