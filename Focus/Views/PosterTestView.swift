//
//  PosterTestView.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import SwiftUI

struct PosterTestView: View {
    @StateObject private var posterManager = PosterManager.shared
    @State private var showingPosters = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("海报系统测试")
                .font(.appLargeTitle())
                .padding()
            
            VStack(spacing: 16) {
                Button("测试解析海报数据") {
                    posterManager.testParsePosterData()
                }
                .buttonStyle(.borderedProminent)
                
                Button("使用成就系统数据") {
                    // 先生成成就系统的测试数据
                    AchievementManager.shared.testParseLoginData()
                    // 然后生成海报
                    posterManager.generatePostersFromCurrentUser()
                }
                .buttonStyle(.bordered)
                
                Button("从当前用户生成海报") {
                    posterManager.generatePostersFromCurrentUser()
                }
                .buttonStyle(.bordered)
                
                Button("查看海报页面") {
                    showingPosters = true
                }
                .buttonStyle(.bordered)
            }
            
            if posterManager.isLoading {
                ProgressView("处理中...")
                    .padding()
            }
            
            // 显示生成的海报数量
            Text("已生成海报: \(posterManager.posters.count)")
                .font(.appBody())
                .foregroundColor(.secondary)
            
            // 显示海报列表预览
            if !posterManager.posters.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("海报预览:")
                        .font(.appHeadline())
                    
                    ForEach(posterManager.posters.prefix(5)) { poster in
                        HStack {
                            Image(systemName: poster.isUnlocked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(poster.isUnlocked ? .green : .gray)
                            
                            VStack(alignment: .leading) {
                                Text(poster.title)
                                    .font(.appButton())
                                Text(poster.description)
                                    .font(.appCaption())
                                    .foregroundColor(.secondary)
                                Text("场景: \(poster.category.sideLabel)")
                                    .font(.appCaption())
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            if let badge = poster.badgeNumber {
                                Text("\(badge)")
                                    .font(.appCaption())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if posterManager.posters.count > 5 {
                        Text("... 还有 \(posterManager.posters.count - 5) 个海报")
                            .font(.appCaption())
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingPosters) {
            PostingView()
        }
    }
}

#Preview {
    PosterTestView()
}