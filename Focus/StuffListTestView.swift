//
//  StuffListTestView.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import SwiftUI

struct StuffListTestView: View {
    @StateObject private var stuffManager = StuffManager.shared
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // 测试按钮
                Button("获取物品列表") {
                    fetchStuffList()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading)
                
                if isLoading {
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
                List(stuffManager.stuffItems) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                        
                        Text(item.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if let category = item.category {
                                Text("分类: \(category)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            
                            if let rarity = item.rarity {
                                Text("稀有度: \(rarity)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                            
                            if let value = item.value {
                                Text("价值: \(value)")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                Spacer()
            }
            .navigationTitle("物品列表测试")
        }
    }
    
    private func fetchStuffList() {
        isLoading = true
        
        Task {
            do {
                let items = try await stuffManager.fetchStuffList()
                await MainActor.run {
                    print("✅ 获取到 \(items.count) 个物品")
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("❌ 获取物品列表失败: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    StuffListTestView()
}