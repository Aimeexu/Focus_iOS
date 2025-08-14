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
    @State private var showMusicSelection = false
    @State private var selectedMusic: String = "music.note"
    @State private var showTimePicker = false
    @State private var selectedMinutes = 25

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 0) {

                    // 顶部音乐图标
                    Button(action: {
                        showMusicSelection = true
                    }) {
                        Image("noise")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .foregroundColor(AppColors.Semantic.darkBrown)
                    }
                    .padding(.top, 78)

                    // 位置标签
                    Button(action: {
                        showLocationSelection = true
                    }) {
                        HStack(spacing: 4) {
                            Image("home_label")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 36)

                            Text(selectedLocation)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(AppColors.Semantic.darkBrown)

                            Image("home_arrow")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .padding(.leading, -8)
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 8)
                    }
                    .padding(.top, 120)

                    // 计时器圆圈
                    Button(action: {
                        if !isTimerRunning {
                            showTimePicker = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.Semantic.beige)
                                .frame(width: 220, height: 220)

                            if isTimerRunning {
                                Circle()
                                    .stroke(AppColors.Brand.primary, lineWidth: 4)
                                    .frame(width: 220, height: 220)
                                    .opacity(0.3)
                            }

                            Text(timeString(from: focusTime))
                                .font(.system(size: 42, weight: .medium, design: .monospaced))
                                .foregroundColor(AppColors.Semantic.darkBrown)
                        }
                    }
                    .disabled(isTimerRunning)
                    .padding(.top, 32)

                    // Start to Focus 按钮
                    Button(action: {
                        toggleTimer()
                    }) {
                        Text(isTimerRunning ? "Stop Focus" : "Start to Focus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 66)
                            .background(isTimerRunning ? AppColors.Semantic.error : AppColors.Brand.primary)
                            .cornerRadius(20)
                            .scaleEffect(isTimerRunning ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isTimerRunning)
                    }
                    .padding(.horizontal, 90)
                    .padding(.top, 72)

                    // 增大底部空白
                    Spacer(minLength: 125)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(AppColors.Background.primary)
        .ignoresSafeArea(.keyboard) // 忽略键盘安全区域
        .overlay(
            // 弹窗层
            Group {
                // 标签选择弹窗
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
                
                // 音乐选择弹窗
                if showMusicSelection {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showMusicSelection = false
                        }
                    
                    MusicSelectionView(
                        isPresented: $showMusicSelection,
                        selectedMusic: $selectedMusic
                    )
                }
                
                // 时间选择弹窗
                if showTimePicker {
                    TimePickerView(
                        selectedMinutes: $selectedMinutes,
                        isPresented: $showTimePicker
                    )
                }
            }
        )
        .onDisappear {
            timer?.invalidate()
        }
        .onAppear {
            selectedMinutes = focusTime / 60
        }
        .onChange(of: showTimePicker) { _, isShowing in
            if !isShowing {
                // 时间选择器关闭时，更新focusTime
                focusTime = selectedMinutes * 60
            }
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
