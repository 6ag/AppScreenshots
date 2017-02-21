//
//  JFAssetItem.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/8.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import Photos

class JFAssetItem: NSObject {
    
    /// 资源
    var asset: PHAsset
    
    /// 是否选中
    var isSelected = false
    
    init(asset: PHAsset) {
        self.asset = asset
        super.init()
    }
    
}
