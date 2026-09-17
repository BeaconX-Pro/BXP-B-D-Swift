//
//  MKBXDUIShims.swift
//  MKBeaconButtonSwiftProject
//
//  业务层对基础库（MKBaseSwiftModule / MKSwiftCustomUI）尚未提供的便利方法做补齐，
//  统一放在本文件，避免改动只读的 SPM 包。
//

import UIKit
import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - NSString 文本尺寸计算
extension NSString {

    /// 计算文本在指定字体与约束尺寸下所占的大小
    /// - Parameters:
    ///   - text: 待计算文本
    ///   - font: 使用的字体
    ///   - maxSize: 约束尺寸
    /// - Returns: 文本实际占用尺寸（已向上取整）
    @MainActor
    public static func mk_size(withText text: String,
                               andFont font: UIFont,
                               andMaxSize maxSize: CGSize) -> CGSize {
        guard !text.isEmpty else { return .zero }
        let rect = (text as NSString).boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }
}

// MARK: - MKSwiftUIAdaptor 业务便利方法
@MainActor
extension MKSwiftUIAdaptor {

    /// 创建常规样式的输入框（业务统一入口名）
    public static func createNormalTextField(text: String = "",
                                             placeHolder: String = "",
                                             textType: MKSwiftTextFieldType = .normal) -> MKSwiftTextField {
        return createTextField(text: text,
                               placeholder: placeHolder,
                               textType: textType)
    }

    /// 多段富文本拼接（首段无外部标签，字体、颜色一一对应）
    public static func attributedString(_ strings: [String],
                                        fonts: [UIFont],
                                        colors: [UIColor]) -> NSAttributedString {
        return createAttributedString(strings: strings,
                                      fonts: fonts,
                                      colors: colors)
    }

    /// 生成绕 Z 轴无限旋转的刷新动画
    /// - Parameter duration: 旋转一周的时长（秒）
    /// - Returns: 可直接添加到 layer 的旋转动画
    public static func refreshAnimation(_ duration: CFTimeInterval) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = Double.pi * 2.0
        animation.duration = duration
        animation.isCumulative = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        return animation
    }
}
