//
//  LottieAnimationView.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import SwiftUI
import Lottie

// MARK: - 网络Lottie动画视图
struct NetworkLottieView: UIViewRepresentable {
    let animationURL: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    
    init(animationURL: String, loopMode: LottieLoopMode = .loop, animationSpeed: CGFloat = 1.0) {
        self.animationURL = animationURL
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        let animationView = LottieAnimationView()
        
        // 配置动画视图
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        
        // 添加到容器
        containerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        // 加载网络动画
        loadNetworkAnimation(animationView: animationView, url: animationURL)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 如果URL改变，重新加载动画
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            // 获取当前动画视图的URL标识
            let currentURL = animationView.accessibilityIdentifier ?? ""
            if currentURL != animationURL {
                print("🔄 动画URL改变，重新加载: \(animationURL)")
                loadNetworkAnimation(animationView: animationView, url: animationURL)
            }
        }
    }
    
    private func loadNetworkAnimation(animationView: LottieAnimationView, url: String) {
        guard let url = URL(string: url) else {
            print("❌ 无效的动画URL: \(url)")
            return
        }
        
        print("🎬 开始加载网络动画: \(url)")
        
        // 使用URLSession下载动画数据
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ 下载动画失败: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ 动画数据为空")
                return
            }
            
            do {
                // 解析JSON数据
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                DispatchQueue.main.async {
                    // 创建动画
                    let animation = try? LottieAnimation.from(data: data)
                    animationView.animation = animation
                    animationView.play()
                    // 使用accessibilityIdentifier来标记当前加载的URL
                    animationView.accessibilityIdentifier = url.absoluteString
                    print("✅ 网络动画加载成功: \(url.absoluteString)")
                }
            } catch {
                print("❌ 解析动画JSON失败: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// MARK: - 专注计时动画视图
struct ConcentrationAnimationView: View {
    @StateObject private var concentrationService = ConcentrationService.shared
    let size: CGSize
    let showStateIndicator: Bool
    
    // 为成人态 Reveal 增加本地动画状态
    @State private var isRevealingAdult = false
    @State private var revealProgress: CGFloat = 0.0
    @State private var shouldShowChild = true // 控制child层的显示
    private let revealDuration: Double = 0.8
    private let childHideDuration: Double = 0.3 // child消失的时间点
    
    init(size: CGSize = CGSize(width: 200, height: 200), showStateIndicator: Bool = false) {
        self.size = size
        self.showStateIndicator = showStateIndicator
    }
    
    var body: some View {
        ZStack {
            // 正常显示动画
            if let animationURL = concentrationService.currentLottieAnimationURL {
                NetworkLottieView(
                    animationURL: animationURL,
                    loopMode: .loop,
                    animationSpeed: 1.0
                )
                .id(animationURL)
                .opacity(isRevealingAdult ? 0 : 1) // reveal时隐藏这一层
                
                // 状态指示器
                if showStateIndicator {
                    VStack {
                        HStack {
                            VStack {
                                Text(concentrationService.currentAnimationState.displayName)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(concentrationService.currentAnimationState == .child ? Color.green : Color.orange)
                                    .cornerRadius(12)
                            }
                            .padding(.leading, 8)
                            .padding(.top, 8)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            } else {
                // 默认状态 - 显示占位符
                VStack {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No Animation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Reveal动画层（仅在切换到adult时显示）
            if isRevealingAdult,
               let childURL = concentrationService.getAnimationURL(for: .child),
               let adultURL = concentrationService.getAnimationURL(for: .adult) {
    
                GeometryReader { geo in
                    let maxRadius = sqrt(pow(geo.size.width / 2, 2) + pow(geo.size.height / 2, 2))
                    let currentRadius = maxRadius * revealProgress
    
                    ZStack {
                        // 底层：child 持续播放（在0.3秒后隐藏）
                        if shouldShowChild {
                            NetworkLottieView(
                                animationURL: childURL,
                                loopMode: .loop,
                                animationSpeed: 1.0
                            )
                            .id(childURL)
                        }
    
                        // 顶层：adult，通过圆形遮罩从中心放大 Reveal
                        NetworkLottieView(
                            animationURL: adultURL,
                            loopMode: .loop,
                            animationSpeed: 1.0
                        )
                        .id(adultURL)
                        .mask(
                            Circle()
                                .frame(width: currentRadius * 2, height: currentRadius * 2)
                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        )
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .background(Color.clear)
        // 监听动画态切换到 adult，触发 Reveal
        .onChange(of: concentrationService.currentAnimationState) { newState in
            guard newState == .adult else { return }
            
            // 启动 reveal 动画
            isRevealingAdult = true
            shouldShowChild = true
            revealProgress = 0.0
            
            withAnimation(.easeInOut(duration: revealDuration)) {
                revealProgress = 1.0
            }
            
            // 0.3秒后隐藏child层
            DispatchQueue.main.asyncAfter(deadline: .now() + childHideDuration) {
                shouldShowChild = false
            }
            
            // 0.8秒后结束reveal，显示正常的adult层
            DispatchQueue.main.asyncAfter(deadline: .now() + revealDuration) {
                isRevealingAdult = false
            }
        }
    }
}

// MARK: - 动画测试视图
struct LottieAnimationTestView: View {
    @State private var testURL = "http://www.cdbolv.com/assets/file/fp/owl_adult.json"
    @StateObject private var lottieAnimationManager = LottieAnimationManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Lottie动画测试")
                    .font(.title)
                    .padding()
                
                // 动画显示区域
                ConcentrationAnimationView(size: CGSize(width: 300, height: 300))
                    .border(Color.gray.opacity(0.3), width: 1)
                
                // 测试按钮
                VStack(spacing: 12) {
                    Button("加载猫头鹰成体动画") {
                        Task {
                            await lottieAnimationManager.loadAnimation(from: "http://www.cdbolv.com/assets/file/fp/owl_adult.json")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("加载猫头鹰幼体动画") {
                        Task {
                            await lottieAnimationManager.loadAnimation(from: "http://www.cdbolv.com/assets/file/fp/owl_child.json")
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("加载猫头鹰睡眠动画") {
                        Task {
                            await lottieAnimationManager.loadAnimation(from: "http://www.cdbolv.com/assets/file/fp/owl_sleep.json")
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("清除动画") {
                        lottieAnimationManager.clearAnimation()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("动画测试")
        }
    }
}

#Preview {
    LottieAnimationTestView()
}
