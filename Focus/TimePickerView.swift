//
//  TimePickerView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI
import UIKit

struct TimePickerView: View {
    @Binding var selectedMinutes: Int
    @Binding var isPresented: Bool
    
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    @State private var initialIndex: Int = 0
    @State private var lastSelectedMinutes: Int = 0
    @State private var rotationAngle: Double = 0
    
    // 时间选项（分钟）
    private let timeOptions = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                AppColors.Background.primary
                    .ignoresSafeArea()
                
                // 添加背景圆形图片 - 移动到屏幕最右边
                Image("time")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 480, height: 480)
                    .opacity(0.7)
                    .rotationEffect(.degrees(rotationAngle), anchor: .center) // 以图片中心为旋转中心
                    .position(
                        x: geometry.size.width, // 图片中心位于屏幕右边缘
                        y: geometry.size.height * 0.5   // 垂直居中
                    )
                
                // 时间选择器 - 与背景图片垂直居中对齐
                VStack(spacing: 20) {
                    // 上方时间显示（较小）
                    Text(formatTime(getTimeAtOffset(-1)))
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.Text.tertiary)
                        .opacity(0.6)
                    
                    // 主要时间显示（大号）- 这个会与背景图片中心对齐
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(formatMainTime(selectedMinutes))
                            .font(.system(size: 72, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.Semantic.darkBrown)
                        
                        Text("M")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(AppColors.Semantic.darkBrown)
                            .padding(.bottom, 8)
                    }
                    
                    // 下方时间显示（较小）
                    Text(formatTime(getTimeAtOffset(1)))
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.Text.tertiary)
                        .opacity(0.6)
                }
                .background(AppColors.Background.primary)
                .position(
                    x: geometry.size.width * 0.5,
                    y: geometry.size.height * 0.5
                )
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let translation = gesture.translation.height
                            dragOffset = translation
                            
                            // 实时更新选中的时间
                            let itemHeight: CGFloat = 50 // 每50点切换一个选项
                            let steps = Int(translation / itemHeight)
                            
                            // 计算新的索引
                            let newIndex = max(0, min(timeOptions.count - 1, initialIndex - steps))
                            
                            // 更新选中的时间
                            if newIndex != timeOptions.firstIndex(of: selectedMinutes) {
                                let newMinutes = timeOptions[newIndex]
                                if newMinutes != lastSelectedMinutes {
                                    // 触发轻微震动
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    // 触发旋转动画
                                    triggerRotationAnimation()
                                    
                                    selectedMinutes = newMinutes
                                    lastSelectedMinutes = newMinutes
                                }
                            }
                        }
                        .onEnded { gesture in
                            // 重置拖拽偏移
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                )
                .onAppear {
                    // 记录初始索引和初始选中值
                    initialIndex = timeOptions.firstIndex(of: selectedMinutes) ?? 0
                    lastSelectedMinutes = selectedMinutes
                }
                .onChange(of: selectedMinutes) { _ in
                    // 当选中时间改变时，更新初始索引（用于下次拖拽）
                    if dragOffset == 0 { // 只在非拖拽状态下更新
                        initialIndex = timeOptions.firstIndex(of: selectedMinutes) ?? 0
                    }
                }
                
                // OK按钮 - 向上移动
                VStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("OK")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 66)
                            .background(AppColors.Brand.primary)
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 160)
                }
            }
        }
    }
    
    // 格式化时间显示
    private func formatTime(_ minutes: Int) -> String {
        return String(format: "%d:00", minutes)
    }
    
    // 格式化主要时间显示
    private func formatMainTime(_ minutes: Int) -> String {
        return String(format: "%d:00", minutes)
    }
    
    // 获取偏移位置的时间
    private func getTimeAtOffset(_ offset: Int) -> Int {
        guard let currentIndex = timeOptions.firstIndex(of: selectedMinutes) else {
            return selectedMinutes
        }
        
        let newIndex = currentIndex + offset
        if newIndex >= 0 && newIndex < timeOptions.count {
            return timeOptions[newIndex]
        }
        
        return selectedMinutes
    }
    
    // 触发旋转动画
    private func triggerRotationAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            rotationAngle += 15 // 每次旋转15度，累积旋转
        }
    }
}

// MARK: - 使用示例
struct TimePickerExample: View {
    @State private var selectedMinutes = 25
    @State private var showTimePicker = false
    
    var body: some View {
        VStack {
            Button("选择时间: \(selectedMinutes)分钟") {
                showTimePicker = true
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.Brand.primary)
            .cornerRadius(25)
        }
        .fullScreenCover(isPresented: $showTimePicker) {
            TimePickerView(
                selectedMinutes: $selectedMinutes,
                isPresented: $showTimePicker
            )
        }
    }
}

#Preview {
    TimePickerExample()
}
