//
//  StuffListTestView.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import SwiftUI

struct StuffListTestView: View {
    @StateObject private var stuffManager = StuffManager.shared
    @State private var selectedType: UserStuffType = .poster
    
    var body: some View {
        NavigationView {
            VStack {
                // 类型选择器
                Picker("物品类型", selection: $selectedType) {
                    ForEach(UserStuffType.allCases, id: \.self) { type in
                        Label(type.displayName, systemImage: type.icon)
                            .tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 测试按钮
                Button("获取物品列表") {
                    fetchStuffList()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(stuffManager.isLoading)
                
                if stuffManager.isLoading {
                    ProgressView("加载中...")
                        .padding()
                }
                
                // 错误信息
                if let errorMessage = stuffManager.errorMessage {
                    Text("错误: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                // 物品列表
                let filteredItems = stuffManager.getUserStuffBases(by: selectedType)
                
                if filteredItems.isEmpty && !stuffManager.isLoading {
                    VStack {
                        Image(systemName: selectedType.icon)
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("暂无\(selectedType.displayName)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredItems) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.headline)
                            
                            Text(item.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(item.userStuffType.displayName)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                                
                                Spacer()
                                
                                if let firstPrice = item.stuffPrices.first {
                                    Text("\(firstPrice.amount) 金币")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            // 如果是宠物且有附件，显示动画信息
                            if item.userStuffType == .pet, let attachment = item.attachment {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(.green)
                                    Text("包含动画: \(attachment.allAnimationURLs.count) 个")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("物品列表测试")
            .onAppear {
                if stuffManager.userStuffBases.isEmpty {
                    fetchStuffList()
                }
            }
        }
    }
    
    private func fetchStuffList() {
        Task {
            do {
                let items = try await stuffManager.fetchStuffList()
                print("✅ 获取到 \(items.count) 个物品")
            } catch {
                print("❌ 获取物品列表失败: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    StuffListTestView()
}