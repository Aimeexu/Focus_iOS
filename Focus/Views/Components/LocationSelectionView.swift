//
//  LocationSelectionView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

// 用于获取内容高度的 PreferenceKey
struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct LocationSelectionView: View {
    @Binding var selectedLocation: String
    @Binding var isPresented: Bool
    @State private var isAddingNew = false
    @State private var newLocationText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var contentHeight: CGFloat = 0
    
    @State private var locations = ["Read", "Study", "Work"]
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {

        ZStack {
            // 背景
            AppColors.Background.primary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 标签列表区域 - 自适应高度
                let itemCount = locations.count + 1 // 包括添加按钮
                let calculatedHeight = CGFloat(itemCount - 1) * 70 + 60 + 60 // (n-1)个item*70 + 最后一个item60 + 顶部padding60
                let finalHeight = min(calculatedHeight, 400) // 最大400高度

                ScrollView(.vertical, showsIndicators: finalHeight >= 400) {
                    VStack(spacing: 10) {
                        ForEach(locations, id: \.self) { location in
                            LocationTagButton(
                                title: location,
                                isSelected: selectedLocation == location
                            ) {
                                selectedLocation = location
                            }
                        }

                        // 添加新标签按钮或输入框
                        if isAddingNew {
                            HStack(spacing: 0) {
                                TextField("输入新标签", text: $newLocationText)
                                    .font(.appBody(size: 24))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .frame(height: 60)
                                    .padding(.horizontal, 20)
                                    .background(AppColors.Background.primary)
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 12,
                                            bottomLeadingRadius: 12,
                                            bottomTrailingRadius: 0,
                                            topTrailingRadius: 0
                                        )
                                    )
                                    .focused($isTextFieldFocused)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        addNewLocation()
                                    }
                                    .foregroundColor(Color(AppColors.Text.primary))

                                // OK按钮 - 从右侧滑入
                                Button(action: {
                                    addNewLocation()
                                }) {
                                    Text("OK")
                                        .font(.appButton(size: 24))
                                        .foregroundColor(AppColors.Text.inverse)
                                        .frame(width: 50, height: 60)
                                        .background(AppColors.Brand.primary)
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 0,
                                                bottomLeadingRadius: 0,
                                                bottomTrailingRadius: 12,
                                                topTrailingRadius: 12
                                            )
                                        )
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                            .transition(.opacity)
                        } else {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isAddingNew = true
                                    newLocationText = ""
                                }
                                // 延迟一点让动画完成后再聚焦
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isTextFieldFocused = true
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.appBody(size: 24))
                                    .foregroundColor(AppColors.Brand.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(AppColors.Background.primary)
                                    .cornerRadius(12)
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: finalHeight)
                .padding(.top, 60)
                .padding(.bottom, 0)
                .background(AppColors.Semantic.beige)

                // Done 按钮
                Button(action: {
                    isPresented = false
                }) {
                    Text("Done")
                        .font(.appButton(size: 24))
                        .foregroundColor(AppColors.Text.inverse)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(AppColors.Semantic.darkBrown)
                }
            }
            .background(AppColors.Semantic.beige)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(AppColors.Semantic.darkBrown, lineWidth: 3)
            )
            .padding(.horizontal, 38)
            .padding(.vertical, 20)
            .offset(y: -keyboardHeight / 2) // 键盘弹起时向上移动
            .onTapGesture {
                // 点击空白区域取消输入
                if isAddingNew {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAddingNew = false
                        isTextFieldFocused = false
                    }
                    newLocationText = ""
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        keyboardHeight = keyboardFrame.height
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardHeight = 0
                }
            }
        }
    }

    private func addNewLocation() {
        let trimmedText = newLocationText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty && !locations.contains(trimmedText) {
            // 插入到数组的第一个位置
            locations.insert(trimmedText, at: 0)
            selectedLocation = trimmedText
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isAddingNew = false
            isTextFieldFocused = false
        }
        newLocationText = ""
    }
        
}

struct LocationTagButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appBody(size: 24))
                .foregroundColor(isSelected ? AppColors.Text.inverse : AppColors.Text.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(isSelected ? AppColors.Brand.primary : AppColors.Background.primary)
                .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        AppColors.Semantic.beige.edgesIgnoringSafeArea(.all)
        LocationSelectionView(
            selectedLocation: .constant("Read"),
            isPresented: .constant(true)
        )
    }
}
