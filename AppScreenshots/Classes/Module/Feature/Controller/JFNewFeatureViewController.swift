//
//  JFNewFeatureViewController.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/10.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

/// 新特性图片数量
fileprivate let count = 3

class JFNewFeatureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    /// 跳过
    ///
    /// - Parameter jumpButton: 跳过
    @objc fileprivate func didTapped(jumpButton: UIButton) {
        UIApplication.shared.keyWindow?.rootViewController = JFHomeViewController()
        
        // 视图转图片
        UIGraphicsBeginImageContextWithOptions(SCREEN_BOUNDS.size, true, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: image)
        UIApplication.shared.keyWindow?.addSubview(imageView)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            (UIApplication.shared.delegate as! AppDelegate).setupGlobalStyle()
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.2, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            imageView.alpha = 0
            imageView.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        }) { (_) in
            imageView.removeFromSuperview()
        }
        
    }
    
    /// 下一步
    ///
    /// - Parameter nextButton: 下一步
    @objc fileprivate func didTapped(nextButton: UIButton) {
        let index = Int(containerView.contentOffset.x / SCREEN_WIDTH)
        if index == count - 1 {
            didTapped(jumpButton: jumpButton)
        } else {
            containerView.setContentOffset(CGPoint(x: CGFloat(index + 1) * SCREEN_WIDTH, y: 0), animated: true)
        }
    }
    
    // MARK: - 懒加载
    fileprivate lazy var containerView: UIScrollView = {
        let scrollView = UIScrollView(frame: SCREEN_BOUNDS)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    /// 跳过
    fileprivate lazy var jumpButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.colorWithHexString("6c6e6f"), for: .normal)
        button.setTitle("跳过", for: .normal)
        button.addTarget(self, action: #selector(didTapped(jumpButton:)), for: .touchUpInside)
        return button
    }()
    
    /// 下一步
    fileprivate lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.colorWithHexString("6c6e6f"), for: .normal)
        button.setTitle("下一页", for: .normal)
        button.addTarget(self, action: #selector(didTapped(nextButton:)), for: .touchUpInside)
        return button
    }()
    
    /// 分页指示器
    fileprivate lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.colorWithHexString("6c6e6f")
        pageControl.numberOfPages = count
        return pageControl
    }()
    
}

// MARK: - 设置界面
extension JFNewFeatureViewController {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        view.backgroundColor = BACKGROUND_COLOR
        
        view.addSubview(containerView)
        view.addSubview(jumpButton)
        view.addSubview(nextButton)
        view.addSubview(pageControl)
        
        for index in 1...count {
            let imageView = UIImageView(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "feature_\(index).jpg", ofType: nil)!))
            imageView.backgroundColor = UIColor.red
            imageView.frame = CGRect(x: CGFloat(index - 1) * SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            containerView.addSubview(imageView)
        }
        
        containerView.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(count), height: 0)
        
        jumpButton.snp.makeConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 0))
            make.bottom.equalTo(layoutVertical(iPhone6: 0))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 80), height: layoutVertical(iPhone6: 80)))
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.right.equalTo(layoutHorizontal(iPhone6: 0))
            make.bottom.equalTo(layoutVertical(iPhone6: 0))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 80), height: layoutVertical(iPhone6: 80)))
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(layoutVertical(iPhone6: -120))
        }
    }
    
}

// MARK: - UIScrollViewDelegate
extension JFNewFeatureViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / SCREEN_WIDTH
        let page = lroundf(Float(index))
        pageControl.currentPage = page
        if page == count - 1 {
            UIView.animate(withDuration: 0.25, animations: { 
                self.nextButton.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.nextButton.alpha = 1
            })
        }
        
    }
    
    /// 松手后判断偏移量，超过则进入主页
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        // 滑动到最后一页，并且超出了边界30%，则进入首页
        if scrollView.contentOffset.x / SCREEN_WIDTH > CGFloat(count - 1) + 0.1 {
            
            UIApplication.shared.keyWindow?.rootViewController = JFHomeViewController()
            
            // 视图转图片
            UIGraphicsBeginImageContextWithOptions(SCREEN_BOUNDS.size, true, UIScreen.main.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return }
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: -SCREEN_WIDTH * 0.1, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            UIApplication.shared.keyWindow?.addSubview(imageView)
            
            (UIApplication.shared.delegate as! AppDelegate).setupGlobalStyle()
            
            UIView.animate(withDuration: 0.25, animations: {
                imageView.transform = CGAffineTransform(translationX: -SCREEN_WIDTH, y: 0)
            }, completion: { (_) in
                imageView.removeFromSuperview()
            })
            
        }
    }
    
}
