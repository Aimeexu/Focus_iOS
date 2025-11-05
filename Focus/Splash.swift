//
//  Splash.swift
//  Focus
//
//  Created by Jessica mini on 2025/11/5.
//

import Foundation
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                // ✅ 主页面
                ContentView()
            } else {
                // ✅ 启动画面
                ZStack {
                    Image("launch")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    LottieView(name: "loading", loopMode: .playOnce)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .onAppear {
                    // 动画时长后切换主页面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        isActive = true
                    }
                }
            }
        }
    }
}
