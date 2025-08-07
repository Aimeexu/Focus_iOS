import SwiftUI

struct CustomTabBarView: View {
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, tasks, chart, settings
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 页面内容
            Group {
                switch selectedTab {
                case .home:
                    Color.white
                case .tasks:
                    Color.white
                case .chart:
                    Color.white
                case .settings:
                    Color.white
                }
            }
            .ignoresSafeArea()

            // 自定义 TabBar
            TabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.container, edges: .bottom) // 让整个视图忽略底部安全区域
    }
}

struct TabBarView: View {
    @Binding var selectedTab: CustomTabBarView.Tab

    var body: some View {
        VStack(spacing: 0) {
            // 原有的TabBar内容 - 保持不变
            ZStack {
                WaveTabBarBackground(selectedTab: selectedTab)
                    .fill(Color.brown)
                    .frame(height: 48)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: -3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.2), value: selectedTab)

                // Tab 按钮
                HStack {
                    tabButton(imageName: "house", tab: .home)
                    Spacer()
                    tabButton(imageName: "checkmark.square", tab: .tasks)
                    Spacer()
                    tabButton(imageName: "chart.bar", tab: .chart)
                    Spacer()
                    tabButton(imageName: "gearshape", tab: .settings)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 0)
            }
            
            // 底部安全区域高度的纯色占位
            Color.brown
                .frame(height: 34) // 底部安全区域的典型高度
        }
        .ignoresSafeArea(.container, edges: .bottom) // 让整个TabBar从最底部开始
    }

    private func tabButton(imageName: String, tab: CustomTabBarView.Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: imageName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(selectedTab == tab ? Color.green : Color.white)
                .frame(width: 44, height: 44)
                .offset(y: selectedTab == tab ? -6 : 0) // 选中时向下偏移到凹陷中
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
        }
    }
}

// 波浪形 Path - 向下凹陷效果
struct WaveTabBarBackground: Shape {
    let selectedTab: CustomTabBarView.Tab
    
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
        let dipWidth: CGFloat = 130  // 增加凹陷的宽度，让开始和结束位置更宽
        let dipDepth: CGFloat = 44  // 凹陷的深度
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
