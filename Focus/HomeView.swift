//
//  HomeView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct HomeView: View {
    @State private var focusTime = 25 * 60 // 25分钟
    @State private var isTimerRunning = false
    @State private var selectedLocation = "Gym"
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 状态栏区域
                HStack {
                    Text("9:41")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        // 信号图标
                        Image(systemName: "cellularbars")
                            .font(.system(size: 16, weight: .medium))
                        // WiFi图标
                        Image(systemName: "wifi")
                            .font(.system(size: 16, weight: .medium))
                        // 电池图标
                        Image(systemName: "battery.100")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // 主内容区域
                VStack(spacing: 0) {
                    Spacer(minLength: 60)
                    
                    // 顶部音乐图标
                    Image(systemName: "music.note")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.brown)
                    
                    Spacer(minLength: 80)
                    
                    // 位置标签
                    Button(action: {
                        // 选择位置逻辑
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                            Text(selectedLocation)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // 计时器圆圈
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5).opacity(0.8))
                            .frame(width: 220, height: 220)
                        
                        // 进度圆环（如果需要的话）
                        if isTimerRunning {
                            Circle()
                                .stroke(Color.green, lineWidth: 4)
                                .frame(width: 220, height: 220)
                                .opacity(0.3)
                        }
                        
                        Text(timeString(from: focusTime))
                            .font(.system(size: 42, weight: .medium, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer(minLength: 60)
                    
                    // Start to Focus 按钮
                    Button(action: {
                        toggleTimer()
                    }) {
                        Text(isTimerRunning ? "Stop Focus" : "Start to Focus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isTimerRunning ? Color.red : Color.green)
                            .cornerRadius(28)
                            .scaleEffect(isTimerRunning ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isTimerRunning)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .background(Color(.systemBackground))
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func toggleTimer() {
        isTimerRunning.toggle()
        
        if isTimerRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if focusTime > 0 {
                focusTime -= 1
            } else {
                stopTimer()
                // 计时结束逻辑
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    HomeView()
}