//
//  JFCommon.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import pop

/// 打印日志封装 - 打包的时候注释掉
///
/// - Parameter items: 需要打印的内容
func log(_ items: Any?...) {
    print(items)
}

struct Platform {
    // 是否是模拟器
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

/// 基于iPhone6垂直方向适配
///
/// - Parameter size: iPhone6垂直方向尺寸
/// - Returns: 其他型号尺寸
func layoutVertical(iPhone6: CGFloat) -> CGFloat {
    
    var newHeight: CGFloat = 0
    
    switch iPhoneModel.getCurrentModel() {
    case .iPhone4:
        newHeight = iPhone6 * (480.0 / 667.0)
    case .iPhone5:
        newHeight = iPhone6 * (568.0 / 667.0)
    case .iPhone6:
        newHeight = iPhone6
    case .iPhone6p:
        newHeight = iPhone6 * (736.0 / 667.0)
    default:
        newHeight = iPhone6 * (1024.0 / 667.0 * 0.9)
    }
    
    return newHeight
    
}

/// 基于iPhone6水平方向适配
///
/// - Parameter iPhone6: iPhone6水平方向尺寸
/// - Returns: 其他型号尺寸
func layoutHorizontal(iPhone6: CGFloat) -> CGFloat {
    
    var newWidth: CGFloat = 0
    
    switch iPhoneModel.getCurrentModel() {
    case .iPhone4:
        newWidth = iPhone6 * (320.0 / 375.0)
    case .iPhone5:
        newWidth = iPhone6 * (320.0 / 375.0)
    case .iPhone6:
        newWidth = iPhone6
    case .iPhone6p:
        newWidth = iPhone6 * (414.0 / 375.0)
    default:
        newWidth = iPhone6 * (768.0 / 375.0 * 0.9)
    }
    
    return newWidth
    
}

/// 基于iPhone6字体的屏幕适配
///
/// - Parameter iPhone6: iPhone字体大小
/// - Returns: 其他型号字体
func layoutFont(iPhone6: CGFloat) -> CGFloat {
    
    var newFont: CGFloat = 0
    
    switch iPhoneModel.getCurrentModel() {
    case .iPhone4:
        newFont = iPhone6 * (320.0 / 375.0)
    case .iPhone5:
        newFont = iPhone6 * (320.0 / 375.0)
    case .iPhone6:
        newFont = iPhone6
    case .iPhone6p:
        newFont = iPhone6 * (414.0 / 375.0)
    default:
        newFont = iPhone6 * 1.2
    }
    
    return newFont
}

/**
 手机型号枚举
 */
enum iPhoneModel {
    
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6p
    case iPad
    
    /**
     获取当前手机型号
     
     - returns: 返回手机型号枚举
     */
    static func getCurrentModel() -> iPhoneModel {
        switch SCREEN_HEIGHT {
        case 480:
            return .iPhone4 // 如果没有适配iPad，则3.5英寸屏幕则是iPad屏幕
        case 568:
            return .iPhone5
        case 667:
            return .iPhone6
        case 736:
            return .iPhone6p
        default:
            return .iPad
        }
    }
}

func isIPad() -> Bool {
    return UIDevice.current.model.contains("iPad")
}

// MARK: - 屏幕尺寸
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_BOUNDS = UIScreen.main.bounds

/// 背景颜色
let BACKGROUND_COLOR = UIColor.colorWithHexString("#333333")

/// 首页cell尺寸
let HomeItemWidth: CGFloat = layoutHorizontal(iPhone6: 175)
let HomeItemHeight: CGFloat = layoutVertical(iPhone6: 312)

/// 设计界面cell尺寸
let SettingPhotoItemWidth: CGFloat = layoutHorizontal(iPhone6: 56)
let SettingPhotoItemHeight: CGFloat = layoutVertical(iPhone6: 100)

// 设置界面弹出和隐藏的通知
let SettingViewControllerWillPresent = "SettingViewControllerWillPresent"
let SettingViewControllerWillDismiss = "SettingViewControllerWillDismiss"

// 相册隐藏通知
let AlbumListViewControllerWillDismiss = "AlbumListViewControllerWillDismiss"

/// AppStore ID
let APPSTORE_ID = "1205269443"

/// 友盟appkey
let UM_APP_KEY = "58a075ece88bad07e3001589"

/// 新浪
let SINA_APP_KEY = "2321901043"
let SINA_APP_SECRET = "b444ff8961a501dc3bf21f4cc36ff715"

/// 腾讯
let QQ_APP_ID = "1105866173"
let QQ_APP_KEY = "4gklryMBVNunMEcR"

/// 微信
let WX_APP_ID = "wx264105d861cf1f3f"
let WX_APP_SECRET = "4681a563d762effff390ea660766b083"



