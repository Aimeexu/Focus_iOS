import SwiftUI

struct CustomTabBarView: View {
    @State private var selectedTab: Tab = .home
    @State private var currentOffsetX: CGFloat = 0

    enum Tab: CaseIterable {
        case home, tasks, chart, settings
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .tasks:
                    Color.white.overlay(Text("Tasks").font(.largeTitle))
                case .chart:
                    StatisticsView()
                case .settings:
                    Color.white.overlay(Text("Settings").font(.largeTitle))
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    GeometryReader { geometry in
                        let tabWidth = geometry.size.width / CGFloat(Tab.allCases.count)

                        WaveTabBarBackground()
                            .fill(Color.brown)
                            .frame(width: geometry.size.width, height: 60)
                            .offset(x: currentOffsetX)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentOffsetX)

                        HStack {
                            ForEach(Tab.allCases, id: \.self) { tab in
                                Spacer()
                                tabButton(for: tab, tabWidth: tabWidth)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(height: 60)
                    .clipped()
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: -3)
                }

                Color.brown
                    .frame(height: 34) // safe area
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .ignoresSafeArea(.keyboard)
    }

    private func tabButton(for tab: Tab, tabWidth: CGFloat) -> some View {
        let icons: [Tab: String] = [
            .home: "house",
            .tasks: "checkmark.square",
            .chart: "chart.bar",
            .settings: "gearshape"
        ]

        return Button {
            let currentIndex = Tab.allCases.firstIndex(of: selectedTab) ?? 0
            let newIndex = Tab.allCases.firstIndex(of: tab) ?? 0
            let diff = CGFloat(newIndex - currentIndex)

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentOffsetX += diff * tabWidth
                selectedTab = tab
            }
        } label: {
            Image(systemName: icons[tab] ?? "circle")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(selectedTab == tab ? Color.green : Color.white)
                .frame(width: 44, height: 44)
                .offset(y: selectedTab == tab ? -6 : 0)
        }
    }
}

struct WaveTabBarBackground: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        let tabCount: CGFloat = 4
        let tabWidth = width / tabCount
        let dipWidth: CGFloat = 130
        let dipDepth: CGFloat = 44
        let flatBottomWidth: CGFloat = 34

        // 默认凹陷在第一个 tab（后续通过 offset 移动）
        let selectedPosition = tabWidth * 0.125

        let dipStartX = selectedPosition - dipWidth / 2
        let dipEndX = selectedPosition + dipWidth / 2
        let flatStartX = selectedPosition - flatBottomWidth / 2
        let flatEndX = selectedPosition + flatBottomWidth / 2

        path.move(to: .zero)

        if dipStartX > 0 {
            path.addLine(to: CGPoint(x: dipStartX, y: 0))
        }

        path.addCurve(
            to: CGPoint(x: flatStartX, y: dipDepth),
            control1: CGPoint(x: dipStartX + 18, y: 0),
            control2: CGPoint(x: flatStartX - 18, y: dipDepth)
        )

        path.addCurve(
            to: CGPoint(x: flatEndX, y: dipDepth),
            control1: CGPoint(x: selectedPosition - 18, y: dipDepth + 3),
            control2: CGPoint(x: selectedPosition + 18, y: dipDepth + 3)
        )

        path.addCurve(
            to: CGPoint(x: dipEndX, y: 0),
            control1: CGPoint(x: flatEndX + 18, y: dipDepth),
            control2: CGPoint(x: dipEndX - 18, y: 0)
        )

        if dipEndX < width {
            path.addLine(to: CGPoint(x: width, y: 0))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

// 示例页面占位
struct HomeView: View {
    var body: some View {
        Color.blue.overlay(Text("Home").font(.largeTitle).foregroundColor(.white))
    }
}

struct StatisticsView: View {
    var body: some View {
        Color.green.overlay(Text("Chart").font(.largeTitle).foregroundColor(.white))
    }
}

#Preview {
    CustomTabBarView()
}
