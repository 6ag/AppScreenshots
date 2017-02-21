//
//  JFMaterial.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/3.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

/// 素材参数
class JFMaterialParameter: NSObject, NSCopying {
    
    /// 展示图名称
    var showImageName: String?
    
    /// 原图名称
    var sourceImageName: String?
    
    /// 用户上传的截图
    var screenShotImage: UIImage?
    
    /// 用户上传的截图的矩形区域x坐标
    var screenShotX: CGFloat = 0
    
    /// 用户上传的截图的矩形区域y坐标
    var screenShotY: CGFloat = 0
    
    /// 用户上传的截图的矩形区域宽度
    var screenShotWidth: CGFloat = 0
    
    /// 用户上传的截图的矩形区域高度
    var screenShotHeight: CGFloat = 0
    
    /// 悬浮配图名称
    var accessoryImageName: String?
    
    /// 悬浮配图x坐标
    var accessoryX: CGFloat = 0
    
    /// 悬浮配图y坐标
    var accessoryY: CGFloat = 0
    
    /// 悬浮配图宽度
    var accessoryWidth: CGFloat = 0
    
    /// 悬浮配图高度
    var accessoryHeight: CGFloat = 0
    
    /// 遮罩图片名称
    var coverImageName: String?
    
    /// 遮罩图片x坐标
    var coverX: CGFloat = 0
    
    /// 遮罩图片y坐标
    var coverY: CGFloat = 0
    
    /// 遮罩图片宽度
    var coverWidth: CGFloat = 0
    
    /// 遮罩图片高度
    var coverHeight: CGFloat = 0
    
    /// 标题
    var title: String?
    
    /// 标题y坐标
    var titleY: CGFloat = 0
    
    /// 标题字体大小
    var titleFontSize: CGFloat = 0
    
    /// 标题字体名称 - 默认字体 平方中粗体
    var titleFontName: String = "PingFangSC-Semibold"
    
    /// 标题颜色16进制
    var titleTextColorHex: String?
    
    /// 副标题
    var subtitle: String?
    
    /// 副标题y坐标
    var subtitleY: CGFloat = 0
    
    /// 副标题字体大小
    var subtitleFontSize: CGFloat = 0
    
    /// 副标题字体名称 - 默认字体 平方中粗体
    var subtitleFontName: String = "PingFangSC-Semibold"
    
    /// 副标题颜色16进制
    var subtitleTextColorHex: String?
    
    /// 是否选中
    var isSelected: Bool = false
    
    override init() {
        super.init()
    }
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    func copy(with zone: NSZone? = nil) -> Any {
        let materialParameter = JFMaterialParameter()
        materialParameter.showImageName = showImageName
        materialParameter.sourceImageName = sourceImageName
        materialParameter.screenShotImage = screenShotImage
        materialParameter.screenShotX = screenShotX
        materialParameter.screenShotY = screenShotY
        materialParameter.screenShotWidth = screenShotWidth
        materialParameter.screenShotHeight = screenShotHeight
        materialParameter.accessoryImageName = accessoryImageName
        materialParameter.accessoryX = accessoryX
        materialParameter.accessoryY = accessoryY
        materialParameter.accessoryWidth = accessoryWidth
        materialParameter.accessoryHeight = accessoryHeight
        materialParameter.coverImageName = coverImageName
        materialParameter.coverX = coverX
        materialParameter.coverY = coverY
        materialParameter.coverWidth = coverWidth
        materialParameter.coverHeight = coverHeight
        materialParameter.title = title
        materialParameter.titleY = titleY
        materialParameter.titleFontSize = titleFontSize
        materialParameter.titleFontName = titleFontName
        materialParameter.titleTextColorHex = titleTextColorHex
        materialParameter.subtitle = subtitle
        materialParameter.subtitleY = subtitleY
        materialParameter.subtitleFontSize = subtitleFontSize
        materialParameter.subtitleFontName = subtitleFontName
        materialParameter.subtitleTextColorHex = subtitleTextColorHex
        materialParameter.isSelected = isSelected
        return materialParameter
    }
}

/// 素材
class JFMaterial: NSObject {
    
    /// 推荐类型 0 最新 1最热
    var commendType: Int = 0
    
    /// 列表展示的图片名称
    var listImageName: String?
    
    /// 素材参数模型集合
    var materialParameterList: [JFMaterialParameter]?
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "materialParameterList" {
            let data = value as! [[String : Any]]
            var materialParameterList = [JFMaterialParameter]()
            for dict in data {
                materialParameterList.append(JFMaterialParameter(dict: dict))
            }
            materialParameterList[0].isSelected = true
            self.materialParameterList = materialParameterList
            return
        }
        
        return super.setValue(value, forKey: key)
    }
    
    /// 获取素材模型集合
    ///
    /// - Returns: 素材模型集合
    class func getMaterialList() -> [JFMaterial] {
        
        let data = NSData(contentsOfFile: Bundle.main.path(forResource: "material", ofType: "json")!)!
        let materialArray = try! JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [[String : Any]]
        
        var materialList = [JFMaterial]()
        
        for dict in materialArray {
            let material = JFMaterial(dict: dict)
            materialList.append(material)
        }
        
        return materialList
        
    }
    
}
