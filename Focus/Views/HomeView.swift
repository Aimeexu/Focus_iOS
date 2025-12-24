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

struct HomeView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
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
    @State private var showExitHint: Bool = false
    @State private var showExitConfirmation: Bool = false
    @State private var animationStateBeforePause: PetState = .child
    @State private var isTimerBlinking: Bool = true
    @State private var blinkTimer: Timer?
    @State private var pausedTimeSnapshot: Int = 0
    @State private var isComplete: Bool = false
    @State private var adultIsComplete: Bool = false
    @State private var showShareView: Bool = false
    @State private var currentAchievement: Achievement?

    @ViewBuilder
    private var mainContent: some View {
        GeometryReader { geometry in
            if step == 0 {
                VStack(spacing: 40) {
                    LottieView(name: "switch", loopMode: .playOnce, speed: 1) {
                        step = 1
                    }
                    .aspectRatio(contentMode: .fill)
                }
            } else if step == 1 {
                ZStack {

                    LottieView(name: "take_breath", loopMode: .playOnce, speed: 1.5) {
                        step = 2
                    }
                    .frame(width: 230, height: 230)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.7)

                    LottieView(name: "prepare", loopMode: .loop) {}
                        .frame(width: 260, height: 260)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.45)

                }
            } else if step == 2 {
                LottieView(name: "switch", loopMode: .playOnce, speed: 1) {
                    step = 3
                }
            } else if step == 3 {
                timerRunningView(geometry: geometry)
                    .transition(.opacity)
            } else if step == 4 {
                pausedView(geometry: geometry)
                    .transition(.opacity)
            } else {
                idleView(geometry: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func timerRunningView(geometry: GeometryProxy) -> some View {
        ZStack {
            // 场景背景图片
            if let sceneBackground = getSceneBackgroundImage() {
                Image(sceneBackground)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            // 背景动画（添加单击和长按手势）
            ConcentrationAnimationView(
                size: CGSize(width: geometry.size.width, height: geometry.size.height),
                showStateIndicator: false
            )
            .contentShape(Rectangle())
            .onTapGesture {
                // 只有在非成年状态时才允许单击进入暂停状态
                if !isComplete {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        pauseTimer()
                        step = 4
                    }
                } else {
                    // 开始动画
                    handleBackgroundTimerCompletion()
                    adultIsComplete = true
                }
            }
            .onLongPressGesture(minimumDuration: 1.0) {
                showExitConfirmation = true
            }
            
            // 顶部导航栏
            VStack {
                HStack {
                    // 左上角：声音设置按钮
                    Button(action: {
                        showMusicSelection = true
                    }) {
                        Image(selectedMusic.isEmpty ? "home_noise_fill" : selectedMusic + "_fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                    }
                    
                    Spacer()
                    
                    // 中间：倒计时显示
                    Text(backgroundTimerManager.timeString(from: backgroundTimerManager.remainingTime))
                        .font(.appNumber(size: 32))
                        .foregroundColor(AppColors.Semantic.darkBrown)
                    
                    Spacer()
                    
                    // 右上角：退出按钮
                    Button(action: {
                        showExitHint = true
                    }) {
                        Image("EXIT") // 确保图像资源名正确
                            .resizable()  // 设置可调整大小
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, geometry.safeAreaInsets.top + 50)

                Spacer()
            }
            
            // 退出提示动画（屏幕中下方）
            if showExitHint {
                VStack {
                    Spacer()
                    LottieView(name: "press_and_hold", loopMode: .playOnce) {
                        showExitHint = false
                    }
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 100)
                }
            }

            // 完成动画（屏幕中下方）
            if isComplete && !adultIsComplete {
                VStack {
                    Spacer()
                    Image("complete")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 280, height: 120)
                        .padding(.bottom, 100)
                }
            }

            if adultIsComplete {
                VStack {
                    Spacer()

                    HStack(spacing: 10) {
                        Button(action: {
                            // share
                            showShareView = true
                        }) {
                            Text("Go share")
                                .font(.appEmphasis())
                                .foregroundColor(.white)
                                .frame(width: 168, height: 66)
                                .background(AppColors.Brand.primary)
                                .cornerRadius(18)
                        }

                        Button(action: {
                            // home
                            showExitConfirmation = false
                            showExitHint = false
                            stopTimer()
                            step = -1
                            isComplete = false
                            adultIsComplete = false
                        }) {
                            Text("Home")
                                .font(.appEmphasis())
                                .foregroundColor(.white)
                                .frame(width: 118, height: 66)
                                .background(AppColors.Neutral.gray100)
                                .cornerRadius(18)
                        }
                    }
                    .frame(height: 66)
                    .padding(.bottom, 120)
                }
            }

            // 退出确认对话框
            if showExitConfirmation {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showExitConfirmation = false
                    }
                
                VStack(spacing: 20) {
                    Text("Are you sure you want to quit?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.Semantic.darkBrown)
                    
                    Text("You will not receive any rewards after quitting.")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.Semantic.darkBrown.opacity(0.7))
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            showExitConfirmation = false
                        }) {
                            Text("Cancel")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppColors.Semantic.darkBrown)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.Background.primary)
                                .cornerRadius(25)
                        }
                        
                        Button(action: {
                            showExitConfirmation = false
                            showExitHint = false
                            stopTimer()
                            step = -1
                            isComplete = false
                            adultIsComplete = false
                        }) {
                            Text("OK")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.Brand.primary)
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(30)
                .background(AppColors.Background.primary)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 40)
            }
        }
    }
    
    @ViewBuilder
    private func pausedView(geometry: GeometryProxy) -> some View {
        ZStack {
            // 纯色背景
            AppColors.Background.primary
                .ignoresSafeArea()
            
            // 显示睡眠动画
            ConcentrationAnimationView(
                size: CGSize(width: geometry.size.width, height: geometry.size.height),
                showStateIndicator: false
            )
            .contentShape(Rectangle())
            .onTapGesture {
                // 点击继续，回到 step 3，使用动画
                withAnimation(.easeInOut(duration: 0.5)) {
                    resumeTimer()
                    step = 3
                }
            }
            
            // 顶部倒计时（闪动效果）
            VStack {
                HStack {
                    Spacer()
                    
                    // 中间：倒计时显示（闪动）- 使用暂停时的固定时间
                    Text(backgroundTimerManager.timeString(from: pausedTimeSnapshot))
                        .font(.appNumber(size: 32))
                        .foregroundColor(AppColors.Semantic.darkBrown)
                        .opacity(isTimerBlinking ? 1.0 : 0.0)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, geometry.safeAreaInsets.top + 50)

                Spacer()
            }
        }
        .onAppear {
            startBlinkTimer()
        }
        .onDisappear {
            stopBlinkTimer()
        }
    }
    
    @ViewBuilder
    private func idleView(geometry: GeometryProxy) -> some View {
        ZStack {
            VStack {
                Button(action: { step = 0 }) {
                    LottieView(name: "start", loopMode: .loop)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 40)
                }
                .disabled(isStartingTimer)
            }
            
            HStack(spacing: 60) {
                Button(action: { showTimePicker = true }) {
                    VStack(spacing: 8) {
                        Image("home_time")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .aspectRatio(contentMode: .fit)
                        Text(backgroundTimerManager.timeString(from: focusTime))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.Semantic.darkBrown)
                    }
                }
                
                Button(action: { showLocationSelection = true }) {
                    VStack(spacing: 8) {
                        Image("home_label")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .aspectRatio(contentMode: .fit)
                        Text(selectedLocation.isEmpty ? "Location" : selectedLocation)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.Semantic.darkBrown)
                    }
                }
                
                Button(action: { showMusicSelection = true }) {
                    VStack(spacing: 8) {
                        Image(selectedMusic.isEmpty ? "home_noise_fill" : selectedMusic + "_fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .aspectRatio(contentMode: .fit)
                            
                        Text(selectedMusic == "silent" || selectedMusic.isEmpty ? "off" : "on")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.Semantic.darkBrown)
                    }
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 200)
            .disabled(isStartingTimer)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var overlayContent: some View {
        Group {
            if showLocationSelection {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showLocationSelection = false }
                
                LocationSelectionView(
                    selectedLocation: $selectedLocation,
                    isPresented: $showLocationSelection
                )
            }
            
            if showMusicSelection {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showMusicSelection = false }
                
                MusicSelectionView(
                    isPresented: $showMusicSelection,
                    selectedMusic: $selectedMusic,
                    isTimerRunning: step == 3
                )
            }
            
            if showTimePicker {
                TimePickerView(
                    selectedMinutes: $selectedMinutes,
                    isPresented: $showTimePicker
                )
            }
        }
    }

    var body: some View {
        mainContent
            .background(AppColors.Background.primary)
            .ignoresSafeArea(.keyboard)
            .overlay(overlayContent)
            .onChange(of: showTimePicker) { _, isShowing in
                if !isShowing {
                    focusTime = selectedMinutes * 60
                }
            }
            .onChange(of: selectedMusic) { _, newMusic in
                // 只保存选择，不立即播放
                userManager.updateSelectedMusic(newMusic)
            }
            .onChange(of: selectedLocation) { _, newLocation in
                userManager.updateSelectedLocation(newLocation)
            }
            .onChange(of: selectedMinutes) { _, newMinutes in
                userManager.updateSelectedMinutes(newMinutes)
            }
            .onChange(of: step) { oldStep, newStep in
                withAnimation(.easeInOut(duration: 0.3)) {
                    tabBarVisibility.isHidden = (newStep >= 0)
                }
                
                // 当从 step 2 进入 step 3 时，启动计时器并播放音乐
                if oldStep == 2 && newStep == 3 {
                    print("🎬 进入 step 3，检查计时器状态: \(backgroundTimerManager.isTimerRunning)")
                    if !backgroundTimerManager.isTimerRunning {
                        print("🎬 启动计时器")
                        startTimer()
                    }
                    // 开始播放选中的音乐
                    if let fileName = getAudioFileName(for: selectedMusic) {
                        audioManager.playSound(fileName: fileName)
                    }
                }
                
                // 当从 step 3 退出时（但不是进入 step 4 暂停），停止音乐并清除动画状态
                if oldStep == 3 && newStep != 3 && newStep != 4 {
                    audioManager.stopSound()
                    concentrationService.clearState()
                    lottieAnimationManager.clearAnimation()
                    print("🧹 退出 step 3，清除动画状态")
                }
                
                // 当从 step 4 退出时（但不是回到 step 3），停止音乐并清除动画状态
                if oldStep == 4 && newStep != 3 && newStep != 4 {
                    audioManager.stopSound()
                    concentrationService.clearState()
                    lottieAnimationManager.clearAnimation()
                    print("🧹 退出 step 4，清除动画状态")
                }
            }
            .onAppear {
                loadUserPreferences()
            }
            .onReceive(NotificationCenter.default.publisher(for: .timerCompletedInBackground)) { _ in
                self.isComplete = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .timerCompleted)) { _ in
                self.isComplete = true
            }
            .overlay(shareOverlay)
    }


    private var shareOverlay: some View {
        Group {
            if showShareView, let achievement = currentAchievement {
                ShareAchievementView(
                    achievement: achievement,
                    isPresented: $showShareView
                )
            }
        }
    }

    private func loadUserPreferences() {
        selectedLocation = userManager.getSelectedLocation()
        selectedMusic = userManager.getSelectedMusic()
        selectedMinutes = userManager.getSelectedMinutes()
        focusTime = selectedMinutes * 60
    }
    
    private func startBlinkTimer() {
        // 停止之前的定时器（如果存在）
        stopBlinkTimer()
        
        // 创建新的定时器，每1秒切换一次显示状态
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                isTimerBlinking.toggle()
            }
        }
    }
    
    private func stopBlinkTimer() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        isTimerBlinking = true // 重置为显示状态
    }
    
    private func handleMusicChange(_ newMusic: String) {
        userManager.updateSelectedMusic(newMusic)
        let audioManager = AudioManager.shared
        if let fileName = getAudioFileName(for: newMusic) {
            audioManager.playSound(fileName: fileName)
        } else {
            audioManager.stopSound()
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
                let (plan, animationURL, currentDropStuff) = try await concentrationService.startConcentrationWithAnimation(
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

                    currentAchievement = Achievement(id: 0,
                                                     title: currentDropStuff.name,
                                                     description: currentDropStuff.description,
                                                     image: currentDropStuff.shareImage ?? "",
                                                     isUnlocked: false,
                                                     category: .calmFields,
                                                     badgeNumber: 1,
                                                     isRemoteImage: true,
                                                     tab: .friends,
                                                     shareText: currentDropStuff.name,
                                                     shareImage: currentDropStuff.shareImage)

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
    private func pauseTimer() {
        // 保存当前动画状态
        animationStateBeforePause = concentrationService.currentAnimationState
        
        // 保存暂停时的剩余时间快照
        pausedTimeSnapshot = backgroundTimerManager.remainingTime
        
        // 暂停计时器
        backgroundTimerManager.pauseTimer()
        
        // 暂停音乐播放
        audioManager.pauseSound()
        
        // 切换到睡眠动画
        concentrationService.switchToSleepAnimation()
        
        print("⏸️ 计时器已暂停，切换到睡眠动画，剩余时间: \(pausedTimeSnapshot)秒")
    }
    
    private func resumeTimer() {
        // 恢复计时器
        backgroundTimerManager.resumeTimer()
        
        // 恢复音乐播放
        if let fileName = getAudioFileName(for: selectedMusic) {
            audioManager.resumeSound()
        }
        
        // 恢复到暂停前的动画状态
        if animationStateBeforePause == .adult {
            concentrationService.switchToAdultAnimation()
        } else {
            concentrationService.switchToChildAnimation()
        }
        
        print("▶️ 计时器已恢复，恢复到\(animationStateBeforePause.displayName)动画")
    }
    
    private func stopTimer() {
        // 停止BackgroundTimerManager的计时
        backgroundTimerManager.stopTimer()
        
        // 停止音乐播放
        audioManager.stopSound()
        
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
                
                // 不自动清除动画，让成年动画一直播放直到用户退出 step=3
                // 动画会在用户退出 step=3 时通过 onChange(of: step) 清除
            }
        }
    }

    private func handleBackgroundTimerCompletion() {
        // 后台计时完成，停止音乐，切换到成体动画，然后调用结束接口
        print("🎯 计时完成，停止音乐并切换到成年动画")
        audioManager.stopSound()
        concentrationService.switchToAdultAnimation()

        // 立即调用结束接口获取奖励，但保持成年动画播放
        naturalEndConcentrationSession()
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
    
    // 获取场景背景图片名称
    private func getSceneBackgroundImage() -> String? {
        // 从 ConcentrationService 获取当前专注计划的场景信息
        // 场景名称应该与本地图片资源名称一致：CalmFields, TropicalWilds, IceSands
        return concentrationService.currentStuffScene
    }
}

#Preview {
    HomeView()
}
