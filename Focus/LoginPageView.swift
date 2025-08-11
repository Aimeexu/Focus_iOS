//
//  LoginPageView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct LoginPageView: View {
    var body: some View {
        ZStack {
            // 背景图片（你可以替换成你的背景图）
            Image("login_background") // 替换成你的背景图片名称
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 如果没有背景图，可以用这个渐变色作为临时背景
            LinearGradient(
                colors: [Color.brown.opacity(0.8), Color.green.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 底部登录区域
                VStack(spacing: 24) {
                    // Continue with Apple 按钮
                    Button(action: {
                        // Apple登录逻辑
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "applelogo")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("Continue with Apple")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 40)
                    
                    // 分隔线和"or"文字
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 40)
                    
                    // 社交登录按钮
                    HStack(spacing: 24) {
                        // Facebook按钮
                        Button(action: {
                            // Facebook登录逻辑
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 50, height: 50)
                                
                                Text("f")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Google按钮
                        Button(action: {
                            // Google登录逻辑
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                
                                Text("G")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.bottom, 60) // 给底部留出安全区域空间
            }
        }
    }
}

#Preview {
    LoginPageView()
}