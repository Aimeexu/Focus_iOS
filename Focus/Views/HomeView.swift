//
//  HomeView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI
import AVFoundation
import Lottie
import Foundation

// Slide to Quit 按钮组件
struct SlideToQuitButton: View {
    let action: () -> Void
    @State private var dragOffset: CGFloat = 0
    @State private var isSliding = false
    
    private let buttonHeight: CGFloat = 66
    private let slideThreshold: CGFloat = 200
    
    var body: some View {
        ZStack {
            // 背景轨道
            RoundedRectangle(cornerRadius: 33)
                .fill(AppColors.Brand.primary)
                .frame(height: buttonHeight)
            
            // 滑动按钮
            HStack {
                ZStack {
                    Circle()
                        .fill(AppColors.Semantic.beige)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "arrow.right")
                            .font(.appButton(size: 20))
                        .foregroundColor(AppColors.Semantic.darkBrown)
                }
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = max(0, min(slideThreshold, value.translation.width))
                            dragOffset = translation
                            isSliding = translation > 0
                        }
                        .onEnded { value in
                            if dragOffset >= slideThreshold {
                                // 滑动完成，执行退出操作
                                action()
                            }
                            
                            // 重置位置
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                                isSliding = false
                            }
                        }
                )
                
                Spacer()
            }
            .padding(.horizontal, 8)
            
            // 文字
            Text("Slide to Quit")
                    .font(.appButton(size: 18))
                .foregroundColor(.white)
                .opacity(isSliding ? 0.5 : 1.0)
        }
    }
}

// 猫头鹰Lottie动画视图包装器
struct OwlAnimationView: UIViewRepresentable {
    let animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        let animationView = LottieAnimationView(name: animationName)
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
        
        containerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 不需要更新
    }
}

struct HomeView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var focusTime = 25 * 60 // 25分钟
    @State private var selectedLocation = ""
    @State private var showLocationSelection = false
    @State private var showMusicSelection = false
    @State private var selectedMusic = ""
    @State private var showTimePicker = false
    @State private var selectedMinutes = 25
    @State private var isStartingTimer = false

    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var concentrationService = ConcentrationService.shared
    @StateObject private var lottieAnimationManager = LottieAnimationManager.shared
    @StateObject private var backgroundTimerManager = BackgroundTimerManager.shared
    @State private var step: Int = -1

    var body: some View {
        GeometryReader { geometry in

            // 计时器显示区域
            if step == 0 {
                VStack(spacing: 40) {
                    LottieView(name: "switch", loopMode: .playOnce, speed: 0.6) {
                        step = 1
                    }
                        .aspectRatio(contentMode: .fill)
                }
            } else if step == 1 {
                ZStack() {
                    LottieView(name: "prepare", loopMode: .loop) {
                    }
                    .frame(width: 220, height: 220)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.45
                    )
                    LottieView(name: "take_breath", loopMode: .playOnce) {
                         step = 2    // 播完 B，进入 C
                    }
                    .frame(width: 200, height: 200)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.7
                    )
                }

            } else if step == 2 {
                LottieView(name: "switch", loopMode: .playOnce , speed: 0.6) {
                    step = 3
                }
            } else if step == 3 {
                toggleTimer()
                // 显示小动物
                ConcentrationAnimationView(size: CGSize(width: geometry.size.width, height: geometry.size.height), showStateIndicator: false)
                if backgroundTimerManager.isTimerRunning {
                    Text(backgroundTimerManager.timeString(from: backgroundTimerManager.remainingTime))
                        .font(.appNumber(size: 24))
                        .foregroundColor(AppColors.Semantic.darkBrown)
                }
            } else {
                ZStack {
                    VStack {
                        // 未运行时显示大圆形Start按钮
                        Button(action: {
                            step = 0
                        }) {
                            LottieView(name: "start", loopMode: .loop)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 160, height: 160)
                                .position(x: geometry.size.width / 2,   // 水平方向居中
                                          y: geometry.size.height / 2 - 40) // 距离中心向下 100pt
                        }
                        .disabled(isStartingTimer)
                    }

                    HStack(spacing: 60) {
                        // 时间选择
                        Button(action: {
                            showTimePicker = true
                        }) {
                            VStack(spacing: 8) {
                                Image("home_time")
                                    .font(.system(size: 36))

                                Text(backgroundTimerManager.timeString(from: focusTime))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppColors.Semantic.darkBrown)
                            }
                        }

                        // 位置选择
                        Button(action: {
                            showLocationSelection = true
                        }) {
                            VStack(spacing: 8) {
                                Image("home_label")
                                    .font(.system(size: 36))

                                Text(selectedLocation.isEmpty ? "Location" : selectedLocation)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppColors.Semantic.darkBrown)
                            }
                        }

                        // 音乐选择
                        Button(action: {
                            showMusicSelection = true
                        }) {
                            VStack(spacing: 8) {
                                Image("home_noise")
                                    .font(.system(size: 36))

                                Text(selectedMusic == "silent" || selectedMusic.isEmpty ? "off" : "on")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppColors.Semantic.darkBrown)
                            }
                        }
                    }
                    .position(x: geometry.size.width / 2,   // 水平方向居中
                              y: geometry.size.height / 2 + 120) // 距离中心向下 100pt
                    .disabled(isStartingTimer)

                }.frame(maxWidth: .infinity, maxHeight: .infinity)

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
        .onChange(of: showTimePicker) { _, isShowing in
            if !isShowing {
                // 时间选择器关闭时，更新focusTime
                focusTime = selectedMinutes * 60
            }
        }
        .onChange(of: selectedMusic) { _, newMusic in
            // 使用 UserManager 保存选中的音乐
            userManager.updateSelectedMusic(newMusic)
            // 立即播放新选择的音乐
            let audioManager = AudioManager.shared
            if let fileName = getAudioFileName(for: newMusic) {
                audioManager.playSound(fileName: fileName)
            } else {
                audioManager.stopSound() // 如果选择静音，停止播放
            }
        }
        .onChange(of: selectedLocation) { _, newLocation in
            // 使用 UserManager 保存选中的位置
            userManager.updateSelectedLocation(newLocation)
        }
        .onChange(of: selectedMinutes) { _, newMinutes in
            // 使用 UserManager 保存选中的时间
            userManager.updateSelectedMinutes(newMinutes)
        }
        .onAppear {
            // 从 UserManager 加载用户偏好设置
            selectedLocation = userManager.getSelectedLocation()
            selectedMusic = userManager.getSelectedMusic()
            selectedMinutes = userManager.getSelectedMinutes()
            focusTime = selectedMinutes * 60
        }
        .onReceive(NotificationCenter.default.publisher(for: .timerCompletedInBackground)) { _ in
            // 处理后台计时完成
            handleBackgroundTimerCompletion()
        }
        .onReceive(NotificationCenter.default.publisher(for: .timerCompleted)) { _ in
            // 处理后台计时完成
            handleBackgroundTimerCompletion()
        }
    }

    private func toggleTimer() {
        if backgroundTimerManager.isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        // 检查用户是否已登录
        guard userManager.isLoggedIn else {
            print("❌ 用户未登录，无法开始专注计时")
            return
        }
        
        isStartingTimer = true
        
        Task {
            do {
                // 使用新的专注计时服务，它会自动获取物品列表并找到对应的动画
                let (plan, animationURL) = try await concentrationService.startConcentrationWithAnimation(
                    duration: selectedMinutes,
                    concentrationPlanTag: selectedLocation
                )
                
                await MainActor.run {
                    // 专注计划信息已经在ConcentrationService中保存
                    
                    // 如果有动画URL，加载动画
                    if let animationURL = animationURL {
                        Task {
                            await lottieAnimationManager.loadAnimation(from: animationURL)
                        }
                    }
                    
                    // 使用BackgroundTimerManager开始计时
                    let durationInSeconds = selectedMinutes * 60
                    backgroundTimerManager.startTimer(duration: durationInSeconds)
                    focusTime = durationInSeconds
                    isStartingTimer = false
                    
                    print("✅ 专注计时开始成功")
                    print("   计划ID: \(plan.uuid)")
                    print("   状态: \(plan.status)")
                    print("   开始时间: \(plan.startDate)")
                    if let stuffId = concentrationService.currentStuffId {
                        print("   奖励物品ID: \(stuffId)")
                    }
                    if let animationURL = animationURL {
                        print("   动画URL: \(animationURL)")
                    }
                }
            } catch {
                await MainActor.run {
                    isStartingTimer = false
                    print("❌ 开始专注计时失败: \(error.localizedDescription)")
                    // 这里可以显示错误提示给用户
                }
            }
        }
    }
    private func stopTimer() {
        // 停止BackgroundTimerManager的计时
        backgroundTimerManager.stopTimer()
        
        // 手动停止时，只清理本地状态，不调用结束接口
        manualStopConcentration()
    }
    
    private func manualStopConcentration() {
        // 手动停止专注计时，只清理本地状态，不调用服务器结束接口
        Task {
            await MainActor.run {
                // 重置计时器时间
                focusTime = selectedMinutes * 60
                
                // 清除动画
                lottieAnimationManager.clearAnimation()
                
                // 只清理本地状态，不调用API
                concentrationService.manualStop()
                
                print("🛑 手动停止专注计时（未调用结束接口）")
            }
        }
    }
    
    private func naturalEndConcentrationSession() {
        // 计时器自然结束，调用结束接口获取奖励
        guard concentrationService.currentPlan != nil else {
            return
        }
        
        Task {
            // 先调用结束接口，但不清除动画状态
            await concentrationService.safeEndConcentrationWithoutClearingAnimation()
            
            await MainActor.run {
                // 重置计时器时间
                focusTime = selectedMinutes * 60
                
                print("✅ 专注计时自然结束，已获取奖励")
                
                // 延迟2秒后再清除动画，让用户有时间看到成年动画
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.concentrationService.clearState()
                    print("🧹 延迟清除动画状态")
                }
            }
        }
    }

    private func handleBackgroundTimerCompletion() {
        // 后台计时完成，先切换到成体动画，然后调用结束接口
        print("🎯 计时完成，切换到成年动画")
        concentrationService.switchToAdultAnimation()

        // 延迟5秒显示成体动画，然后结束计时（给用户更多时间看到成年动画）
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            print("🎯 成年动画显示完毕，结束专注计时")
            naturalEndConcentrationSession()
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func restoreBackgroundMusic() {
        // 根据选中的音乐图标恢复播放
        let audioManager = AudioManager.shared
        
        // 如果当前没有播放音乐，且选择的不是静音，则开始播放
        if !audioManager.isPlaying && selectedMusic != "silent" {
            let fileName = getAudioFileName(for: selectedMusic)
            if let fileName = fileName {
                audioManager.playSound(fileName: fileName)
            }
        }
    }
    
    private func getAudioFileName(for icon: String) -> String? {
        switch icon {
        case "rain":
            return "rain_sound"
        case "river":
            return "wave_sound"
        case "jungle":
            return "forest_sound"
        case "sea":
            return "wind_sound"
        case "silent":
            return nil
        default:
            return nil
        }
    }
}

#Preview {
    HomeView()
}
