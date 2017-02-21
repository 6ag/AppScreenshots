//
//  JFPasterCollectionViewCell.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/10.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

/// 贴纸集合自定义cell - 现在和组的cell一样的，以后可能改，所以写成2个cell
class JFPasterCollectionViewCell: UICollectionViewCell {
    
    /// 贴纸
    var paster: JFPaster? {
        didSet {
            imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: paster?.iconName ?? "", ofType: nil) ?? "")
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
    /// 贴纸
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 圆角背景
    lazy var bgView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.colorWithHexString("#333333", alpha: 0.3)
        return view
    }()
    
}

// MARK: - 设置界面
extension JFPasterCollectionViewCell {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        contentView.addSubview(bgView)
        contentView.addSubview(imageView)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 8))
            make.right.equalTo(layoutHorizontal(iPhone6: -8))
            make.top.equalTo(layoutVertical(iPhone6: 8))
            make.bottom.equalTo(layoutVertical(iPhone6: -8))
        }
        
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 12))
            make.right.equalTo(layoutHorizontal(iPhone6: -12))
            make.top.equalTo(layoutVertical(iPhone6: 12))
            make.bottom.equalTo(layoutVertical(iPhone6: -12))
        }
        
    }
}
