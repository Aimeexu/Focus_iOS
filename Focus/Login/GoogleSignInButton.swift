//
//  GoogleSignInButton.swift
//  Focus
//
//  Created by Kiro on 2025/10/16.
//

import SwiftUI
import GoogleSignIn

// MARK: - Google登录按钮
struct GoogleSignInButton: View {
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
                    Image("google_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                }
                
                Text(isLoading ? "登录中..." : "Continue with Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(red: 0.26, green: 0.52, blue: 0.96)) // Google蓝色
            .cornerRadius(20)
            .disabled(isLoading)
        }
    }
}

// MARK: - Google图标按钮（用于社交登录区域）
struct GoogleIconButton: View {
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(0.8)
                } else {
                    Image("google_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
            }
            .frame(width: 50, height: 50)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
            .disabled(isLoading)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GoogleSignInButton(action: {}, isLoading: false)
        GoogleSignInButton(action: {}, isLoading: true)
        
        HStack(spacing: 20) {
            GoogleIconButton(action: {}, isLoading: false)
            GoogleIconButton(action: {}, isLoading: true)
        }
    }
    .padding()
}