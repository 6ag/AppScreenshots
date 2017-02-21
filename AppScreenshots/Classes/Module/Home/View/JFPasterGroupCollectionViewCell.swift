//
//  JFPasterGroupCollectionViewCell.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/12.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFPasterGroupCollectionViewCell: UICollectionViewCell {
    
    /// 贴纸组模型
    var pasterGroup: JFPasterGroup? {
        didSet {
            imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: pasterGroup?.iconName ?? "", ofType: nil) ?? "")
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
extension JFPasterGroupCollectionViewCell {
    
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
