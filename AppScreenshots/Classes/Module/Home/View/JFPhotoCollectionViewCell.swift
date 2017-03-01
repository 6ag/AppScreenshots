//
//  JFPhotoCollectionViewCell.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/4.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFPhotoCollectionViewCell: UICollectionViewCell {
    
    var materialParameter: JFMaterialParameter? {
        didSet {
            guard let materialParameter = materialParameter else { return }
            // 模板图片
            imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: materialParameter.sourceImageName ?? "", ofType: nil) ?? "")
            
            // 配图
            accessoryView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: materialParameter.accessoryImageName ?? "", ofType: nil) ?? "")
            
            // 遮罩
            coverView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: materialParameter.coverImageName ?? "", ofType: nil) ?? "")
            
            // 是否正在编辑
            selectedIconView.isHidden = !materialParameter.isSelected
            
            // 应用截图
            screenShotImageView.image = materialParameter.screenShotImage
            
            // 标题
            titleLabel.text = materialParameter.title
            titleLabel.font = UIFont(name: "PingFangSC-Semibold", size: SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.titleFontSize))
            titleLabel.textColor = UIColor.colorWithHexString(materialParameter.titleTextColorHex ?? "")
            
            // 副标题
            subtitleLabel.text = materialParameter.subtitle
            subtitleLabel.font = UIFont(name: "PingFangSC-Semibold", size: SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.subtitleFontSize))
            subtitleLabel.textColor = UIColor.colorWithHexString(materialParameter.subtitleTextColorHex ?? "")
            
            titleLabel.snp.updateConstraints { (make) in
                make.centerX.equalTo(contentView)
                make.top.equalTo(SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.titleY))
            }
            
            subtitleLabel.snp.updateConstraints { (make) in
                make.centerX.equalTo(contentView)
                make.top.equalTo(SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.subtitleY))
            }
            
            screenShotImageView.snp.updateConstraints { (make) in
                make.left.equalTo(SettingPhotoItemWidth / SCREEN_WIDTH * layoutHorizontal(iPhone6: materialParameter.screenShotX))
                make.top.equalTo(SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.screenShotY))
                make.width.equalTo(SettingPhotoItemWidth / SCREEN_WIDTH * layoutHorizontal(iPhone6: materialParameter.screenShotWidth))
                make.height.equalTo(SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.screenShotHeight))
            }
            
            accessoryView.snp.updateConstraints { (make) in
                make.left.equalTo(SettingPhotoItemWidth / SCREEN_WIDTH * layoutHorizontal(iPhone6: materialParameter.accessoryX))
                make.top.equalTo(SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.accessoryY))
                make.width.equalTo(SettingPhotoItemWidth / SCREEN_WIDTH * layoutHorizontal(iPhone6: materialParameter.accessoryWidth))
                make.height.equalTo(SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.accessoryHeight))
            }
            
            coverView.snp.updateConstraints { (make) in
                make.left.equalTo(SettingPhotoItemWidth / SCREEN_WIDTH * layoutHorizontal(iPhone6: materialParameter.coverX))
                make.top.equalTo(SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.coverY))
                make.width.equalTo(SettingPhotoItemWidth / SCREEN_WIDTH * layoutHorizontal(iPhone6: materialParameter.coverWidth))
                make.height.equalTo(SettingPhotoItemHeight / SCREEN_HEIGHT * layoutVertical(iPhone6: materialParameter.coverHeight))
            }
            
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
    /// 展示图
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = layoutHorizontal(iPhone6: 2)
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    /// 选中图标
    lazy var selectedIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "img_select"))
        return imageView
    }()
    
    /// 标题
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    /// 副标题
    fileprivate lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    /// 上传的屏幕截图
    fileprivate lazy var screenShotImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 配图
    fileprivate lazy var accessoryView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 遮罩
    fileprivate lazy var coverView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
}

// MARK: - 设置界面
extension JFPhotoCollectionViewCell {
    
    fileprivate func prepareUI() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(selectedIconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(screenShotImageView)
        contentView.addSubview(coverView)
        contentView.addSubview(accessoryView)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        
        selectedIconView.snp.makeConstraints { (make) in
            make.top.equalTo(layoutVertical(iPhone6: -5))
            make.size.equalTo(CGSize(
                width: layoutHorizontal(iPhone6: 15),
                height: layoutVertical(iPhone6: 15)))
            make.right.equalTo(layoutHorizontal(iPhone6: 5))
        }
        
    }
    
}
