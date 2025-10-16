//
//  FacebookSignInButton.swift
//  Focus
//
//  Created by Kiro on 2025/10/10.
//

import SwiftUI
import FBSDKLoginKit

// MARK: - 自定义Facebook登录按钮样式
struct CustomFacebookSignInButton: View {
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image("facebook_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                }
                
                Text(isLoading ? "登录中..." : "Continue with Facebook")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(red: 24/255, green: 119/255, blue: 242/255)) // Facebook蓝色
            .cornerRadius(20)
            .disabled(isLoading)
        }
    }
}

// MARK: - Facebook登录图标按钮（用于社交登录区域）
struct FacebookIconButton: View {
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.6)
                } else {
                    Image("facebook_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
            }
            .frame(width: 50, height: 50)
            .background(Color(red: 24/255, green: 119/255, blue: 242/255))
            .clipShape(Circle())
            .disabled(isLoading)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomFacebookSignInButton(action: {}, isLoading: false)
        CustomFacebookSignInButton(action: {}, isLoading: true)
        
        HStack(spacing: 20) {
            FacebookIconButton(action: {}, isLoading: false)
            FacebookIconButton(action: {}, isLoading: true)
        }
    }
    .padding()
}