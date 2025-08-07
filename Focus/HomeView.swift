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
    @State private var showLocationSelection = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 0) {

                    // 顶部音乐图标
                    Image(systemName: "music.note")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.brown)
                        .padding(.top, 34)

                    // 位置标签
                    Button(action: {
                        showLocationSelection = true
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
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    }
                    .padding(.top, 100)

                    // 计时器圆圈
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5).opacity(0.8))
                            .frame(width: 230, height: 230)

                        Circle()
                            .fill(Color(.systemGray5).opacity(1))
                            .frame(width: 210, height: 210)

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
                    .padding(.top, 40)

                    // Start to Focus 按钮
                    Button(action: {
                        toggleTimer()
                    }) {
                        Text(isTimerRunning ? "Stop Focus" : "Start to Focus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(minWidth: 206)
                            .frame(height: 60)
                            .background(isTimerRunning ? Color.red : Color.green)
                            .cornerRadius(20)
                            .scaleEffect(isTimerRunning ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isTimerRunning)
                    }
                    .padding(.top, 60)

                    // 增大底部空白
                    Spacer(minLength: 100)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            // 标签选择弹窗
            Group {
                if showLocationSelection {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showLocationSelection = false
                        }
                    
                    LocationSelectionView(
                        selectedLocation: $selectedLocation,
                        isPresented: $showLocationSelection
                    )
                }
            }
        )
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
