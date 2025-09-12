//
//  StatisticsView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct StatisticsView: View {
    @State private var selectedPeriod: TimePeriod = .day

    enum TimePeriod: String, CaseIterable {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
    }

    // 示例数据
    let focusData = [
        FocusData(category: "Study", minutes: 53, color: AppColors.Brand.primary),
        FocusData(category: "Work", minutes: 210, color: AppColors.Semantic.lightGray),
        FocusData(category: "Read", minutes: 200, color: AppColors.Semantic.beige)
    ]

    var totalMinutes: Int {
        focusData.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        ZStack {
            AppColors.Background.primary.ignoresSafeArea()

            VStack(spacing: 0) {
                // 图表内容区域
                if selectedPeriod == .day {
                    pieChartSection
                } else {
                    VStack(spacing: 0) {
                        barChartSection
                            .padding(.top, 30)

                        ZStack {
                            PieChartView(data: focusData, total: totalMinutes)
                                .frame(width: 180, height: 180)

                            Text("\(totalMinutes)")
                                .font(.appNumber(size: 36))
                                .foregroundColor(AppColors.Text.primary)

                            ForEach(Array(focusData.enumerated()), id: \.offset) { index, data in
                                PieChartLabel(
                                    data: data,
                                    angle: labelAngle(for: index),
                                    radius: 120
                                )
                            }
                        }
                        .padding(.top, 30)

                        Spacer()
                    }
                }
            }
        }
        // ✅ 把 TabBar 固定在安全区域顶部
        .safeAreaInset(edge: .top) {
            HStack(spacing: 0) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                    }) {
                        Text(period.rawValue)
                            .font(.appButton(size: 16))
                            .foregroundColor(selectedPeriod == period ? AppColors.Text.inverse : AppColors.Text.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(selectedPeriod == period ? AppColors.Semantic.error : Color.clear)
                            .cornerRadius(selectedPeriod == period ? 8 : 0)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 78)
            .background(AppColors.Background.primary)
        }
        .onAppear {
            Task {
                do {
                    let response = try await NetworkManager.shared.getConcentrationStatistics(
                        period: "MONTH",
                        month: 9,
                        year: 2025
                    )
                    print("📊 专注统计返回: \(response)")
                } catch {
                    print("❌ 检查海报兑换资格失败: \(error)")
                }
            }
        }
    }

    private var pieChartSection: some View {
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                RoundedDonutChartView(data: focusData, total: totalMinutes)
                    .frame(width: 180, height: 180)

                Text("\(totalMinutes)")
                    .font(.appNumber(size: 36))
                    .foregroundColor(AppColors.Text.primary)

                ForEach(Array(focusData.enumerated()), id: \.offset) { index, data in
                    PieChartLabel(
                        data: data,
                        angle: labelAngle(for: index),
                        radius: 120
                    )
                }
            }

            Spacer()

            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("Total Focus")
                        .font(.appBody(size: 18))
                        .foregroundColor(AppColors.Text.secondary)
                    Text("\(totalMinutes) m")
                        .font(.appNumber(size: 24))
                        .foregroundColor(AppColors.Text.primary)
                }

                Rectangle()
                    .fill(AppColors.Brand.primary)
                    .frame(width: 2, height: 40)

                VStack(spacing: 8) {
                    Text("Focus Sessions")
                        .font(.appBody(size: 18))
                        .foregroundColor(AppColors.Text.secondary)
                    Text("60")
                        .font(.appNumber(size: 24))
                        .foregroundColor(AppColors.Text.primary)
                }
            }
            .padding(.bottom, 200)
        }
    }

    

    struct PieChartView: View {
        let data: [FocusData]
        let total: Int
        private let gapDegrees: Double = 2   // 切片之间的间隙角度
        private let innerRatio: CGFloat = 0.6
        private let cornerRadius: CGFloat = 12

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        let start = startAngle(for: index)
                        let end = endAngle(for: index)

                        RoundedPieSlice(
                            startAngle: start,
                            endAngle: end,
                            innerRadiusRatio: innerRatio,
                            cornerRadius: cornerRadius
                        )
                        .fill(item.color)
                    }
                }
            }
        }

        private func startAngle(for index: Int) -> Angle {
            let previous = data.prefix(index).reduce(0) { $0 + $1.minutes }
            let degrees = Double(previous) / Double(total) * 360 - 90 + Double(index) * gapDegrees
            return Angle(degrees: degrees)
        }

        private func endAngle(for index: Int) -> Angle {
            let current = data[index].minutes
            let previous = data.prefix(index).reduce(0) { $0 + $1.minutes }
            let degrees = Double(previous + current) / Double(total) * 360 - 90 + Double(index) * gapDegrees
            return Angle(degrees: degrees)
        }
    }

    struct RoundedPieSlice: Shape {
        let startAngle: Angle
        let endAngle: Angle
        let innerRadiusRatio: CGFloat
        let cornerRadius: CGFloat

        func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let innerRadius = radius * innerRadiusRatio

            var path = Path()

            let start = CGFloat(startAngle.radians)
            let end = CGFloat(endAngle.radians)

            // 外圆起点终点
            let p1 = CGPoint(x: center.x + cos(start) * radius,
                             y: center.y + sin(start) * radius)
            let p2 = CGPoint(x: center.x + cos(end) * radius,
                             y: center.y + sin(end) * radius)

            // 内圆起点终点
            let p3 = CGPoint(x: center.x + cos(end) * innerRadius,
                             y: center.y + sin(end) * innerRadius)
            let p4 = CGPoint(x: center.x + cos(start) * innerRadius,
                             y: center.y + sin(start) * innerRadius)

            // 外圆弧
            path.move(to: p1)
            path.addArc(center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false)

            // 外角过渡
            path.addArc(tangent1End: p2, tangent2End: p3, radius: cornerRadius)
//
//            // 内圆弧
//            path.addArc(center: center,
//                        radius: innerRadius,
//                        startAngle: endAngle,
//                        endAngle: startAngle,
//                        clockwise: true)
//
//            // 内角过渡
//            path.addArc(tangent1End: p4, tangent2End: p1, radius: cornerRadius)
//
            path.closeSubpath()
            return path
        }
    }

    // 条形图部分
    private var barChartSection: some View {
        let weeklyData = [
            BarData(day: "Mon", value: 90),
            BarData(day: "Tue", value: 15),
            BarData(day: "Wed", value: 22),
            BarData(day: "Thu", value: 78),
            BarData(day: "Fri", value: 62),
            BarData(day: "Sat", value: 20),
            BarData(day: "Sun", value: 88)
        ]

        let maxValue = (weeklyData.map { $0.value }.max() ?? 100)
        let totalFocus = weeklyData.reduce(0) { $0 + $1.value }
        let dailyAverage = totalFocus / weeklyData.count

        // 计算 5 等分
        let step = maxValue / 5
        let yAxisValues = (0...5).map { $0 * step }  // [0, step, 2step, ..., maxValue]

        return VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                // 左侧刻度
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(yAxisValues.reversed(), id: \.self) { value in
                        Text("\(value)")
                            .font(.appNumber(size: 12))
                            .foregroundColor(AppColors.Text.secondary)
                            .frame(height: 160 / 5, alignment: .top) // 160 高度对应 5 等分
                    }
                }
                .frame(width: 30)
                .padding(.trailing, 5)

                GeometryReader { geo in
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(weeklyData, id: \.day) { data in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.Brand.primary)
                                    .frame(
                                        width: 20,
                                        height: geo.size.height * CGFloat(data.value) / CGFloat(maxValue)
                                    )

                                Text(data.day)
                                    .font(.appBody(size: 12))
                                    .foregroundColor(AppColors.Text.primary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(height: 160)
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Total Focus")
                        .font(.appBody(size: 14))
                        .foregroundColor(AppColors.Text.secondary)
                    Text("\(totalFocus) m")
                        .font(.appNumber(size: 18))
                        .foregroundColor(AppColors.Text.primary)
                }
                .frame(maxWidth: .infinity)

                Rectangle().fill(AppColors.Brand.primary).frame(width: 1, height: 30)

                VStack(spacing: 4) {
                    Text("Daily Focus")
                        .font(.appBody(size: 14))
                        .foregroundColor(AppColors.Text.secondary)
                    Text("\(dailyAverage) m")
                        .font(.appNumber(size: 18))
                        .foregroundColor(AppColors.Text.primary)
                }
                .frame(maxWidth: .infinity)

                Rectangle().fill(AppColors.Brand.primary).frame(width: 1, height: 30)

                VStack(spacing: 4) {
                    Text("Focus Sessions")
                        .font(.appBody(size: 14))
                        .foregroundColor(AppColors.Text.secondary)
                    Text("60")
                        .font(.appNumber(size: 18))
                        .foregroundColor(AppColors.Text.primary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 50)
        }
    }

    private func labelAngle(for index: Int) -> Angle {
        let previousTotal = focusData.prefix(index).reduce(0) { $0 + $1.minutes }
        let currentValue = focusData[index].minutes
        let midPoint = previousTotal + currentValue / 2
        return Angle(degrees: Double(midPoint) / Double(totalMinutes) * 360 - 90)
    }
}

struct FocusData {
    let category: String
    let minutes: Int
    let color: Color
}

struct PieChartView: View {
    let data: [FocusData]
    let total: Int
    private let gapDegrees: Double = 3

    var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                PieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: item.color
                )
            }
        }
    }

    private func startAngle(for index: Int) -> Angle {
        let previousTotal = data.prefix(index).reduce(0) { $0 + $1.minutes }
        let baseAngle = Double(previousTotal) / Double(total) * (360 - Double(data.count) * gapDegrees) - 90
        let gapOffset = Double(index) * gapDegrees
        return Angle(degrees: baseAngle + gapOffset)
    }

    private func endAngle(for index: Int) -> Angle {
        let currentValue = data[index].minutes
        let previousTotal = data.prefix(index).reduce(0) { $0 + $1.minutes }
        let baseAngle = Double(previousTotal + currentValue) / Double(total) * (360 - Double(data.count) * gapDegrees) - 90
        let gapOffset = Double(index) * gapDegrees
        return Angle(degrees: baseAngle + gapOffset)
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                let innerRadius = radius * 0.6
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

struct PieChartLabel: View {
    let data: FocusData
    let angle: Angle
    let radius: CGFloat

    var body: some View {
        let x = cos(angle.radians) * radius
        let y = sin(angle.radians) * radius

        VStack(spacing: 2) {
            Text(data.category)
                .font(.appCallout())
                .foregroundColor(AppColors.Text.primary)
            Text("\(data.minutes)")
                .font(.appNumber(size: 14))
                .foregroundColor(AppColors.Text.secondary)
        }
        .offset(x: x, y: y)
    }
}

#Preview {
    StatisticsView()
}

// 注意：DonutChartView 要放在 StatisticsView 外面
struct RoundedDonutChartView: View {
    let data: [FocusData]
    let total: Int
    private let lineWidth: CGFloat = 40      // 环形厚度
    private let gapDegrees: Double = 26       // 每个扇形之间的间隙角度

    var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2

            ZStack {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let start = startAngle(for: index)
                    let end = endAngle(for: index)

                    Circle()
                        .trim(from: CGFloat(start.degrees / 360),
                              to: CGFloat(end.degrees / 360))
                        .stroke(item.color,
                                style: StrokeStyle(
                                    lineWidth: lineWidth,
                                    lineCap: .round
                                ))
                        .rotationEffect(.degrees(-90)) // 让 0 度朝上
                    
                }
            }
        }
    }

    // 起始角度（加半个 gap）
    private func startAngle(for index: Int) -> Angle {
        let sum = data.prefix(index).reduce(0) { $0 + $1.minutes }
        let degrees = Double(sum) / Double(total) * 360 + gapDegrees / 2
        return .degrees(degrees)
    }

    // 结束角度（减半个 gap）
    private func endAngle(for index: Int) -> Angle {
        let sum = data.prefix(index + 1).reduce(0) { $0 + $1.minutes }
        let degrees = Double(sum) / Double(total) * 360 - gapDegrees / 2
        return .degrees(degrees)
    }
}
