//
//  JFPasterGroup.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/12.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFPasterGroup: NSObject {
    
    /// 贴纸组名
    var groupName: String
    
    /// 贴纸组icon名
    var iconName: String
    
    /// 贴纸组里的贴纸集合
    var pasterList: [JFPaster]
    
    /// 初始化贴图组模型
    ///
    /// - Parameters:
    ///   - groupName: 组名
    ///   - prefix: 前缀
    ///   - count: 数量
    init(groupName: String, prefix: String, count: Int) {
        
        self.groupName = groupName
        self.iconName = "\(prefix)_icon.png"
        
        var pasterList = [JFPaster]()
        for index in 1...count {
            let paster = JFPaster(iconName: "\(prefix)_compress_\(index).png")
            pasterList.append(paster)
        }
        self.pasterList = pasterList
        
        super.init()
    }

    /// 获取所有贴纸组
    ///
    /// - Returns: 贴纸组模型集合
    class func getPasterGroupList() -> [JFPasterGroup] {
        
        var pasterGroupList = [JFPasterGroup]()
        let shenjjm = JFPasterGroup(groupName: "神经猫", prefix: "shenjjm", count: 110)
        let HK = JFPasterGroup(groupName: "hello kitty", prefix: "HK", count: 95)
        let SC = JFPasterGroup(groupName: "蜡笔小新", prefix: "SC", count: 102)
        let DA = JFPasterGroup(groupName: "多啦A梦", prefix: "DA", count: 123)
        let Maruko = JFPasterGroup(groupName: "小丸子", prefix: "Maruko", count: 102)
        let cheesecat = JFPasterGroup(groupName: "奶酪猫", prefix: "cheesecat", count: 36)
        let COCO = JFPasterGroup(groupName: "小女人", prefix: "COCO", count: 77)
        let mengmengxiong_christmas = JFPasterGroup(groupName: "萌萌熊", prefix: "mengmengxiong_christmas", count: 32)
        
        pasterGroupList.append(shenjjm)
        pasterGroupList.append(HK)
        pasterGroupList.append(SC)
        pasterGroupList.append(DA)
        pasterGroupList.append(Maruko)
        pasterGroupList.append(cheesecat)
        pasterGroupList.append(COCO)
        pasterGroupList.append(mengmengxiong_christmas)
        
        return pasterGroupList
    }
    
}
