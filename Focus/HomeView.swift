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
    @State private var focusTime = 25 * 60 // 25分钟
    @State private var isTimerRunning = false
    @State private var selectedLocation = UserDefaults.standard.string(forKey: "selectedLocation") ?? "Gym"
    @State private var timer: Timer?
    @State private var showLocationSelection = false
    @State private var showMusicSelection = false
    @State private var selectedMusic: String = UserDefaults.standard.string(forKey: "selectedMusic") ?? "silent"
    @State private var showTimePicker = false
    @State private var selectedMinutes = UserDefaults.standard.object(forKey: "selectedMinutes") as? Int ?? 25
    @State private var currentConcentrationPlan: ConcentrationPlan?
    @State private var isStartingTimer = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 0) {

                    // 顶部音乐图标
                    Button(action: {
                        showMusicSelection = true
                    }) {
                        Image(selectedMusic)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 42, height: 42)
                            .foregroundColor(AppColors.Semantic.darkBrown)
                    }
                    .padding(.top, 84)

                    // 位置标签 - 只在未运行时显示
                    if !isTimerRunning {
                        Button(action: {
                            showLocationSelection = true
                        }) {
                            HStack(spacing: 4) {
                                Image("home_label")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 36)

                                Text(selectedLocation)
                                    .font(.appButton(size: 20))
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
                    }

                    // 计时器显示区域
                    if isTimerRunning {
                        VStack(spacing: 40) {
                            // 猫头鹰动画 - 在中间空白区域
                            OwlAnimationView(animationName: "owl")
                                .frame(width: 200, height: 200)
                                .padding(.top, 150)
                            
                            // 运行时显示大号时间
                            Text(timeString(from: focusTime))
                                .font(.appNumber(size: 24))
                                .foregroundColor(AppColors.Semantic.darkBrown)
                        }
                    } else {
                        // 未运行时显示圆形选择器
                        Button(action: {
                            showTimePicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.Semantic.lightGray)
                                    .frame(width: 230, height: 230)

                                Circle()
                                    .fill(AppColors.Semantic.beige)
                                    .frame(width: 210, height: 210)

                                Text(timeString(from: focusTime))
                                    .font(.appNumber(size: 42))
                                    .foregroundColor(AppColors.Semantic.darkBrown)
                            }
                        }
                        .padding(.top, 32)
                    }

                    // 按钮区域
                    if isTimerRunning {
                        // 运行时显示 Slide to Quit 按钮
                        SlideToQuitButton {
                            stopTimer()
                        }
                        .padding(.horizontal, 60)
                        .padding(.top, 100)
                    } else {
                        // 未运行时显示 Start to Focus 按钮
                        Button(action: {
                            toggleTimer()
                        }) {
                            HStack {
                                if isStartingTimer {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Start to Focus")
                                        .font(.appButton(size: 20))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 66)
                            .background(AppColors.Brand.primary)
                            .cornerRadius(20)
                        }
                        .disabled(isStartingTimer)
                        .padding(.horizontal, 90)
                        .padding(.top, 72)
                    }

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
            // 恢复播放之前选择的音乐
            restoreBackgroundMusic()
        }
        .onChange(of: showTimePicker) { _, isShowing in
            if !isShowing {
                // 时间选择器关闭时，更新focusTime
                focusTime = selectedMinutes * 60
            }
        }
        .onChange(of: selectedMusic) { _, newMusic in
            // 保存选中的音乐到UserDefaults
            UserDefaults.standard.set(newMusic, forKey: "selectedMusic")
            // 立即播放新选择的音乐
            let audioManager = AudioManager.shared
            if let fileName = getAudioFileName(for: newMusic) {
                audioManager.playSound(fileName: fileName)
            } else {
                audioManager.stopSound() // 如果选择静音，停止播放
            }
        }
        .onChange(of: selectedLocation) { _, newLocation in
            // 保存选中的位置到UserDefaults
            UserDefaults.standard.set(newLocation, forKey: "selectedLocation")
        }
        .onChange(of: selectedMinutes) { _, newMinutes in
            // 保存选中的时间到UserDefaults
            UserDefaults.standard.set(newMinutes, forKey: "selectedMinutes")
        }
    }

    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        // 检查用户是否已登录
        guard AuthService.shared.isLoggedIn() else {
            print("❌ 用户未登录，无法开始专注计时")
            return
        }
        
        isStartingTimer = true
        
        Task {
            do {
                // 1. 先获取物品列表
                print("📦 正在获取物品列表...")
                let stuffResponse = try await NetworkManager.shared.getStuffList()
                
                if stuffResponse.status == "success", let stuffItems = stuffResponse.data {
                    print("✅ 物品列表获取成功，共 \(stuffItems.count) 个物品")
                    
                    // 更新StuffManager中的数据
                    await MainActor.run {
                        StuffManager.shared.stuffItems = stuffItems
                    }
                } else {
                    print("⚠️ 物品列表获取失败: \(stuffResponse.message)")
                    // 继续执行，不阻断专注计时
                }
                
                // 2. 调用后台接口开始专注计时（现在使用Cookie认证）
                print("⏰ 正在开始专注计时...")
                let response = try await NetworkManager.shared.startConcentration(
                    duration: selectedMinutes
                )
                
                await MainActor.run {
                    if response.status == "success", let data = response.data {
                        // 保存专注计划信息
                        currentConcentrationPlan = data.concentrationPlan
                        
                        // 开始本地计时器
                        isTimerRunning = true
                        isStartingTimer = false
                        
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            if focusTime > 0 {
                                focusTime -= 1
                            } else {
                                // 计时结束，调用结束接口
                                endConcentrationSession()
                            }
                        }
                        
                        print("✅ 专注计时开始成功")
                        print("   计划ID: \(data.concentrationPlan.uuid)")
                        print("   状态: \(data.concentrationPlan.status)")
                        print("   开始时间: \(data.concentrationPlan.startDate)")
                        print("   奖励物品: \(data.stuffId) x\(data.stuffAmount)")
                    } else {
                        isStartingTimer = false
                        print("❌ 专注计时开始失败: \(response.message)")
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
//    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        
        // 如果有正在进行的专注计划，调用结束接口
        if let plan = currentConcentrationPlan {
            endConcentrationSession()
        }
    }
    
    private func endConcentrationSession() {
        guard let plan = currentConcentrationPlan else {
            return
        }
        
        Task {
            do {
                let _ = try await NetworkManager.shared.endConcentration(
                    planId: plan.uuid
                )
                
                await MainActor.run {
                    currentConcentrationPlan = nil
                    timer?.invalidate()
                    timer = nil
                    isTimerRunning = false
                    
                    // 重置计时器时间
                    focusTime = selectedMinutes * 60
                    
                    print("✅ 专注计时结束成功")
                }
            } catch {
                await MainActor.run {
                    // 即使接口调用失败，也要停止本地计时器
                    currentConcentrationPlan = nil
                    timer?.invalidate()
                    timer = nil
                    isTimerRunning = false
                    focusTime = selectedMinutes * 60
                    
                    print("❌ 结束专注计时失败: \(error.localizedDescription)")
                }
            }
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
