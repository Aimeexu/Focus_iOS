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
    
    // 根据步数自适应动画时长
    private func animationDuration(from: Tab, to: Tab) -> Double {
        let steps = abs(to.rawValue - from.rawValue)
        return 0.4 + Double(steps - 1) * 0.15  // 增加基础时间，让移动更明显
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
        let duration = animationDuration(from: selectedTab, to: newTab)
        
        // 根据步数选择动画类型
        if transition.steps == 1 {
            // 相邻切换：使用较慢的弹簧动画
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                previousTab = selectedTab
                selectedTab = newTab
            }
        } else if transition.steps == 2 {
            // 跨一个Tab：使用中等速度动画
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                previousTab = selectedTab
                selectedTab = newTab
            }
        } else {
            // 跨多个Tab：使用较慢的平滑动画
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                previousTab = selectedTab
                selectedTab = newTab
            }
        }
        
        // 打印切换信息（调试用）
        print("Tab切换: \(selectedTab) → \(newTab), 方向: \(transition.direction), 步数: \(transition.steps), 时长: \(String(format: "%.2f", duration))s")
    }
}

struct TabBarView: View {
    @Binding var selectedTab: CustomTabBarView.Tab
    let previousTab: CustomTabBarView.Tab
    let onTabChange: (CustomTabBarView.Tab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 原有的TabBar内容 - 添加白色凹陷背景
            ZStack {
                // 底层白色背景
                Rectangle()
                    .fill(AppColors.Background.primary)
                    .frame(height: 48)
                
                // 波浪形TabBar背景
                WaveTabBarBackground(selectedTab: selectedTab, previousTab: previousTab)
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
    }

    private func tabButton(imageName: String, tab: CustomTabBarView.Tab) -> some View {
        Button {
            onTabChange(tab)
        } label: {
            Image(selectedTab == tab ? imageName + "_fill" : imageName)
                .font(.system(size: 24, weight: .medium))
                .frame(width: 44, height: 44)
                .offset(y: selectedTab == tab ? -6 : 0) // 选中时向下偏移到凹陷中
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTab)
        }
    }
}

// 波浪形 Path - 向下凹陷效果
struct WaveTabBarBackground: Shape {
    let selectedTab: CustomTabBarView.Tab
    let previousTab: CustomTabBarView.Tab
    
    var animatableData: Double {
        get { Double(selectedTab.rawValue) }
        set { 
            // 这里不需要设置，因为我们通过外部动画控制
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // 根据选中的tab确定凹陷位置
        let tabPositions: [CustomTabBarView.Tab: CGFloat] = [
            .home: width * 0.13,
            .tasks: width * 0.375,
            .chart: width * 0.625,
            .settings: width * 0.875
        ]
        
        let selectedPosition = tabPositions[selectedTab] ?? width * 0.125
        let transition = CustomTabBarView.Transition(from: previousTab.rawValue, to: selectedTab.rawValue)
        
        // 根据切换方向和步数调整动画参数
        let dipWidth: CGFloat = transition.steps > 1 ? 140 : 130  // 远距离切换时凹陷更宽
        let dipDepth: CGFloat = transition.steps > 2 ? 48 : 44   // 超远距离切换时凹陷更深

        let flatBottomWidth: CGFloat = 34  // 底部平滑区域的宽度

        // 从左上角开始
        path.move(to: CGPoint(x: 0, y: 0))

        // 左侧到凹陷前的平线 - 开始位置提前
        let dipStartX = selectedPosition - dipWidth / 2
        if dipStartX > 0 {
            path.addLine(to: CGPoint(x: dipStartX, y: 0))
        }
        
        // 创建向下凹陷的曲线 - 结束位置延后
        let dipEndX = selectedPosition + dipWidth / 2
        let flatStartX = selectedPosition - flatBottomWidth / 2
        let flatEndX = selectedPosition + flatBottomWidth / 2
        
        // 凹陷的左侧曲线 - 从平面向下弯曲到平滑底部的开始
        path.addCurve(
            to: CGPoint(x: flatStartX, y: dipDepth),
            control1: CGPoint(x: dipStartX + 18, y: 0),
            control2: CGPoint(x: flatStartX - 18, y: dipDepth)
        )
        
        // 底部的平滑圆弧 - 稍微调整控制点让底部更圆润
        path.addCurve(
            to: CGPoint(x: flatEndX, y: dipDepth),
            control1: CGPoint(x: selectedPosition - 18, y: dipDepth + 3),
            control2: CGPoint(x: selectedPosition + 18, y: dipDepth + 3)
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
}



#Preview {
    CustomTabBarView()
}
