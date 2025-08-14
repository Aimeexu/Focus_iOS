//
//  TimePickerView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var selectedMinutes: Int
    @Binding var isPresented: Bool
    
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    
    // 时间选项（分钟）
    private let timeOptions = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    
    // 装饰性线条的位置和角度
    private let decorativeLines = [
        (x: 0.2, y: 0.15, angle: 45.0, length: 40.0),
        (x: 0.8, y: 0.2, angle: -30.0, length: 35.0),
        (x: 0.15, y: 0.35, angle: 60.0, length: 25.0),
        (x: 0.85, y: 0.4, angle: -45.0, length: 30.0),
        (x: 0.3, y: 0.65, angle: 30.0, length: 35.0),
        (x: 0.75, y: 0.7, angle: -60.0, length: 40.0),
        (x: 0.1, y: 0.8, angle: 45.0, length: 30.0),
        (x: 0.9, y: 0.85, angle: -30.0, length: 25.0)
    ]
    
    var body: some View {
        ZStack {
            // 背景
            AppColors.Background.primary
                .ignoresSafeArea()
            
            // 装饰性线条
            GeometryReader { geometry in
                ForEach(0..<decorativeLines.count, id: \.self) { index in
                    let line = decorativeLines[index]
                    Rectangle()
                        .fill(AppColors.Semantic.beige)
                        .frame(width: 3, height: line.length)
                        .rotationEffect(.degrees(line.angle))
                        .position(
                            x: geometry.size.width * line.x,
                            y: geometry.size.height * line.y
                        )
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 时间选择器
                VStack(spacing: 20) {
                    // 上方时间显示（较小）
                    Text(formatTime(getTimeAtOffset(-1)))
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.Text.tertiary)
                        .opacity(0.6)
                    
                    // 主要时间显示（大号）
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
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let translation = gesture.translation.height
                            dragOffset = translation
                        }
                        .onEnded { gesture in
                            let translation = gesture.translation.height
                            let velocity = gesture.velocity.height
                            
                            // 计算应该移动多少个选项
                            let itemHeight: CGFloat = 60
                            var steps = Int((translation + velocity * 0.1) / itemHeight)
                            
                            // 限制步数
                            steps = max(-timeOptions.count + 1, min(timeOptions.count - 1, steps))
                            
                            // 更新选中的时间
                            if let currentIndex = timeOptions.firstIndex(of: selectedMinutes) {
                                let newIndex = max(0, min(timeOptions.count - 1, currentIndex - steps))
                                selectedMinutes = timeOptions[newIndex]
                            }
                            
                            // 重置拖拽偏移
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                )
                
                Spacer()
                
                // OK按钮
                Button(action: {
                    isPresented = false
                }) {
                    Text("OK")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(AppColors.Brand.primary)
                        .cornerRadius(25)
                }
                .padding(.bottom, 60)
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