//
//  AnimationSwitchTestView.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import SwiftUI

struct AnimationSwitchTestView: View {
    @StateObject private var concentrationService = ConcentrationService.shared
    @StateObject private var lottieAnimationManager = LottieAnimationManager.shared
    @State private var testDuration = 5 // 5秒用于测试
    @State private var remainingTime = 5
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var showingAdultAnimation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("动画切换测试")
                    .font(.title)
                    .padding()
                
                // 动画显示区域
                VStack {
                    Text("当前状态: \(concentrationService.currentAnimationState.displayName)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    if showingAdultAnimation {
                        Text("🎉 完成奖励动画")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    ConcentrationAnimationView(
                        size: CGSize(width: 250, height: 250),
                        showStateIndicator: true
                    )
                    .border(Color.gray.opacity(0.3), width: 1)
                }
                
                // 倒计时显示
                if isRunning {
                    VStack {
                        Text("剩余时间")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(remainingTime)")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                }
                
                // 控制按钮
                VStack(spacing: 12) {
                    if !isRunning {
                        Button("开始测试 (5秒倒计时)") {
                            startTest()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(concentrationService.isLoading)
                    } else {
                        Button("停止测试") {
                            stopTest()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                    
                    // 手动切换按钮
                    HStack(spacing: 12) {
                        Button("切换到幼体") {
                            concentrationService.switchToChildAnimation()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isRunning)
                        
                        Button("切换到成体") {
                            concentrationService.switchToAdultAnimation()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isRunning)
                        
                        Button("切换到睡眠") {
                            concentrationService.switchToSleepAnimation()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isRunning)
                    }
                    
                    HStack(spacing: 12) {
                        Button("清除动画") {
                            concentrationService.clearState()
                            lottieAnimationManager.clearAnimation()
                            showingAdultAnimation = false
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.orange)
                        
                        Button("检查状态") {
                            concentrationService.printCurrentState()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                    }
                }
                
                // 详细状态信息
                VStack(alignment: .leading, spacing: 8) {
                    if concentrationService.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("加载中...")
                                .font(.caption)
                        }
                    }
                    
                    if let stuffId = concentrationService.currentStuffId {
                        Text("物品ID: \(stuffId)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let animationURL = concentrationService.currentLottieAnimationURL {
                        Text("动画URL: \(animationURL)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if let attachment = concentrationService.currentStuffAttachment {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("可用动画:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if attachment.child != nil {
                                Text("✅ 幼体动画")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                            
                            if attachment.adult != nil {
                                Text("✅ 成体动画")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                            
                            if attachment.sleep != nil {
                                Text("✅ 睡眠动画")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    if let errorMessage = concentrationService.errorMessage {
                        Text("错误: \(errorMessage)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("动画切换测试")
        }
    }
    
    private func startTest() {
        // 模拟开始专注计时
        Task {
            do {
                // 使用测试时长
                let (_, animationURL) = try await concentrationService.startConcentrationWithAnimation(duration: testDuration)
                
                await MainActor.run {
                    if let animationURL = animationURL {
                        Task {
                            await lottieAnimationManager.loadAnimation(from: animationURL)
                        }
                    }
                    
                    // 开始倒计时
                    isRunning = true
                    remainingTime = testDuration
                    showingAdultAnimation = false
                    
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        if remainingTime > 0 {
                            remainingTime -= 1
                        } else {
                            // 时间到了，切换到成体动画
                            print("⏰ 时间到！切换到成体动画")
                            concentrationService.switchToAdultAnimation()
                            showingAdultAnimation = true
                            
                            // 3秒后结束测试
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                stopTest()
                            }
                        }
                    }
                }
            } catch {
                print("❌ 测试开始失败: \(error)")
            }
        }
    }
    
    private func stopTest() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingTime = testDuration
        showingAdultAnimation = false
        
        // 清理状态
        Task {
            await concentrationService.safeEndConcentration()
        }
    }
    

}

#Preview {
    AnimationSwitchTestView()
}