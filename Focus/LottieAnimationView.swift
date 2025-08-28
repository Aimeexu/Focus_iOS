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
            loadNetworkAnimation(animationView: animationView, url: animationURL)
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
                    print("✅ 网络动画加载成功")
                }
            } catch {
                print("❌ 解析动画JSON失败: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// MARK: - 专注计时动画视图
struct ConcentrationAnimationView: View {
    @StateObject private var lottieAnimationManager = LottieAnimationManager.shared
    let size: CGSize
    
    init(size: CGSize = CGSize(width: 200, height: 200)) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            if lottieAnimationManager.isAnimationLoading {
                // 加载中状态
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("加载动画中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            } else if let animationURL = lottieAnimationManager.currentAnimationURL {
                // 显示网络动画
                NetworkLottieView(
                    animationURL: animationURL,
                    loopMode: .loop,
                    animationSpeed: 1.0
                )
            } else {
                // 默认状态 - 显示占位符
                VStack {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("暂无动画")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .background(Color.clear)
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