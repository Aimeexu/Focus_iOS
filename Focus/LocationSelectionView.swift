//
//  LocationSelectionView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct LocationSelectionView: View {
    @Binding var selectedLocation: String
    @Binding var isPresented: Bool
    @State private var isAddingNew = false
    @State private var newLocationText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var locations = ["Gym", "Read", "Work", "Paint", "Nap"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 标签列表区域
            VStack(spacing: 12) {
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
                    HStack(spacing: 8) {
                        TextField("输入新标签", text: $newLocationText)
                            .font(.system(size: 16, weight: .medium))
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                            .background(Color.white)
                            .cornerRadius(25)
                            .focused($isTextFieldFocused)
                        
                        // OK按钮 - 从右侧滑入
                        Button(action: {
                            addNewLocation()
                        }) {
                            Text("OK")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.green)
                                .cornerRadius(25)
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
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 20)
            .background(Color(.systemGray6))
            
            // Done 按钮
            Button(action: {
                isPresented = false
            }) {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.brown)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.horizontal, 40)
        .padding(.vertical, 60)
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
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isSelected ? Color.green : Color.white)
                .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LocationSelectionView(
        selectedLocation: .constant("Gym"),
        isPresented: .constant(true)
    )
    .background(Color.black.opacity(0.3))
}