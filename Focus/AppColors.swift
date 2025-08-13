//
//  AppColors.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

// MARK: - App颜色规范
struct AppColors {
    
    // MARK: - 品牌色
    struct Brand {
        /// 主品牌色 - 绿色
        static let primary = Color(hex: "67A12A")
    }
    
    // MARK: - 中性色
    struct Neutral {
        /// 纯白色
        static let white = Color(hex: "FFFFFF")
        
        /// 浅灰色
        static let gray100 = Color(hex: "a9aab1")
        
        /// 中灰色
        static let gray200 = Color(hex: "81838d")
        
        /// 深灰色
        static let gray300 = Color(hex: "5c5d66")
        
        /// 更深灰色
        static let gray400 = Color(hex: "38383e")
        
        /// 最深灰色/黑色
        static let black = Color(hex: "131415")
    }
    
    // MARK: - 语义色
    struct Semantic {
        /// 深棕色 - 用于背景
        static let darkBrown = Color(hex: "4c3e33")
        
        /// 浅棕色 - 用于次要背景
        static let lightBrown = Color(hex: "eae0cb")
        
        /// 米色 - 用于卡片背景
        static let beige = Color(hex: "eae0cb")
        
        /// 橄榄绿 - 用于辅助色
        static let oliveGreen = Color(hex: "b7baa0")

        /// 浅灰 - 用于禁用状态
        static let lightGray = Color(hex: "FBF4EC")
        
        /// 错误红色 - 用于错误提示
        static let error = Color(hex: "E2583F")
    }
    
    // MARK: - 功能色
    struct Functional {
        /// 成功色
        static let success = Brand.primary
        
        /// 警告色
        static let warning = Color(hex: "FF9500")
        
        /// 信息色
        static let info = Color(hex: "007AFF")
        
        /// 危险色
        static let danger = Semantic.error
    }
    
    // MARK: - 文本色
    struct Text {
        /// 主要文本色
        static let primary = Neutral.black
        
        /// 次要文本色
        static let secondary = Neutral.gray300
        
        /// 辅助文本色
        static let tertiary = Neutral.gray200
        
        /// 禁用文本色
        static let disabled = Neutral.gray100
        
        /// 反色文本（白色）
        static let inverse = Neutral.white
    }
    
    // MARK: - 背景色
    struct Background {
        /// 主背景色
        static let primary = Neutral.white
        
        /// 次要背景色
        static let secondary = Semantic.lightGray
        
        /// 卡片背景色
        static let card = Neutral.white
        
        /// 深色背景
        static let dark = Semantic.darkBrown
        
        /// TabBar背景色
        static let tabBar = Semantic.darkBrown
    }
    
    // MARK: - 边框色
    struct Border {
        /// 默认边框色
        static let `default` = Neutral.gray100
        
        /// 聚焦边框色
        static let focused = Brand.primary
        
        /// 错误边框色
        static let error = Semantic.error
    }
}

// MARK: - Color扩展，支持十六进制颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
