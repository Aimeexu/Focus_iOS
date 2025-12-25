//
//  FontExtension.swift
//  Focus
//
//  Created by Assistant on 2025/1/27.
//

import SwiftUI

// MARK: - 字体扩展
extension Font {
    
    // MARK: - ShangguRound字体系列（仅保留使用中的字体）
    
    /// ShangguRound Regular (默认字体)
    static func shangguRoundRegular(size: CGFloat) -> Font {
        return Font.custom("ShangguRound-Regular", size: size)
    }
    
    /// ShangguRound Medium
    static func shangguRoundMedium(size: CGFloat) -> Font {
        return Font.custom("ShangguRound-Medium", size: size)
    }
    
    /// ShangguRound Bold
    static func shangguRoundBold(size: CGFloat) -> Font {
        return Font.custom("ShangguRound-Bold", size: size)
    }
    
    // MARK: - 语义化字体定义
    
    /// 大标题字体
    static func appLargeTitle(size: CGFloat = 34) -> Font {
        return .shangguRoundBold(size: size)
    }
    
    /// 标题字体
    static func appTitle(size: CGFloat = 28) -> Font {
        return .shangguRoundBold(size: size)
    }
    
    /// 标题2字体
    static func appTitle2(size: CGFloat = 22) -> Font {
        return .shangguRoundBold(size: size)
    }
    
    /// 标题3字体
    static func appTitle3(size: CGFloat = 20) -> Font {
        return .shangguRoundMedium(size: size)
    }
    
    /// 标题字体
    static func appHeadline(size: CGFloat = 17) -> Font {
        return .shangguRoundMedium(size: size)
    }
    
    /// 子标题字体
    static func appSubheadline(size: CGFloat = 15) -> Font {
        return .shangguRoundRegular(size: size)
    }
    
    /// 正文字体
    static func appBody(size: CGFloat = 17) -> Font {
        return .shangguRoundRegular(size: size)
    }
    
    /// 标注字体
    static func appCallout(size: CGFloat = 16) -> Font {
        return .shangguRoundRegular(size: size)
    }
    
    /// 脚注字体
    static func appFootnote(size: CGFloat = 13) -> Font {
        return .shangguRoundRegular(size: size)
    }
    
    /// 说明字体
    static func appCaption(size: CGFloat = 12) -> Font {
        return .shangguRoundRegular(size: size)
    }
    
    /// 说明2字体
    static func appCaption2(size: CGFloat = 11) -> Font {
        return .shangguRoundRegular(size: size)
    }
    
    // MARK: - 自定义尺寸字体
    
    /// 按钮字体
    static func appButton(size: CGFloat = 16) -> Font {
        return .shangguRoundBold(size: size)
    }
    
    /// 数字字体（等宽）
    static func appNumber(size: CGFloat = 17) -> Font {
        return .shangguRoundBold(size: size)
    }
    
    /// 强调字体
    static func appEmphasis(size: CGFloat = 17) -> Font {
        return .shangguRoundBold(size: size)
    }

    /// 应用副标题字体
    static func appSubtitle(size: CGFloat) -> Font {
        return .system(size: size, weight: .semibold)
    }
}
