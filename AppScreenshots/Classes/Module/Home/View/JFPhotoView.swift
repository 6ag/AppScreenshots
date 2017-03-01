//
//  JFPhotoView.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/6.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

/// 生成应用截图的视图类
class JFPhotoView: UIView {
    
    /// 生成应用截图需要的参数模型
    fileprivate var materialParameter: JFMaterialParameter
    
    init(materialParameter: JFMaterialParameter) {
        self.materialParameter = materialParameter
        super.init(frame: SCREEN_BOUNDS)
        
        prepareUI()
        prepareData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载
    /// 模板图片
    fileprivate lazy var templeteImageView: UIImageView = {
        let imageView = UIImageView()
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
    
    /// 相册上传的截图
    fileprivate lazy var screenShotImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 配图图片
    fileprivate lazy var accessoryView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 遮罩图片
    fileprivate lazy var coverView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
}

// MARK: - 设置界面
extension JFPhotoView {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        addSubview(templeteImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(screenShotImageView)
        addSubview(coverView)
        addSubview(accessoryView)
        
        templeteImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(layoutVertical(iPhone6: materialParameter.titleY))
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(layoutVertical(iPhone6: materialParameter.subtitleY))
        }
        
        screenShotImageView.snp.makeConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: materialParameter.screenShotX))
            make.top.equalTo(layoutVertical(iPhone6: materialParameter.screenShotY))
            make.width.equalTo(layoutHorizontal(iPhone6: materialParameter.screenShotWidth))
            make.height.equalTo(layoutVertical(iPhone6: materialParameter.screenShotHeight))
        }
        
        accessoryView.snp.updateConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: materialParameter.accessoryX))
            make.top.equalTo(layoutVertical(iPhone6: materialParameter.accessoryY))
            make.width.equalTo(layoutHorizontal(iPhone6: materialParameter.accessoryWidth))
            make.height.equalTo(layoutVertical(iPhone6: materialParameter.accessoryHeight))
        }
        
        coverView.snp.updateConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: materialParameter.coverX))
            make.top.equalTo(layoutVertical(iPhone6: materialParameter.coverY))
            make.width.equalTo(layoutHorizontal(iPhone6: materialParameter.coverWidth))
            make.height.equalTo(layoutVertical(iPhone6: materialParameter.coverHeight))
        }
        
    }
    
    /// 准备数据
    fileprivate func prepareData() {
        
        // 模板图片
        templeteImageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: materialParameter.sourceImageName ?? "", ofType: nil) ?? "")
        
        // 相册上传的截图
        screenShotImageView.image = materialParameter.screenShotImage
        
        // 配图 - 不一定每个模板都有
        accessoryView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: materialParameter.accessoryImageName ?? "", ofType: nil) ?? "")
        
        // 遮罩图 - 不一定每个模板都有
        coverView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: materialParameter.coverImageName ?? "", ofType: nil) ?? "")
        
        // 标题
        titleLabel.text = materialParameter.title
        titleLabel.font = UIFont(name: materialParameter.titleFontName, size: layoutVertical(iPhone6: materialParameter.titleFontSize))
        titleLabel.textColor = UIColor.colorWithHexString(materialParameter.titleTextColorHex ?? "")
        
        // 副标题 - 不一定每个模板都有
        subtitleLabel.text = materialParameter.subtitle
        subtitleLabel.font = UIFont(name: materialParameter.subtitleFontName, size: layoutVertical(iPhone6: materialParameter.subtitleFontSize))
        subtitleLabel.textColor = UIColor.colorWithHexString(materialParameter.subtitleTextColorHex ?? "")
        
    }
}
