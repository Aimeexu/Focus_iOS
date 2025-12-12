//
//  ImageTextComposer.swift
//  Focus
//
//  Created by Kiro on 2025/12/12.
//

import UIKit
import SwiftUI

/// 图片文字合成工具类
class ImageTextComposer {
    
    /// 在图片上添加文字，生成新的合成图片
    /// - Parameters:
    ///   - image: 原始图片
    ///   - text: 要添加的文字
    ///   - textColor: 文字颜色，默认白色
    ///   - fontSize: 字体大小，如果为nil则根据图片大小自动计算
    ///   - position: 文字位置，默认居中
    ///   - backgroundColor: 文字背景色，默认半透明黑色
    ///   - padding: 文字内边距，默认16
    /// - Returns: 合成后的图片
    static func composeImage(
        image: UIImage,
        text: String,
        textColor: UIColor = .white,
        fontSize: CGFloat? = nil,
        position: TextPosition = .center,
        backgroundColor: UIColor = UIColor.black.withAlphaComponent(0),
        padding: CGFloat = 20
    ) -> UIImage? {
        
        let imageSize = image.size
        
        // 根据图片大小自动计算字体大小
        let calculatedFontSize = fontSize ?? (imageSize.width / 15)
        
        // 创建图形上下文，使用原图的scale确保清晰度
        UIGraphicsBeginImageContextWithOptions(imageSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // 绘制原始图片
        image.draw(at: .zero)
        
        // 设置文字属性
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = calculatedFontSize * 0.1 // 行间距

        let font = UIFont.systemFont(ofSize: calculatedFontSize, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle,
            .strokeColor: UIColor.black.withAlphaComponent(0.3), // 添加描边增强可读性
            .strokeWidth: -2.0
        ]
        
        // 计算文字尺寸
        let maxWidth = imageSize.width - padding * 2
        let textRect = text.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        // 计算文字位置
        let textX = (imageSize.width - textRect.width) / 2
        var textY: CGFloat
        
        switch position {
        case .top:
            textY = padding * 3
        case .center:
            textY = (imageSize.height - textRect.height) / 2
        case .bottom:
            textY = imageSize.height - textRect.height - padding * 2
        case .custom(let y):
            textY = y
        }
        
        let textFrame = CGRect(
            x: textX,
            y: textY,
            width: textRect.width,
            height: textRect.height
        )
        
        // 绘制文字
        text.draw(in: textFrame, withAttributes: attributes)
        
        // 获取合成后的图片
        let composedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return composedImage
    }
    
    /// 文字位置枚举
    enum TextPosition {
        case top        // 顶部
        case center     // 居中
        case bottom     // 底部
        case custom(CGFloat)  // 自定义Y坐标
    }
}
