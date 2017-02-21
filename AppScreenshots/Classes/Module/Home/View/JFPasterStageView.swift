//
//  JFPasterStageView.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/21.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFPasterStageViewDelegate: NSObjectProtocol {
    func didTappedBgView()
}

class JFPasterStageView: UIView {
    
    weak var delegate: JFPasterStageViewDelegate?
    
    /// 贴纸集合
    fileprivate var pasterList = [JFPasterView]()
    
    /// 当前贴图
    fileprivate var pasterCurrent: JFPasterView? {
        didSet {
            self.bringSubview(toFront: pasterCurrent!)
        }
    }
    
    // 记录贴纸的id
    fileprivate var newPasterID: Int = 0
    
    /// 原图
    public var originImage: UIImage? {
        didSet {
            self.imgView.image = originImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 准备UI
    private func prepareUI() {
        addSubview(bgButton)
        addSubview(imgView)
    }
    
    /**
     添加贴图
     
     - param: imgPater 贴图图片
     */
    public func addPasterWithImg(imgPater: UIImage) {
        clearAllOnFirst()
        newPasterID += 1
        pasterCurrent = JFPasterView(pasterStageView: self, pasterID: newPasterID, imagePaster: imgPater)
        pasterCurrent?.delegate = self
        pasterList.append(pasterCurrent!)
        addSubview(pasterCurrent!)
    }
    
    /// 获取已经贴图后的图片
    ///
    /// - Returns: 贴纸后生成的新图
    public func doneEdit() -> UIImage {
        clearAllOnFirst()
        return getImageFromView(theView: self)
    }
    
    /// 将UIView转成UIImage
    func getImageFromView(theView: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(theView.bounds.size, true, UIScreen.main.scale)
        theView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 点击了背景
    func backgroundClicked(btBg: UIButton) {
        clearAllOnFirst()
        delegate?.didTappedBgView()
    }
    
    /**
     清除贴纸操作状态
     */
    func clearAllOnFirst() {
        pasterCurrent?.isOnFirst = false
        for paster in pasterList {
            paster.isOnFirst = false
        }
    }
    
    // MARK: - 懒加载
    /**
     背景按钮
     */
    fileprivate lazy var bgButton: UIButton = {
        let button = UIButton(frame: self.frame)
        button.tintColor = nil
        button.backgroundColor = nil
        button.addTarget(self, action: #selector(backgroundClicked(btBg:)), for: .touchUpInside)
        return button
    }()
    
    /**
     需要编辑的视图
     */
    fileprivate lazy var imgView: UIImageView = {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        return imageView
    }()
    
}

// MARK: - JFPasterViewDelegate
extension JFPasterStageView: JFPasterViewDelegate {
    
    /**
     让指定贴纸成为第一响应者
     
     - param: pasterID 贴纸id
     */
    func makePasterBecomeFirstRespond(pasterID: Int) {
        
        for paster in pasterList {
            paster.isOnFirst = false
            if paster.pasterID == pasterID {
                pasterCurrent = paster
                paster.isOnFirst = true
            }
        }
    }
    
    /**
     移除指定贴纸
     
     - param: pasterID 贴纸id
     */
    func removePaster(pasterID: Int) {
        
        for (index, paster) in pasterList.enumerated() {
            if paster.pasterID == pasterID {
                pasterList.remove(at: index)
                break
            }
        }
        
    }
    
}

