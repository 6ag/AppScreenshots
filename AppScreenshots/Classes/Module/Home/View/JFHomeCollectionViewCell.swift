//
//  JFHomeCollectionViewCell.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/3.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFHomeCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var material: JFMaterial? {
        didSet {
            guard let material = material else { return }
            imageView.image = UIImage(named: material.listImageName ?? "")?.redrawRoundedImage(size: CGSize(width: HomeItemWidth, height: HomeItemHeight), bgColor: BACKGROUND_COLOR, cornerRadius: 10)
            
            if material.commendType == 0 {
                typeIconView.image = UIImage(named: "home_latest")
            } else {
                typeIconView.image = UIImage(named: "home_hot")
            }
            
        }
    }
    
    // MARK: - 懒加载
    /// 展示图
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 类型图标
    fileprivate lazy var typeIconView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
}

// MARK: - 设置界面
extension JFHomeCollectionViewCell {
    
    fileprivate func prepareUI() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(typeIconView)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        typeIconView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 22), height: layoutVertical(iPhone6: 34)))
            make.right.equalTo(layoutHorizontal(iPhone6: -20))
        }
        
    }
    
}
