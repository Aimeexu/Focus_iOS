//
//  RemoteImageView.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import SwiftUI
import Combine

/// 增强的远程图片加载组件，支持缓存、错误处理和重试机制
struct RemoteImageView: View {
    let url: String
    let placeholder: String
    let width: CGFloat?
    let height: CGFloat?
    let contentMode: ContentMode
    
    @StateObject private var loader = ImageLoader()
    
    init(
        url: String,
        placeholder: String = "photo",
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        contentMode: ContentMode = .fit
    ) {
        self.url = url
        self.placeholder = placeholder
        self.width = width
        self.height = height
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if loader.isLoading {
                ProgressView()
                    .frame(width: width, height: height)
            } else {
                // 显示占位符或错误状态
                VStack {
                    Image(systemName: loader.hasError ? "exclamationmark.triangle" : placeholder)
                        .foregroundColor(loader.hasError ? .red : .gray)
                    
                    if loader.hasError {
                        Button("重试") {
                            loader.loadImage(from: url)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .frame(width: width, height: height)
            }
        }
        .onAppear {
            loader.loadImage(from: url)
        }
    }
}

/// 图片加载器，负责下载、缓存和管理图片
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var hasError = false
    
    private var cancellables = Set<AnyCancellable>()
    private static let cache = NSCache<NSString, UIImage>()
    
    init() {
        // 配置缓存
        Self.cache.countLimit = 100
        Self.cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func loadImage(from urlString: String) {
        // 重置状态
        hasError = false
        
        // 检查缓存
        let cacheKey = NSString(string: urlString)
        if let cachedImage = Self.cache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.image = cachedImage
                self.isLoading = false
            }
            return
        }
        
        // 验证URL
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.hasError = true
                self.isLoading = false
            }
            return
        }
        
        // 开始加载
        isLoading = true
        image = nil
        
        // 取消之前的请求
        cancellables.removeAll()
        
        // 创建URL请求
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .returnCacheDataElseLoad
        
        // 添加User-Agent以避免某些服务器拒绝请求
        request.setValue("Focus-iOS-App/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                self?.isLoading = false
                
                if let loadedImage = loadedImage {
                    self?.image = loadedImage
                    self?.hasError = false
                    
                    // 缓存图片
                    Self.cache.setObject(loadedImage, forKey: cacheKey)
                    
                    print("✅ 图片加载成功: \(urlString)")
                } else {
                    self?.hasError = true
                    print("❌ 图片加载失败: \(urlString)")
                }
            }
            .store(in: &cancellables)
    }
    
    /// 清除缓存
    static func clearCache() {
        cache.removeAllObjects()
    }
    
    /// 获取缓存大小
    static func getCacheSize() -> Int {
        return cache.totalCostLimit
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: 20) {
        Text("远程图片加载测试")
            .font(.title)
        
        // 测试有效的图片URL
        RemoteImageView(
            url: "http://www.cdbolv.com/assets/file/fp/hog.png",
            placeholder: "pawprint",
            width: 100,
            height: 100
        )
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        
        // 测试无效的图片URL
        RemoteImageView(
            url: "http://invalid-url.com/image.png",
            placeholder: "photo",
            width: 100,
            height: 100
        )
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        
        Spacer()
    }
    .padding()
}