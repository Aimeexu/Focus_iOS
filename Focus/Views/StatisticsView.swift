//
//  StatisticsView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct StatisticsView: View {
    @State private var selectedPeriod: TimePeriod = .day
    @State private var responseData = ConcentrationStatisticsResponse.empty

    @State private var focusData: [FocusData] = []

    enum TimePeriod: String, CaseIterable {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
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
                            PieChartView(data: focusData, total: responseData.data.totalDuration)
                                .frame(width: 180, height: 180)


                            Text("\(responseData.data.totalDuration)")
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
                        Task {
                            do {
                                // 获取当前日期
                                let currentDate = Date()
                                // 使用 Calendar 获取月份、年份
                                let month = Calendar.current.component(.month, from: currentDate)
                                let year = Calendar.current.component(.year, from: currentDate)
                                let response = try await NetworkManager.shared.getConcentrationStatistics(
                                    period: selectedPeriod.rawValue == "DAY" ? "TODAY" : selectedPeriod.rawValue,
                                    month: month,
                                    year: year
                                )
                                print("📊 专注统计返回: \(response)")
                                responseData = response

                                focusData = responseData.data.durationByTag.map { (key, value) in
                                    let color = categoryColors[key] ?? randomColor()
                                    return FocusData(category: key, minutes: value, color: color)
                                }
                            } catch {
                                print("❌ 检查海报兑换资格失败: \(error)")
                            }
                        }
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
                    // 获取当前日期
                    let currentDate = Date()
                    // 使用 Calendar 获取月份、年份
                    let month = Calendar.current.component(.month, from: currentDate)
                    let year = Calendar.current.component(.year, from: currentDate)
                    let response = try await NetworkManager.shared.getConcentrationStatistics(
                        period: "TODAY",//selectedPeriod.rawValue,
                        month: month,
                        year: year
                    )
                    print("📊 专注统计返回: \(response)")
                    responseData = response

                    focusData = responseData.data.durationByTag.map { (key, value) in
                        let color = categoryColors[key] ?? randomColor()
                        return FocusData(category: key, minutes: value, color: color)
                    }
                } catch {
                    print("❌ 检查海报兑换资格失败: \(error)")
                }
            }
        }
    }

    // 饼图部分
    private var pieChartSection: some View {
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                PieChartView(data: focusData, total: responseData.data.totalDuration)
                    .frame(width: 180, height: 180)

                Text("\(responseData.data.totalDuration)")
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
                    Text("\(responseData.data.totalDuration) m")
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
        return Angle(degrees: Double(midPoint) / Double(responseData.data.totalDuration) * 360 - 90)
    }
}

struct FocusData {
    let category: String
    let minutes: Int
    let color: Color
}

// 固定颜色映射
let categoryColors: [String: Color] = [
    "Study": AppColors.Brand.primary,
    "Work": AppColors.Semantic.lightGray,
    "Read": AppColors.Semantic.beige
]

// 随机颜色生成函数
func randomColor() -> Color {
    return Color(
        red: .random(in: 0...1),
        green: .random(in: 0...1),
        blue: .random(in: 0...1)
    )
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

