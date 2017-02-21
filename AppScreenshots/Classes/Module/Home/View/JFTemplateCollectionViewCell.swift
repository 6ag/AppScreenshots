//
//  JFTemplateCollectionViewCell.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/4.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFTemplateCollectionViewCell: UICollectionViewCell {
    
    var materialParameter: JFMaterialParameter? {
        didSet {
            guard let materialParameter = materialParameter else { return }
            imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: materialParameter.showImageName ?? "", ofType: nil) ?? "")
            selectedIconView.isHidden = !materialParameter.isSelected
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
}

// MARK: - 设置界面
extension JFTemplateCollectionViewCell {
    
    fileprivate func prepareUI() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(selectedIconView)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
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
