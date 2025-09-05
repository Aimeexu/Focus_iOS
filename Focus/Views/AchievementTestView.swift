//
//  AchievementTestView.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import SwiftUI

struct AchievementTestView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var showingAchievements = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("成就系统测试")
                .font(.appLargeTitle())
                .padding()
            
            VStack(spacing: 16) {
                Button("测试解析登录数据") {
                    achievementManager.testParseLoginData()
                }
                .buttonStyle(.borderedProminent)
                
                Button("从当前用户生成成就") {
                    achievementManager.generateAchievementsFromCurrentUser()
                }
                .buttonStyle(.bordered)
                
                Button("查看成就页面") {
                    showingAchievements = true
                }
                .buttonStyle(.bordered)
            }
            
            if achievementManager.isLoading {
                ProgressView("处理中...")
                    .padding()
            }
            
            // 显示生成的成就数量
            Text("已生成成就: \(achievementManager.achievements.count)")
                .font(.appBody())
                .foregroundColor(.secondary)
            
            // 显示成就列表预览
            if !achievementManager.achievements.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("成就预览:")
                        .font(.appHeadline())
                    
                    ForEach(achievementManager.achievements.prefix(5)) { achievement in
                        HStack {
                            Image(systemName: achievement.isUnlocked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(achievement.isUnlocked ? .green : .gray)
                            
                            VStack(alignment: .leading) {
                                Text(achievement.title)
                                    .font(.appButton())
                                Text(achievement.description)
                                    .font(.appCaption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let badge = achievement.badgeNumber {
                                Text("\(badge)")
                                    .font(.appCaption())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if achievementManager.achievements.count > 5 {
                        Text("... 还有 \(achievementManager.achievements.count - 5) 个成就")
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
        .sheet(isPresented: $showingAchievements) {
            AchievementsView()
        }
    }
}

#Preview {
    AchievementTestView()
}