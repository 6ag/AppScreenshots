//
//  JFAlbumImageCollectionViewCell.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/8.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import Photos

/// 自定义相册图片cell
class JFAlbumImageCollectionViewCell: UICollectionViewCell {
    
    var assetItem: JFAssetItem? {
        didSet {
            guard let assetItem = assetItem else { return }
            
            // 加载图片
            PHCachingImageManager.default().requestImage(
            for: assetItem.asset,
            targetSize: CGSize(width: JFPhotoPickerViewItemWidth * 1.5, height: JFPhotoPickerViewItemWidth * 1.5),
            contentMode: .aspectFit,
            options: nil) { [weak self] (image, info) in
                self?.imageView.image = image
            }
            
            // 是否选中
            selectedButton.isSelected = assetItem.isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    /// 选中按钮
    lazy var selectedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "photo_picker_icon_normal"), for: .normal)
        button.setBackgroundImage(UIImage(named: "photo_picker_icon_selected"), for: .selected)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    /// 选中时的遮罩
    lazy var shadowView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        return view
    }()
    
}

// MARK: - 设置界面
extension JFAlbumImageCollectionViewCell {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(selectedButton)
        contentView.addSubview(shadowView)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        
        selectedButton.snp.makeConstraints { (make) in
            make.top.equalTo(layoutVertical(iPhone6: 2))
            make.right.equalTo(layoutHorizontal(iPhone6: -2))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 22), height: layoutVertical(iPhone6: 22)))
        }
        
        shadowView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
}
