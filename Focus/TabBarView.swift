import SwiftUI

struct CustomTabBarView: View {
    @State private var selectedTab: Tab = .home
    @State private var previousTab: Tab = .home

    enum Tab: Int, CaseIterable {
        case home = 1, tasks = 2, chart = 3, settings = 4
    }
    
    struct Transition: Hashable {
        let from: Int
        let to: Int
        
        enum Direction { case left, right }
        
        var direction: Direction { 
            to > from ? .right : .left 
        }
        
        var steps: Int { 
            abs(to - from) 
        }
    }
    
    
    // 获取切换路径（用于分段动画）
    private func transitionPath(from: Tab, to: Tab) -> [Tab] {
        guard from != to else { return [from] }
        let step = to.rawValue > from.rawValue ? 1 : -1
        let rawPath = Array(stride(from: from.rawValue, through: to.rawValue, by: step))
        return rawPath.compactMap { Tab(rawValue: $0) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 页面内容
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .tasks:
                    AchievementsView()
                case .chart:
                    StatisticsView()
                case .settings:
                    SettingsView()
                }
            }
            .ignoresSafeArea()

            // 自定义 TabBar
            TabBarView(
                selectedTab: $selectedTab,
                previousTab: previousTab,
                onTabChange: performTabTransition
            )
        }
        .ignoresSafeArea(.container, edges: .bottom) // 让整个视图忽略底部安全区域
        .ignoresSafeArea(.keyboard) // 忽略键盘，防止TabBar被推上去
    }
    
    // 执行智能Tab切换
    private func performTabTransition(to newTab: Tab) {
        guard newTab != selectedTab else { return }
        
        let transition = Transition(from: selectedTab.rawValue, to: newTab.rawValue)
        
        // 根据步数选择动画类型 - 与TabBarView保持一致
        switch transition.steps {
        case 1:
            // 相邻切换：轻微回弹
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.1)) {
                previousTab = selectedTab
                selectedTab = newTab
            }
        case 2:
            // 跨一个Tab：减小回弹效果
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.1)) {
                previousTab = selectedTab
                selectedTab = newTab
            }
        case 3:
            // 跨两个Tab：使用类似1步的回弹效果
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.1)) {
                previousTab = selectedTab
                selectedTab = newTab
            }
        default:
            // 其他情况
            let duration = 0.5 + Double(transition.steps - 1) * 0.1  // 减小时长增量
            withAnimation(.spring(response: duration, dampingFraction: 0.7, blendDuration: 0.1)) {
                previousTab = selectedTab
                selectedTab = newTab
            }
        }
        
        // 打印切换信息（调试用）
//        print("Tab切换: \(selectedTab) → \(newTab), 方向: \(transition.direction), 步数: \(transition.steps), 时长: \(String(format: "%.2f", duration))s")
    }
}

struct TabBarView: View {
    @Binding var selectedTab: CustomTabBarView.Tab
    let previousTab: CustomTabBarView.Tab
    let onTabChange: (CustomTabBarView.Tab) -> Void
    @State private var animatedPosition: Double = 1.0

    var body: some View {
        VStack(spacing: 0) {
            // 原有的TabBar内容 - 添加白色凹陷背景
            ZStack {
                // 底层白色背景
                Rectangle()
                    .fill(AppColors.Background.primary)
                    .frame(height: 48)
                
                // 波浪形TabBar背景
                WaveTabBarBackground(animatablePosition: animatedPosition)
                    .fill(AppColors.Semantic.darkBrown)
                    .frame(height: 48)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: -3)

                // Tab 按钮
                HStack {
                    tabButton(imageName: "home", tab: .home)
                    Spacer()
                    tabButton(imageName: "checkmark", tab: .tasks)
                    Spacer()
                    tabButton(imageName: "chart", tab: .chart)
                    Spacer()
                    tabButton(imageName: "setting", tab: .settings)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 0)
            }
            
            // 底部安全区域高度的纯色占位
            AppColors.Semantic.darkBrown
                .frame(height: 34) // 底部安全区域的典型高度
        }
        .ignoresSafeArea(.container, edges: .bottom) // 让整个TabBar从最底部开始
        .onAppear {
            animatedPosition = Double(selectedTab.rawValue)
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            // 计算动画时长和回弹参数
            let steps = abs(newTab.rawValue - oldTab.rawValue)
            
            // 根据步数调整动画参数
            let duration: Double
            let dampingFraction: Double
            let blendDuration: Double
            
            switch steps {
            case 1:
                // 相邻切换：轻微回弹
                duration = 0.5
                dampingFraction = 0.65
                blendDuration = 0.1
            case 2:
                // 跨一个Tab：减小回弹效果
                duration = 0.6
                dampingFraction = 0.7  // 增加阻尼系数，减小回弹
                blendDuration = 0.1
            case 3:
                // 跨两个Tab：使用类似1步的回弹效果
                duration = 0.7
                dampingFraction = 0.7  // 与1步相似的阻尼系数
                blendDuration = 0.1    // 与1步相似的混合时间
            default:
                // 其他情况
                duration = 0.5 + Double(steps - 1) * 0.1  // 减小时长增量
                dampingFraction = 0.7                     // 与其他情况保持一致
                blendDuration = 0.1                       // 与其他情况保持一致
            }
            
            // 执行带回弹效果的滚动动画
            withAnimation(.spring(
                response: duration,
                dampingFraction: dampingFraction,
                blendDuration: blendDuration
            )) {
                animatedPosition = Double(newTab.rawValue)
            }
        }
    }

    private func tabButton(imageName: String, tab: CustomTabBarView.Tab) -> some View {
        Button {
            onTabChange(tab)
        } label: {
            Image(selectedTab == tab ? imageName + "_fill" : imageName)
                .font(.system(size: 24, weight: .medium))
                .frame(width: 44, height: 44)
//                .offset(y: selectedTab == tab ? -6 : 0) // 选中时向下偏移到凹陷中
//                .scaleEffect(selectedTab == tab ? 1.1 : 1.0) // 选中时稍微放大
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1), value: selectedTab)
        }
    }
}

// 波浪形 Path - 向下凹陷效果，支持滚动动画
struct WaveTabBarBackground: Shape {
    var animatablePosition: Double // 动画位置，从1到4
    
    var animatableData: Double {
        get { animatablePosition }
        set { animatablePosition = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // 根据动画位置计算凹陷位置（支持中间过渡状态）
        let tabPositions: [Double: CGFloat] = [
            1.0: width * 0.13,   // home
            2.0: width * 0.375,  // tasks
            3.0: width * 0.625,  // chart
            4.0: width * 0.875   // settings
        ]
        
        // 线性插值计算当前位置
        let currentPosition = interpolatePosition(animatablePosition, positions: tabPositions, width: width)
        
        // 计算动画步数和总距离 - 用于调整动画参数
        let steps = abs(animatablePosition - round(animatablePosition))
        let totalDistance = abs(animatablePosition - Double(Int(round(animatablePosition))))
        
        // 使用平滑曲线函数计算动画参数调整系数
        let animationProgress = smootherStep(totalDistance)
        
        // 动态凹陷参数 - 使用平滑曲线函数调整
         let dipWidth: CGFloat = 110 + CGFloat(animationProgress) * 25  // 减小凹陷开口，移动时稍微变宽
         let dipDepth: CGFloat = 44 + CGFloat(animationProgress) * 12   // 移动时稍微变深
 
         let flatBottomWidth: CGFloat = 34 + CGFloat(animationProgress) * 8  // 底部平滑区域的宽度

        // 从左上角开始
        path.move(to: CGPoint(x: 0, y: 0))

        // 左侧到凹陷前的平线 - 开始位置提前
        let dipStartX = currentPosition - dipWidth / 2
        if dipStartX > 0 {
            path.addLine(to: CGPoint(x: dipStartX, y: 0))
        }
        
        // 创建向下凹陷的曲线 - 结束位置延后
        let dipEndX = currentPosition + dipWidth / 2
        let flatStartX = currentPosition - flatBottomWidth / 2
        let flatEndX = currentPosition + flatBottomWidth / 2
        
        // 凹陷的左侧曲线 - 从平面向下弯曲到平滑底部的开始
        path.addCurve(
            to: CGPoint(x: flatStartX, y: dipDepth),
            control1: CGPoint(x: dipStartX + 18, y: 0),
            control2: CGPoint(x: flatStartX - 18, y: dipDepth)
        )
        
        // 底部的平滑圆弧 - 修复控制点避免突出
        path.addCurve(
            to: CGPoint(x: flatEndX, y: dipDepth),
            control1: CGPoint(x: currentPosition - 18, y: dipDepth + 1),
            control2: CGPoint(x: currentPosition + 18, y: dipDepth + 1)
        )
        
        // 凹陷的右侧曲线 - 从平滑底部向上回到平面
        path.addCurve(
            to: CGPoint(x: dipEndX, y: 0),
            control1: CGPoint(x: flatEndX + 18, y: dipDepth),
            control2: CGPoint(x: dipEndX - 18, y: 0)
        )
        
        // 右侧到右边缘的平线
        if dipEndX < width {
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        
        // 右边缘向下到底部
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
    
    // 增强的插值计算位置 - 支持多步动画
    private func interpolatePosition(_ position: Double, positions: [Double: CGFloat], width: CGFloat) -> CGFloat {
        let clampedPosition = max(1.0, min(4.0, position))
        
        // 如果正好是整数位置，直接返回
        if let exactPosition = positions[clampedPosition] {
            return exactPosition
        }
        
        // 否则在两个位置之间插值
        let lowerKey = floor(clampedPosition)
        let upperKey = ceil(clampedPosition)
        
        guard let lowerValue = positions[lowerKey],
              let upperValue = positions[upperKey] else {
            return width * 0.13 // 默认值
        }
        
        // 计算步数
        let steps = upperKey - lowerKey
        let fraction = clampedPosition - lowerKey
        
        // 多步动画使用缓动函数增强过渡效果
         if steps > 1 {
             // 使用缓动函数 - 开始和结束时速度较慢，中间速度较快
             let easedFraction = easeInOutCubic(fraction)
             return lowerValue + (upperValue - lowerValue) * CGFloat(easedFraction)
         } else {
             // 单步使用线性插值
             return lowerValue + (upperValue - lowerValue) * CGFloat(fraction)
         }
    }
    
    // 缓动函数 - 三次方缓入缓出
    private func easeInOutCubic(_ x: Double) -> Double {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }
    

    
    // 平滑曲线函数 - 更平滑的过渡效果，减少颤抖
    private func smootherStep(_ x: Double) -> Double {
        // 确保x在[0,1]范围内
        let t = max(0, min(1, x))
        // 平滑曲线公式：6t^5 - 15t^4 + 10t^3
        return t * t * t * (t * (t * 6 - 15) + 10)
    }
}



#Preview {
    CustomTabBarView()
}
