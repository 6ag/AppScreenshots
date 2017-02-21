//
//  JFContextItem.swift
//  JianSan Wallpaper
//
//  Created by zhoujianfeng on 16/4/22.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFContextItem: UIView {
    
    // MARK: - 初始化
    init(itemName: String, itemIcon: String) {
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 40, height: 50)))
        
        itemLabel.text = itemName
        itemImage.image = UIImage(named: itemIcon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载
    lazy var itemLabel: UILabel = {
        let itemLabel = UILabel()
        itemLabel.frame = CGRect(x: 5, y: 0, width: self.frame.width - 10, height: 14)
        itemLabel.textColor = UIColor.white
        itemLabel.backgroundColor = UIColor(white: 0, alpha: 0.5)
        itemLabel.layer.cornerRadius = 8
        itemLabel.layer.masksToBounds = true
        itemLabel.textAlignment = NSTextAlignment.center
        itemLabel.font = UIFont.systemFont(ofSize: 10)
        self.addSubview(itemLabel)
        return itemLabel
    }()
    
    fileprivate lazy var itemImage: UIImageView = {
        let itemImage = UIImageView()
        itemImage.frame = CGRect(x: 9, y: 14, width: 25, height: 35)
        itemImage.contentMode = .scaleAspectFit
        self.addSubview(itemImage)
        return itemImage
    }()
    
}
