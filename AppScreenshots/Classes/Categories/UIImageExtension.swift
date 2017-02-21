//
//  UIImageExtension.swift
//  ImageOptimizeTest
//
//  Created by zhoujianfeng on 2017/1/20.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 重新绘制图片
    ///
    /// - Parameters:
    ///   - size: 绘制尺寸
    /// - Returns: 新图
    func redrawImage(size: CGSize?, scale: CGFloat = 0) -> UIImage? {
        
        // 绘制区域
        let rect = CGRect(origin: CGPoint(), size: size ?? CGSize.zero)
        
        // 开启图形上下文 size:绘图的尺寸 opaque:不透明 scale:屏幕分辨率系数,0会选择当前设备的屏幕分辨率系数
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        // 绘制 在指定区域拉伸并绘制
        draw(in: rect)
        
        // 从图形上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// 绘制圆角图片
    ///
    /// - Parameters:
    ///   - size: 绘制尺寸
    ///   - bgColor: 裁剪区域外的背景颜色
    ///   - cornerRadius: 圆角
    /// - Returns: 新图
    func redrawRoundedImage(size: CGSize?, bgColor: UIColor?, cornerRadius: CGFloat) -> UIImage? {
        
        // 绘制区域
        let rect = CGRect(origin: CGPoint(), size: size ?? CGSize.zero)
        
        // 开启图形上下文 size:绘图的尺寸 opaque:不透明 scale:屏幕分辨率系数,0会选择当前设备的屏幕分辨率系数
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        // 背景颜色填充
        bgColor?.setFill()
        UIRectFill(rect)
        
        // 圆角矩形路径
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        // 进行路径裁切，后续的绘图都会出现在这个圆形路径内部
        path.addClip()
        
        // 绘制图像 在指定区域拉伸并绘制
        draw(in: rect)
        
        // 从图形上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// 重新绘制圆形图片
    ///
    /// - Parameters:
    ///   - size: 绘制尺寸
    ///   - bgColor: 裁剪区域外的背景颜色
    /// - Returns: 新图
    func redrawOvalImage(size: CGSize?, bgColor: UIColor?) -> UIImage? {
        
        // 绘制区域
        let rect = CGRect(origin: CGPoint(), size: size ?? CGSize.zero)
        
        // 开启图形上下文 size:绘图的尺寸 opaque:不透明 scale:屏幕分辨率系数,0会选择当前设备的屏幕分辨率系数
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        // 背景颜色填充
        bgColor?.setFill()
        UIRectFill(rect)
        
        // 圆形路径
        let path = UIBezierPath(ovalIn: rect)
        
        // 进行路径裁切，后续的绘图都会出现在这个圆形路径内部
        path.addClip()
        
        // 绘制图像 在指定区域拉伸并绘制
        draw(in: rect)
        
        // 从图形上下文获取图片
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return result
    }
    
}
