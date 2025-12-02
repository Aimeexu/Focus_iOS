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
    @State private var currentDate = Date()  // 当前查看的日期
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
        GeometryReader { geometry in
            ZStack {
                AppColors.Background.primary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 图表内容区域
                    if selectedPeriod == .day {
                        dayModeContent
                            .frame(maxHeight: geometry.size.height - 200)  // 预留底部空间
                    } else {
                        weekMonthYearModeContent
                    }
                }
            }
        }
        // TabBar 固定在安全区域顶部
        .safeAreaInset(edge: .top) {
            HStack(spacing: 0) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                        currentDate = Date()

                        Task {
                            do {
                                let currentDate = Date()
                                let month = Calendar.current.component(.month, from: currentDate)
                                let year = Calendar.current.component(.year, from: currentDate)

                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let operateDateString = dateFormatter.string(from: currentDate)

                                let response: ConcentrationStatisticsResponse

                                if selectedPeriod == .day {
                                    response = try await NetworkManager.shared
                                        .getConcentrationStatistics(
                                            period: "DAY",
                                            month: month,
                                            year: year,
                                            operateDate: operateDateString
                                        )
                                } else {
                                    response = try await NetworkManager.shared
                                        .getConcentrationStatistics(
                                            period: selectedPeriod.rawValue,
                                            month: month,
                                            year: year,
                                            operateDate: operateDateString
                                        )
                                }

                                print("📊 专注统计返回: \(response)")
                                responseData = response

                                focusData = Array(responseData.data.durationByTag.enumerated()).map
                                { (index: Int, element: (key: String, value: Int)) in
                                    let (key, value) = element
                                    let color = getColorForIndex(index)
                                    return FocusData(category: key, minutes: value, color: color)
                                }
                            } catch {
                                print("❌ 获取统计数据失败: \(error)")
                            }
                        }
                    }) {
                        Text(period.rawValue)
                            .font(.appButton(size: 16))
                            .foregroundColor(
                                selectedPeriod == period
                                    ? AppColors.Text.inverse : AppColors.Text.primary
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                selectedPeriod == period ? AppColors.Semantic.error : Color.clear
                            )
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
                    let currentDate = Date()
                    let month = Calendar.current.component(.month, from: currentDate)
                    let year = Calendar.current.component(.year, from: currentDate)
                    let response = try await NetworkManager.shared.getConcentrationStatistics(
                        period: "TODAY",
                        month: month,
                        year: year
                    )
                    print("📊 专注统计返回: \(response)")
                    responseData = response

                    focusData = Array(responseData.data.durationByTag.enumerated()).map {
                        (index: Int, element: (key: String, value: Int)) in
                        let (key, value) = element
                        let color = getColorForIndex(index)
                        return FocusData(category: key, minutes: value, color: color)
                    }
                } catch {
                    print("❌ 检查海报兑换资格失败: \(error)")
                }
            }
        }
    }

    // Day模式内容 - 使用ScrollView确保不被遮挡
    private var dayModeContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 10)

                // 显示当前日期
                VStack(spacing: 4) {
                    Text(formatDate(currentDate))
                        .font(.appBody(size: 18))
                        .foregroundColor(AppColors.Text.secondary)
                }
                Spacer().frame(height: 8)

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
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: AppColors.Brand.primary))
                    }
                }
                .offset(x: dragOffset)

                Spacer().frame(height: 20)

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
                        Text("\(responseData.data.totalSession)")
                            .font(.appNumber(size: 24))
                            .foregroundColor(AppColors.Text.primary)
                    }
                }

                Spacer().frame(height: 50)  // 底部安全空间
            }
        }
        .scrollDisabled(true)  // 禁用滚动，只是为了避免被遮挡
        .contentShape(Rectangle())  // 确保整个区域可以响应手势
        .gesture(dayModeGesture)  // 将手势应用到整个内容区域
    }

    // Week/Month/Year模式内容
    private var weekMonthYearModeContent: some View {
        VStack(spacing: 0) {
            barChartSection
                .padding(.top, 10)
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
            .padding(.top, 10)
            .offset(x: dragOffset)

            Spacer()
        }
        .contentShape(Rectangle())  // 确保整个区域可以响应手势
        .gesture(weekMonthYearModeGesture)  // 将手势应用到整个内容区域
    }

    // Day模式手势
    private var dayModeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                let maxOffset: CGFloat = 50
                dragOffset = min(max(value.translation.width, -maxOffset), maxOffset) * 0.3
            }
            .onEnded { value in
                let threshold: CGFloat = 30
                let velocity = abs(value.predictedEndTranslation.width - value.translation.width)

                withAnimation(.easeOut(duration: 0.2)) {
                    dragOffset = 0
                }

                if !isLoading {
                    if value.translation.width > threshold
                        || (value.translation.width > 15 && velocity > 80)
                    {
                        changeDate(by: -1)
                    } else if value.translation.width < -threshold
                        || (value.translation.width < -15 && velocity > 80)
                    {
                        if !Calendar.current.isDateInToday(currentDate) {
                            changeDate(by: 1)
                        }
                    }
                }
            }
    }

    // Week/Month/Year模式手势
    private var weekMonthYearModeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                let maxOffset: CGFloat = 50
                dragOffset = min(max(value.translation.width, -maxOffset), maxOffset) * 0.3
            }
            .onEnded { value in
                let threshold: CGFloat = 30
                let velocity = abs(value.predictedEndTranslation.width - value.translation.width)

                withAnimation(.easeOut(duration: 0.2)) {
                    dragOffset = 0
                }

                if !isLoading {
                    if value.translation.width > threshold
                        || (value.translation.width > 15 && velocity > 80)
                    {
                        switch selectedPeriod {
                        case .week:
                            changeWeek(by: -1)
                        case .month:
                            changeMonth(by: -1)
                        case .year:
                            changeYear(by: -1)
                        default:
                            break
                        }
                    } else if value.translation.width < -threshold
                        || (value.translation.width < -15 && velocity > 80)
                    {
                        switch selectedPeriod {
                        case .week:
                            changeWeek(by: 1)
                        case .month:
                            changeMonth(by: 1)
                        case .year:
                            changeYear(by: 1)
                        default:
                            break
                        }
                    }
                }
            }
    }

    // 改变日期并请求数据
    private func changeDate(by days: Int) {
        let newDate =
            Calendar.current.date(byAdding: .day, value: days, to: currentDate) ?? currentDate
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

    // 按月改变日期并请求数据
    private func changeMonth(by months: Int) {
        let newDate =
            Calendar.current.date(byAdding: .month, value: months, to: currentDate) ?? currentDate
        currentDate = newDate

        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }

        Task {
            await loadDataForMonth()
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
            }
        }
    }

    // 按年改变日期并请求数据
    private func changeYear(by years: Int) {
        let newDate =
            Calendar.current.date(byAdding: .year, value: years, to: currentDate) ?? currentDate
        currentDate = newDate

        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }

        Task {
            await loadDataForYear()
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
            }
        }
    }

    // 按周改变日期并请求数据
    private func changeWeek(by weeks: Int) {
        let newDate =
            Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: currentDate)
            ?? currentDate
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

    // 为当前月加载数据
    private func loadDataForMonth() async {
        do {
            let month = Calendar.current.component(.month, from: currentDate)
            let year = Calendar.current.component(.year, from: currentDate)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let operateDateString = dateFormatter.string(from: currentDate)

            let response = try await NetworkManager.shared.getConcentrationStatistics(
                period: "MONTH",
                month: month,
                year: year,
                operateDate: operateDateString
            )

            responseData = response
            focusData = Array(responseData.data.durationByTag.enumerated()).map {
                (index: Int, element: (key: String, value: Int)) in
                let (key, value) = element
                let color = getColorForIndex(index)
                return FocusData(category: key, minutes: value, color: color)
            }
        } catch {
            print("❌ 加载月数据失败: \(error)")
        }
    }

    // 为当前年加载数据
    private func loadDataForYear() async {
        do {
            let month = Calendar.current.component(.month, from: currentDate)
            let year = Calendar.current.component(.year, from: currentDate)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let operateDateString = dateFormatter.string(from: currentDate)

            let response = try await NetworkManager.shared.getConcentrationStatistics(
                period: "YEAR",
                month: month,
                year: year,
                operateDate: operateDateString
            )

            responseData = response
            focusData = Array(responseData.data.durationByTag.enumerated()).map {
                (index: Int, element: (key: String, value: Int)) in
                let (key, value) = element
                let color = getColorForIndex(index)
                return FocusData(category: key, minutes: value, color: color)
            }
        } catch {
            print("❌ 加载年数据失败: \(error)")
        }
    }

    // 为当前周加载数据
    private func loadDataForWeek() async {
        do {
            let month = Calendar.current.component(.month, from: currentDate)
            let year = Calendar.current.component(.year, from: currentDate)

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
            focusData = Array(responseData.data.durationByTag.enumerated()).map {
                (index: Int, element: (key: String, value: Int)) in
                let (key, value) = element
                let color = getColorForIndex(index)
                return FocusData(category: key, minutes: value, color: color)
            }
        } catch {
            print("❌ 加载周数据失败: \(error)")
        }
    }

    // 为当前日期加载数据
    private func loadDataForCurrentDate() async {
        do {
            let month = Calendar.current.component(.month, from: currentDate)
            let year = Calendar.current.component(.year, from: currentDate)

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
            focusData = Array(responseData.data.durationByTag.enumerated()).map {
                (index: Int, element: (key: String, value: Int)) in
                let (key, value) = element
                let color = getColorForIndex(index)
                return FocusData(category: key, minutes: value, color: color)
            }
        } catch {
            print("❌ 加载日期数据失败: \(error)")
        }
    }

    // 条形图部分
    private var barChartSection: some View {
        let chartData: [BarData]
        switch selectedPeriod {
        case .week:
            chartData = generateWeeklyData(from: responseData.data.dataByDate)
        case .month:
            chartData = generateMonthlyData(from: responseData.data.dataByDate)
        case .year:
            chartData = generateYearlyData(from: responseData.data.dataByDate)
        default:
            chartData = []
        }

        let actualMaxValue = chartData.map { $0.value }.max() ?? 0
        let isAllZero = actualMaxValue == 0
        let maxValue = isAllZero ? 1 : actualMaxValue
        let totalFocus = chartData.reduce(0) { $0 + $1.value }
        let dailyAverage = responseData.data.dailyFocusTime

        let step = maxValue / 5
        let yAxisValues = isAllZero ? [0] : (0...5).map { $0 * step }

        return VStack(spacing: 0) {
            // 显示当前周/月/年信息
            VStack(spacing: 4) {
                Text(formatPeriodRange(currentDate, period: selectedPeriod))
                    .font(.appBody(size: 18))
                    .foregroundColor(AppColors.Text.secondary)
                    .padding(.bottom, 10)
            }

            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .trailing, spacing: 0) {
                    if isAllZero {
                        Spacer()
                        Text("0")
                            .font(.appNumber(size: 12))
                            .foregroundColor(AppColors.Text.secondary)
                    } else {
                        ForEach(yAxisValues.reversed(), id: \.self) { value in
                            Text("\(value)")
                                .font(.appNumber(size: 12))
                                .foregroundColor(AppColors.Text.secondary)
                                .frame(height: 160 / 5, alignment: .top)
                        }
                    }
                }
                .frame(width: 30, height: 160)
                .padding(.trailing, 5)

                VStack(spacing: 8) {
                    GeometryReader { geo in
                        VStack {
                            Spacer()
                            HStack(alignment: .bottom, spacing: selectedPeriod == .week ? 4 : 1) {
                                ForEach(chartData, id: \.day) { data in
                                    RoundedRectangle(cornerRadius: selectedPeriod == .week ? 12 : 6)
                                        .fill(AppColors.Brand.primary)
                                        .frame(
                                            width: selectedPeriod == .week ? 20 : 8,
                                            height: {
                                                // 0值完全不显示高度
                                                let displayValue: CGFloat = CGFloat(data.value)
                                                return geo.size.height * displayValue
                                                    / CGFloat(maxValue)
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
                    Text("\(responseData.data.totalSession)")
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
        let gapDegrees: Double = 3
        let previousTotal = focusData.prefix(index).reduce(0) { $0 + $1.minutes }
        let currentValue = focusData[index].minutes

        // 计算扇形的起始和结束角度（考虑间隙）
        let totalDataCount = focusData.count
        let effectiveDegrees = 360 - Double(totalDataCount) * gapDegrees

        let startAngle = Double(previousTotal) / Double(responseData.data.totalDuration) * effectiveDegrees + Double(index) * gapDegrees - 90
        let endAngle = Double(previousTotal + currentValue) / Double(responseData.data.totalDuration) * effectiveDegrees + Double(index) * gapDegrees - 90

        // 返回扇形的中点角度
        return Angle(degrees: (startAngle + endAngle) / 2)
    }

    // 格式化时间周期范围显示
    private func formatPeriodRange(_ date: Date, period: TimePeriod) -> String {
        let calendar = Calendar.current
        let now = Date()

        switch period {
        case .week:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
                return "This Week"
            }

            let startDate = weekInterval.start
            let endDate =
                calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end

            if calendar.dateInterval(of: .weekOfYear, for: now) == weekInterval {
                return "This Week"
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"

            let startString = formatter.string(from: startDate)
            let endString = formatter.string(from: endDate)

            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let year = yearFormatter.string(from: endDate)

            return "\(startString) - \(endString), \(year)"

        case .month:
            let currentMonth = calendar.component(.month, from: now)
            let currentYear = calendar.component(.year, from: now)
            let dateMonth = calendar.component(.month, from: date)
            let dateYear = calendar.component(.year, from: date)

            if currentMonth == dateMonth && currentYear == dateYear {
                return "This Month"
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)

        case .year:
            let currentYear = calendar.component(.year, from: now)
            let dateYear = calendar.component(.year, from: date)

            if currentYear == dateYear {
                return "This Year"
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: date)

        case .day:
            return formatDate(date)
        }
    }
}

struct FocusData {
    let category: String
    let minutes: Int
    let color: Color
}

// 预定义颜色数组，按优先级顺序
let predefinedColors: [Color] = [
    Color(red: 0x6A / 255.0, green: 0x54 / 255.0, blue: 0x46 / 255.0),  // 1. #6A5446
    Color(red: 0xF2 / 255.0, green: 0xE9 / 255.0, blue: 0xDA / 255.0),  // 2. #F2E9DA
    Color(red: 0xA7 / 255.0, green: 0x84 / 255.0, blue: 0x72 / 255.0),  // 3. #A78472
    Color(red: 0xE6 / 255.0, green: 0xDC / 255.0, blue: 0xC2 / 255.0),  // 4. #E6DCC2
    Color(red: 0xC5 / 255.0, green: 0xC9 / 255.0, blue: 0xB2 / 255.0),  // 5. #C5C9B2
    Color(red: 0xDA / 255.0, green: 0xB9 / 255.0, blue: 0x96 / 255.0),  // 6. #DAB996
    Color(red: 0xC7 / 255.0, green: 0xD2 / 255.0, blue: 0xB8 / 255.0),  // 7. #C7D2B8
    Color(red: 0xB6 / 255.0, green: 0xA8 / 255.0, blue: 0x92 / 255.0),  // 8. #B6A892
    Color(red: 0xFC / 255.0, green: 0xF8 / 255.0, blue: 0xF3 / 255.0),  // 9. #FCF8F3
    Color(red: 0xED / 255.0, green: 0xE3 / 255.0, blue: 0xD7 / 255.0),  // 10. #EDE3D7
]

// 获取颜色的函数 - 按索引优先使用预定义颜色，超出则随机
func getColorForIndex(_ index: Int) -> Color {
    if index < predefinedColors.count {
        return predefinedColors[index]
    } else {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

// 生成周数据的辅助函数
private func generateWeeklyData(from dataByDate: [ConcentrationDataByDate]) -> [BarData] {
    let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var weeklyData: [BarData] = []

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

    for (index, dayData) in dataByDate.enumerated() {
        let dateComponents = dayData.date.split(separator: "-")
        let dayNumber = String(dateComponents.last ?? "\(index + 1)")

        monthlyData.append(BarData(day: dayNumber, value: dayData.durationTotal))
    }

    return monthlyData
}

// 生成年数据的辅助函数
private func generateYearlyData(from dataByDate: [ConcentrationDataByDate]) -> [BarData] {
    var yearlyData: [BarData] = []

    // 创建12个月的数据，初始值为0
    for month in 1...12 {
        yearlyData.append(BarData(day: "\(month)", value: 0))
    }

    // 填充实际数据
    for dayData in dataByDate {
        let dateComponents = dayData.date.split(separator: "-")
        if dateComponents.count >= 2,
           let month = Int(dateComponents[1]),
           month >= 1 && month <= 12 {
            yearlyData[month - 1] = BarData(day: "\(month)", value: dayData.durationTotal)
        }
    }

    return yearlyData
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

struct PieChartView: View {
    let data: [FocusData]
    let total: Int
    private let gapDegrees: Double = 3

    var body: some View {
        ZStack {
            if total == 0 || data.isEmpty {
                // 当数据为空时显示灰色圆环
                PieSlice(
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 360),
                    color: Color.gray.opacity(0.3)
                )
            } else if data.count == 1 {
                // 当只有一项数据时显示完整的圆环
                PieSlice(
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 360),
                    color: data[0].color
                )
            } else {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: item.color
                    )
                }
            }
        }
    }

    private func startAngle(for index: Int) -> Angle {
        let previousTotal = data.prefix(index).reduce(0) { $0 + $1.minutes }
        let baseAngle =
            Double(previousTotal) / Double(total) * (360 - Double(data.count) * gapDegrees) - 90
        let gapOffset = Double(index) * gapDegrees
        return Angle(degrees: baseAngle + gapOffset)
    }

    private func endAngle(for index: Int) -> Angle {
        let currentValue = data[index].minutes
        let previousTotal = data.prefix(index).reduce(0) { $0 + $1.minutes }
        let baseAngle =
            Double(previousTotal + currentValue) / Double(total)
            * (360 - Double(data.count) * gapDegrees) - 90
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
                path.addArc(
                    center: center, radius: radius, startAngle: startAngle, endAngle: endAngle,
                    clockwise: false)
                path.addArc(
                    center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle,
                    clockwise: true)
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
