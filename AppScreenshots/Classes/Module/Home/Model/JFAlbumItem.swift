//
//  JFAlbumItem.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/8.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import Photos

/// 相册
class JFAlbumItem: NSObject {

    // 相簿名称
    var title: String
    
    // 相簿内的资源
    var fetchResult: PHFetchResult<PHAsset>
    
    /// 是否选中
    var isSelected = false
    
    init(title: String?, fetchResult: PHFetchResult<PHAsset>) {
        self.title = title ?? "未命名相册"
        self.fetchResult = fetchResult
    }
    
    /// 获取自定义相册集合
    ///
    /// - Returns: 自定义相册集合
    class func getAlbumItemList() -> [JFAlbumItem] {
        
        var albumItemList = [JFAlbumItem]()
        
        // 列出所有系统的智能相册
        let smartOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: PHAssetCollectionSubtype.albumRegular,
            options: smartOptions)
        albumItemList.append(contentsOf: convertCollection(smartAlbums as! PHFetchResult<AnyObject>))
        
        // 列出所有用户创建的相册
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        albumItemList.append(contentsOf: convertCollection(userCollections as! PHFetchResult<AnyObject>))
        
        // 相册按包含的照片数量排序（降序）
        albumItemList.sort { (item1, item2) -> Bool in
            return item1.fetchResult.count > item2.fetchResult.count
        }
        
        return albumItemList
    }
    
    /// 转成系统集合为自定义相册集合
    ///
    /// - Parameter collection: 系统集合
    /// - Returns: 自定义相册集合
    fileprivate class func convertCollection(_ collection: PHFetchResult<AnyObject>) -> [JFAlbumItem] {
        
        var albumItemList = [JFAlbumItem]()
        
        for i in 0..<collection.count {
            // 获取出当前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            guard let c = collection[i] as? PHAssetCollection else { return albumItemList}
            let assetsFetchResult = PHAsset.fetchAssets(in: c, options: resultsOptions)
            
            // 没有图片的空相簿不显示
            if assetsFetchResult.count > 0 {
                albumItemList.append(JFAlbumItem(title: c.localizedTitle, fetchResult: assetsFetchResult))
            }
            
        }
        
        return albumItemList
    }
    
}
