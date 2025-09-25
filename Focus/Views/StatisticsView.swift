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
    @State private var currentDate = Date() // 当前查看的日期
    @State private var focusData: [FocusData] = []
    @State private var dragOffset: CGFloat = 0
    @State private var isLoading = false

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
                            .offset(x: dragOffset)
                            .opacity(isLoading ? 0.5 : 1.0)

                        ZStack {
                            PieChartView(data: focusData, total: responseData.data.totalDuration)
                                .frame(width: 180, height: 180)
                                .opacity(isLoading ? 0.5 : 1.0)

                            Text("\(responseData.data.totalDuration)")
                                .font(.appNumber(size: 36))
                                .foregroundColor(AppColors.Text.primary)
                                .opacity(isLoading ? 0.5 : 1.0)

                            ForEach(Array(focusData.enumerated()), id: \.offset) { index, data in
                                PieChartLabel(
                                    data: data,
                                    angle: labelAngle(for: index),
                                    radius: 120
                                )
                                .opacity(isLoading ? 0.5 : 1.0)
                            }

                            if isLoading {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Brand.primary))
                            }
                        }
                        .padding(.top, 30)
                        .offset(x: dragOffset)

                        Spacer()
                    }
                    .gesture(
                        DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onChanged { value in
                                // 限制拖拽范围，提供视觉反馈
                                let maxOffset: CGFloat = 50
                                dragOffset = min(max(value.translation.width, -maxOffset), maxOffset) * 0.3
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 30
                                let velocity = abs(value.predictedEndTranslation.width - value.translation.width)

                                // 重置偏移
                                withAnimation(.easeOut(duration: 0.2)) {
                                    dragOffset = 0
                                }

                                // 检查是否需要切换周
                                if !isLoading {
                                    if value.translation.width > threshold || (value.translation.width > 15 && velocity > 80) {
                                        // 右滑：显示上一周
                                        changeWeek(by: -1)
                                    } else if value.translation.width < -threshold || (value.translation.width < -15 && velocity > 80) {
                                        // 左滑：显示下一周
                                        changeWeek(by: 1)
                                    }
                                }
                            }
                    )
                }
            }
        }
        // ✅ 把 TabBar 固定在安全区域顶部
        .safeAreaInset(edge: .top) {
            HStack(spacing: 0) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period

                        // 重置当前日期为今天
                        currentDate = Date()

                        Task {
                            do {
                                // 获取当前日期
                                let currentDate = Date()
                                // 使用 Calendar 获取月份、年份
                                let month = Calendar.current.component(.month, from: currentDate)
                                let year = Calendar.current.component(.year, from: currentDate)

                                let response: ConcentrationStatisticsResponse

                                if selectedPeriod == .week {
                                    // 构建operateDate字符串
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    let operateDateString = dateFormatter.string(from: currentDate)

                                    response = try await NetworkManager.shared.getConcentrationStatistics(
                                        period: "WEEK",
                                        month: month,
                                        year: year,
                                        operateDate: operateDateString
                                    )
                                } else {
                                    response = try await NetworkManager.shared.getConcentrationStatistics(
                                        period: selectedPeriod.rawValue == "DAY" ? "TODAY" : selectedPeriod.rawValue,
                                        month: month,
                                        year: year
                                    )
                                }

                                print("📊 专注统计返回: \(response)")
                                responseData = response

                                focusData = responseData.data.durationByTag.map { (key, value) in
                                    let color = categoryColors[key] ?? randomColor()
                                    return FocusData(category: key, minutes: value, color: color)
                                }
                            } catch {
                                print("❌ 获取统计数据失败: \(error)")
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
                        period: "TODAY",
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

    // 改变日期并请求数据
    private func changeDate(by days: Int) {
        let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) ?? currentDate
        currentDate = newDate

        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }

        Task {
            await loadDataForCurrentDate()
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
            }
        }
    }

    // 按周改变日期并请求数据
    private func changeWeek(by weeks: Int) {
        let newDate = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: currentDate) ?? currentDate
        currentDate = newDate

        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }

        Task {
            await loadDataForWeek()
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
            }
        }
    }

    // 为当前日期加载数据
    private func loadDataForCurrentDate() async {
        do {
            let month = Calendar.current.component(.month, from: currentDate)
            let year = Calendar.current.component(.year, from: currentDate)

            // 构建operateDate字符串 "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let operateDateString = dateFormatter.string(from: currentDate)

            let response = try await NetworkManager.shared.getConcentrationStatistics(
                period: "DAY",
                month: month,
                year: year,
                operateDate: operateDateString
            )

            responseData = response
            focusData = responseData.data.durationByTag.map { (key, value) in
                let color = categoryColors[key] ?? randomColor()
                return FocusData(category: key, minutes: value, color: color)
            }
        } catch {
            print("❌ 加载日期数据失败: \(error)")
        }
    }

    // 为当前周加载数据
    private func loadDataForWeek() async {
        do {
            let month = Calendar.current.component(.month, from: currentDate)
            let year = Calendar.current.component(.year, from: currentDate)

            // 构建operateDate字符串 "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let operateDateString = dateFormatter.string(from: currentDate)

            let response = try await NetworkManager.shared.getConcentrationStatistics(
                period: "WEEK",
                month: month,
                year: year,
                operateDate: operateDateString
            )

            responseData = response
            focusData = responseData.data.durationByTag.map { (key, value) in
                let color = categoryColors[key] ?? randomColor()
                return FocusData(category: key, minutes: value, color: color)
            }
        } catch {
            print("❌ 加载周数据失败: \(error)")
        }
    }

    // 饼图部分
    private var pieChartSection: some View {
        VStack(spacing: 40) {
            Spacer()

            // 显示当前日期和滑动提示
            VStack(spacing: 4) {
                Text(formatDate(currentDate))
                    .font(.appBody(size: 18))
                    .foregroundColor(AppColors.Text.secondary)
            }

            ZStack {
                PieChartView(data: focusData, total: responseData.data.totalDuration)
                    .frame(width: 180, height: 180)
                    .opacity(isLoading ? 0.5 : 1.0)

                Text("\(responseData.data.totalDuration)")
                    .font(.appNumber(size: 36))
                    .foregroundColor(AppColors.Text.primary)
                    .opacity(isLoading ? 0.5 : 1.0)

                ForEach(Array(focusData.enumerated()), id: \.offset) { index, data in
                    PieChartLabel(
                        data: data,
                        angle: labelAngle(for: index),
                        radius: 120
                    )
                    .opacity(isLoading ? 0.5 : 1.0)
                }

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Brand.primary))
                }
            }
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged { value in
                        // 限制拖拽范围，提供视觉反馈
                        let maxOffset: CGFloat = 50
                        dragOffset = min(max(value.translation.width, -maxOffset), maxOffset) * 0.3
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 30
                        let velocity = abs(value.predictedEndTranslation.width - value.translation.width)

                        // 重置偏移
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragOffset = 0
                        }

                        // 检查是否需要切换日期
                        if !isLoading {
                            if value.translation.width > threshold || (value.translation.width > 15 && velocity > 80) {
                                // 右滑：显示前一天
                                changeDate(by: -1)
                            } else if value.translation.width < -threshold || (value.translation.width < -15 && velocity > 80) {
                                // 左滑：显示后一天（不能超过今天）
                                if !Calendar.current.isDateInToday(currentDate) {
                                    changeDate(by: 1)
                                }
                            }
                        }
                    }
            )


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
        // 根据选择的时间周期生成数据
        let chartData = selectedPeriod == .week ?
            generateWeeklyData(from: responseData.data.dataByDate) :
            generateMonthlyData(from: responseData.data.dataByDate)

        let actualMaxValue = chartData.map { $0.value }.max() ?? 0
        let isAllZero = actualMaxValue == 0
        let maxValue = isAllZero ? 1 : actualMaxValue
        let totalFocus = chartData.reduce(0) { $0 + $1.value }
        let dailyAverage = totalFocus / chartData.count

        // 计算 5 等分
        let step = maxValue / 5
        let yAxisValues = (0...5).map { $0 * step }  // [0, step, 2step, ..., maxValue]

        return VStack(spacing: 0) {
            // 显示当前周/月信息
            if selectedPeriod == .week {
                VStack(spacing: 4) {
                    Text(formatWeekRange(currentDate))
                        .font(.appBody(size: 18))
                        .foregroundColor(AppColors.Text.secondary)
                        .padding(.bottom, 10)
                }
            }
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

                VStack(spacing: 8) {
                    GeometryReader { geo in
                        VStack {
                            Spacer()
                            HStack(alignment: .bottom, spacing: selectedPeriod == .week ? 4 : 1) {
                                ForEach(chartData, id: \.day) { data in
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.Brand.primary)
                                        .frame(
                                            width: selectedPeriod == .week ? 20 : 8,
                                            height: {
                                                let displayValue: CGFloat = (isAllZero && data.value == 0) ? 0.1 : CGFloat(data.value)
                                                return geo.size.height * displayValue / CGFloat(maxValue)
                                            }()
                                        )
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .frame(height: 160)

                    HStack(spacing: selectedPeriod == .week ? 4 : 1) {
                        ForEach(chartData, id: \.day) { data in
                            Text(data.day)
                                .font(.appBody(size: selectedPeriod == .week ? 12 : 8))
                                .foregroundColor(AppColors.Text.primary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
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

// 生成周数据的辅助函数
private func generateWeeklyData(from dataByDate: [ConcentrationDataByDate]) -> [BarData] {
    let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var weeklyData: [BarData] = []

    // 遍历返回的数据，按顺序添加
    for i in 0..<7 {
        let dayName = dayNames[i]
        let value = i < dataByDate.count ? dataByDate[i].durationTotal : 0
        weeklyData.append(BarData(day: dayName, value: value))
    }

    return weeklyData
}

// 生成月数据的辅助函数
private func generateMonthlyData(from dataByDate: [ConcentrationDataByDate]) -> [BarData] {
    var monthlyData: [BarData] = []

    // 显示所有天的数据
    for (index, dayData) in dataByDate.enumerated() {
        // 从日期字符串中提取日期数字，格式：2025-9-1
        let dateComponents = dayData.date.split(separator: "-")
        let dayNumber = String(dateComponents.last ?? "\(index + 1)")

        monthlyData.append(BarData(day: dayNumber, value: dayData.durationTotal))
    }

    return monthlyData
}

// 格式化日期显示
private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    if Calendar.current.isDateInToday(date) {
        return "Today"
    } else if Calendar.current.isDateInYesterday(date) {
        return "Yesterday"
    } else {
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// 格式化周范围显示
private func formatWeekRange(_ date: Date) -> String {
    let calendar = Calendar.current

    // 获取该日期所在周的开始和结束日期
    guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
        return "This Week"
    }

    let startDate = weekInterval.start
    let endDate = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end

    // 检查是否是当前周
    let now = Date()
    if calendar.dateInterval(of: .weekOfYear, for: now) == weekInterval {
        return "This Week"
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"

    let startString = formatter.string(from: startDate)
    let endString = formatter.string(from: endDate)

    // 添加年份
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "yyyy"
    let year = yearFormatter.string(from: endDate)

    return "\(startString) - \(endString), \(year)"
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
