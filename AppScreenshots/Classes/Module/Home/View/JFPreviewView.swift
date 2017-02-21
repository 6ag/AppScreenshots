//
//  JFPreviewView.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/7.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

/// 预览视图
class JFPreviewView: UIView {

    /// 应用截图视图集合
    fileprivate var photoViewList: [JFPhotoView]
    
    /// 默认下标
    fileprivate var defaultIndex: Int
    
    init(photoViewList: [JFPhotoView], defaultIndex: Int) {
        self.photoViewList = photoViewList
        self.defaultIndex = defaultIndex
        super.init(frame: SCREEN_BOUNDS)
        
        prepareUI()
        
        // 预览视图tap手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载
    /// 预览滚动视图
    fileprivate lazy var containerView: UIScrollView = {
        let scrollView = UIScrollView(frame: SCREEN_BOUNDS)
        scrollView.backgroundColor = BACKGROUND_COLOR
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    /// 页码标签
    fileprivate lazy var pageLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: 44))
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        return label
    }()
    
}

// MARK: - public方法
extension JFPreviewView {
    
    /// 显示预览图
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        
        self.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1.0
        }) { (_) in
            UIApplication.shared.isStatusBarHidden = true
        }
        
    }
    
    /// 隐藏预览图
    func dismiss() {
        UIApplication.shared.isStatusBarHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
}

// MARK: - 设置界面
extension JFPreviewView {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        addSubview(containerView)
        addSubview(pageLabel)
        pageLabel.text = "\(defaultIndex + 1) / \(photoViewList.count)"
        for (index, photoView) in photoViewList.enumerated() {
            photoView.frame = CGRect(x: CGFloat(index) * SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            containerView.addSubview(photoView)
        }
        containerView.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(photoViewList.count), height: 0)
        containerView.setContentOffset(CGPoint(x: CGFloat(defaultIndex) * SCREEN_WIDTH, y: 0), animated: true)
        
    }
}

// MARK: - 监听滚动
extension JFPreviewView: UIScrollViewDelegate {
    
    // 修改页码指示器
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageLabel.text = "\(Int(scrollView.contentOffset.x / SCREEN_WIDTH) + 1) / \(photoViewList.count)"
    }
    
}
