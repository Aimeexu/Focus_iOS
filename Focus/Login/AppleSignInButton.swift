//
//  AppleSignInButton.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import SwiftUI
import AuthenticationServices

struct AppleSignInButton: UIViewRepresentable {
    let onRequest: () -> Void
    let onCompletion: (Result<AuthResponse, Error>) -> Void
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .continue,
            authorizationButtonStyle: .black
        )
        
        button.cornerRadius = 20
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleAppleSignIn),
            for: .touchUpInside
        )
        
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // 不需要更新
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: AppleSignInButton
        
        init(_ parent: AppleSignInButton) {
            self.parent = parent
        }
        
        @objc func handleAppleSignIn() {
            parent.onRequest()
            
            Task {
                do {
                    let result = try await AppleSignInService.shared.signInWithApple()
                    await MainActor.run {
                        parent.onCompletion(.success(result))
                    }
                } catch {
                    await MainActor.run {
                        parent.onCompletion(.failure(error))
                    }
                }
            }
        }
    }
}

// MARK: - 自定义Apple登录按钮样式
struct CustomAppleSignInButton: View {
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
                    Image(systemName: "applelogo")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(isLoading ? "登录中..." : "Continue with Apple")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black)
            .cornerRadius(20)
            .disabled(isLoading)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomAppleSignInButton(action: {}, isLoading: false)
        CustomAppleSignInButton(action: {}, isLoading: true)
    }
    .padding()
}