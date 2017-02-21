//
//  JFAlbumItemCollectionViewCell.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/9.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import Photos

/// 自定义相册的相册cell
class JFAlbumItemCollectionViewCell: UICollectionViewCell {
    
    var albumItem: JFAlbumItem? {
        didSet {
            guard let albumItem = albumItem, let asset = albumItem.fetchResult.lastObject else { return }
            
            // 加载图片
            PHCachingImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: JFPhotoPickerViewItemWidth * 1.5, height: JFPhotoPickerViewItemWidth * 1.5),
                contentMode: .aspectFit,
                options: nil) { [weak self] (image, info) in
                    self?.imageView.image = image
            }
            
            // 相册标题
            titleLabel.text = albumItem.title
            
            // 是否选中
            selectedButton.isHidden = !albumItem.isSelected
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
    
    /// 标题
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        return label
    }()
    
    /// 选中按钮
    lazy var selectedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "photo_picker_icon_selected"), for: .normal)
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
extension JFAlbumItemCollectionViewCell {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectedButton)
        contentView.addSubview(shadowView)
        
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 5))
            make.right.equalTo(layoutHorizontal(iPhone6: -5))
            make.top.equalTo(layoutVertical(iPhone6: 5))
            make.bottom.equalTo(layoutVertical(iPhone6: -25))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
        }
        
        selectedButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 22), height: layoutVertical(iPhone6: 22)))
        }
        
        shadowView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.imageView)
        }
    }
}
