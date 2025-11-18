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
    
    @State private var locations: [String] = []
    @State private var keyboardHeight: CGFloat = 0
    @State private var hideDeleteButtons = false
    
    private let userManager = UserManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            let modalWidth = geometry.size.width * 0.811
            let modalHeight = geometry.size.height * 0.653

            ZStack {
                // 背景
                AppColors.Background.primary
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    Spacer()
                    
                    // 标签列表区域 - 自适应高度
                    let itemCount = locations.count + 1 // 包括添加按钮
                    let calculatedHeight = CGFloat(itemCount - 1) * 70 + 60 + 60 // (n-1)个item*70 + 最后一个item60 + 顶部padding60
                    let maxScrollHeight = modalHeight - 60 - 120 // 减去顶部padding和Done按钮高度
                    let finalHeight = min(calculatedHeight, maxScrollHeight)

                    ScrollView(.vertical, showsIndicators: finalHeight >= maxScrollHeight) {
                        VStack(spacing: 10) {
                            ForEach(locations, id: \.self) { location in
                                LocationTagButton(
                                    title: location,
                                    isSelected: selectedLocation == location,
                                    isCustom: userManager.getCustomLocations().contains(location),
                                    hideDeleteButton: hideDeleteButtons
                                ) {
                                    selectedLocation = location
                                    // 选择位置时隐藏所有删除按钮
                                    hideDeleteButtons = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        hideDeleteButtons = false
                                    }
                                } onDelete: {
                                    deleteLocation(location)
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
                        .padding(.horizontal, 40)
                    }
                    .frame(height: finalHeight)
                    .padding(.top, 60)
                    .padding(.bottom, 0)
                    .background(Color.clear)

                    Spacer()

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
                .frame(width: modalWidth, height: modalHeight)
                .background(AppColors.Semantic.lightGray)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(AppColors.Semantic.darkBrown, lineWidth: 3)
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .offset(y: -keyboardHeight / 2) // 键盘弹起时向上移动
                .onTapGesture {
                    // 点击空白区域取消输入并隐藏删除按钮
                    if isAddingNew {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isAddingNew = false
                            isTextFieldFocused = false
                        }
                        newLocationText = ""
                    }

                    // 隐藏所有删除按钮
                    hideDeleteButtons = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideDeleteButtons = false
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
                .onAppear {
                    loadLocations()
                }
            }
        }
    }

    private func loadLocations() {
        locations = userManager.getAllLocations()
    }
    
    private func addNewLocation() {
        let trimmedText = newLocationText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            // 保存到UserManager
            userManager.addCustomLocation(trimmedText)
            
            // 重新加载locations数组
            loadLocations()
            
            // 设置为选中状态
            selectedLocation = trimmedText
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isAddingNew = false
            isTextFieldFocused = false
        }
        newLocationText = ""
    }
    
    private func deleteLocation(_ location: String) {
        let customLocations = userManager.getCustomLocations()

        // 只能删除自定义位置
        if customLocations.contains(location) {
            userManager.removeCustomLocation(location)
            
            // 重新加载locations数组
            loadLocations()

            // 如果删除的是当前选中的位置，切换到默认位置
            if selectedLocation == location {
                selectedLocation = "Read"
            }
        } else {
            print("❌ 不是自定义位置，无法删除")
        }
    }
}

struct LocationTagButton: View {
    let title: String
    let isSelected: Bool
    let isCustom: Bool
    let hideDeleteButton: Bool
    let action: () -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var showDeleteButton = false
    
    private let deleteButtonWidth: CGFloat = 80
    
    var body: some View {
        ZStack {
            // 背景删除按钮（在主按钮下方）
            if isCustom {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        print("🔴 删除按钮被点击: \(title)")
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                            showDeleteButton = false
                        }
                        onDelete()
                    }) {
                        VStack {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 20))
                            Text("删除")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: deleteButtonWidth, height: 60)
                        .background(AppColors.Brand.primary)
                        .cornerRadius(14)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(showDeleteButton ? 1 : 0)
                    .scaleEffect(showDeleteButton ? 1 : 0.8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showDeleteButton)
                }
            }
            
            // 主按钮内容（不使用Button，避免手势冲突）
            HStack {
                Text(title)
                    .font(.appBody(size: 24))
                    .foregroundColor(isSelected ? AppColors.Text.inverse : AppColors.Text.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(.horizontal, 20)
            .background(isSelected ? AppColors.Brand.primary : AppColors.Background.primary)
            .cornerRadius(14)
            .offset(x: dragOffset)
            .onTapGesture {
                // 如果删除按钮显示中，先隐藏删除按钮
                if showDeleteButton {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = 0
                        showDeleteButton = false
                    }
                } else {
                    action()
                }
            }
            .gesture(
                isCustom ? DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        let translation = value.translation.width
                        
                        // 只允许向左滑动
                        if translation < 0 {
                            dragOffset = max(translation, -deleteButtonWidth)
                        } else if showDeleteButton {
                            // 如果删除按钮已显示，允许向右滑动隐藏
                            dragOffset = min(0, -deleteButtonWidth + translation)
                        }
                    }
                    .onEnded { value in
                        let translation = value.translation.width
                        let velocity = value.velocity.width
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if translation < -deleteButtonWidth/2 || velocity < -500 {
                                // 显示删除按钮
                                dragOffset = -deleteButtonWidth
                                showDeleteButton = true
                            } else {
                                // 隐藏删除按钮
                                dragOffset = 0
                                showDeleteButton = false
                            }
                        }
                    } : nil
            )
        }
        .clipped()
        .onChange(of: hideDeleteButton) { _, shouldHide in
            if shouldHide && showDeleteButton {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    dragOffset = 0
                    showDeleteButton = false
                }
            }
        }
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
