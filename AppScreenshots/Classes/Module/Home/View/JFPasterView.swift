//
//  JFPasterView.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/21.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

fileprivate let FLEX_SLIDE: CGFloat = 10.0
fileprivate let BT_SLIDE: CGFloat = 20.0
fileprivate let BORDER_LINE_WIDTH: CGFloat = 1.0
fileprivate let SECURITY_LENGTH: CGFloat = 75.0
fileprivate let MAX_HEIGHT: CGFloat = 300
fileprivate let MAX_WIDTH: CGFloat = 200

protocol JFPasterViewDelegate: NSObjectProtocol {
    func makePasterBecomeFirstRespond(pasterID: Int)
    func removePaster(pasterID: Int)
}

class JFPasterView: UIView {
    
    /// 贴纸id
    var pasterID = 0
    
    /// 贴纸图片宽度
    var imgWidth: CGFloat = 0
    
    /// 贴纸图片高度
    var imgHeight: CGFloat = 0
    
    /// 贴纸能缩放的最小宽度
    var minWidth: CGFloat = 0
    
    /// 贴纸能缩放的最小高度
    var minHeight: CGFloat = 0
    
    /// 记录上一个点
    var prevPoint: CGPoint = CGPoint.zero
    
    /// 开始触摸点
    var touchStart: CGPoint = CGPoint.zero
    
    /// 角度
    var deltaAngle: CGFloat = 0
    
    weak var delegate: JFPasterViewDelegate?
    
    init(pasterStageView: JFPasterStageView, pasterID: Int, imagePaster: UIImage) {
        // 限定图片的最大尺寸
        imgWidth = imagePaster.size.width
        imgHeight = imagePaster.size.height
        if imgWidth > MAX_WIDTH {
            imgWidth = MAX_WIDTH
            imgHeight = imgWidth * (imagePaster.size.height * imagePaster.scale) / (imagePaster.size.width * imagePaster.scale)
        } else if imgHeight > MAX_HEIGHT {
            imgHeight = MAX_HEIGHT
            imgWidth = imgHeight * (imagePaster.size.width * imagePaster.scale) / (imagePaster.size.height * imagePaster.scale)
        }
        
        self.pasterID = pasterID
        isOnFirst = true
        
        super.init(frame: CGRect.zero)
        
        frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
        center = CGPoint(x: pasterStageView.frame.size.width / 2, y: pasterStageView.frame.size.height / 2)
        backgroundColor = nil
        minWidth = bounds.size.width * 0.5
        minHeight = bounds.size.height * 0.5
        deltaAngle = atan2(frame.origin.y + frame.size.height - center.y,
                           frame.origin.x + frame.size.width - center.x)
        
        addSubview(imageContentView)
        addSubview(deleteButton)
        addSubview(rotationButton)
        addSubview(turnButton)
        
        imageContentView.image = imagePaster
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(tapGesture:)))
        addGestureRecognizer(tapGesture)
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(rotateGesture:)))
        addGestureRecognizer(rotateGesture)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            var rect = CGRect.zero
            rect.origin = CGPoint(x: FLEX_SLIDE, y: FLEX_SLIDE)
            rect.size = CGSize(width: imgWidth - FLEX_SLIDE * 2, height: imgHeight - FLEX_SLIDE * 2)
            self.imageContentView.frame = rect
            self.imageContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    /// 是否是正在编辑的图片
    public var isOnFirst = false {
        didSet {
            deleteButton.isHidden = !isOnFirst
            rotationButton.isHidden = !isOnFirst
            turnButton.isHidden = !isOnFirst
            imageContentView.layer.borderWidth = isOnFirst ? BORDER_LINE_WIDTH : 0.0
        }
    }
    
    // 移除贴纸
    public func remove() {
        removeFromSuperview()
        delegate?.removePaster(pasterID: pasterID)
    }
    
    /// 删除
    @objc fileprivate func deleteButtonPressed(recognizer: AnyObject) {
        remove()
    }
    
    /// 图片翻转
    @objc fileprivate func transition(recognizer: UITapGestureRecognizer) {
        let image = imageContentView.image?.copy() as! UIImage
        imageContentView.image = UIImage(
            cgImage: image.cgImage!,
            scale: image.scale,
            orientation: UIImageOrientation(rawValue: (image.imageOrientation.rawValue + 4) % 8)!)
    }
    
    /// 旋转缩放
    @objc fileprivate func resizeTranslate(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            prevPoint = recognizer.location(in: self)
            setNeedsDisplay()
        } else if recognizer.state == .changed {
            if bounds.size.width < minWidth || bounds.size.height < minHeight {
                bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: minWidth + 1, height: minHeight + 1)
                rotationButton.frame = CGRect(x: bounds.size.width-BT_SLIDE, y: bounds.size.height - BT_SLIDE, width: BT_SLIDE, height: BT_SLIDE)
                prevPoint = recognizer.location(in: self)
            } else {
                let point = recognizer.location(in: self)
                var wChange: CGFloat = 0.0
                var hChange: CGFloat = 0.0
                wChange = point.x - prevPoint.x
                let wRatioChange: CGFloat = wChange / CGFloat(bounds.size.width)
                hChange = wRatioChange * bounds.size.height
                if abs(wChange) > 50.0 || abs(hChange) > 50.0 {
                    prevPoint = recognizer.location(ofTouch: 0, in: self)
                    return
                }
                var finalWidth = bounds.size.width + wChange
                var finalHeight = bounds.size.height + wChange
                if finalWidth > imgWidth * 1.5 {
                    finalWidth = imgWidth * 1.5
                }
                if finalWidth < imgWidth * 0.5 {
                    finalWidth = imgWidth * 0.5
                }
                if finalHeight > imgHeight * 1.5 {
                    finalHeight = imgHeight * 1.5
                }
                if finalHeight < imgHeight * 0.5 {
                    finalHeight = imgHeight * 0.5
                }
                bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: finalWidth, height: finalHeight)
                rotationButton.frame = CGRect(x: bounds.size.width-BT_SLIDE, y: bounds.size.height - BT_SLIDE, width: BT_SLIDE, height: BT_SLIDE)
                turnButton.frame = CGRect(x: 0, y: bounds.size.height - BT_SLIDE, width: BT_SLIDE, height: BT_SLIDE)
                prevPoint = recognizer.location(ofTouch: 0, in: self)
            }
            
            let ang = atan2(recognizer.location(in: superview).y - center.y, recognizer.location(in: superview).x - center.x)
            let angleDiff = deltaAngle - ang
            self.transform = CGAffineTransform(rotationAngle: -angleDiff)
            setNeedsDisplay()
        } else if recognizer.state == .ended {
            prevPoint = recognizer.location(in: self)
            setNeedsDisplay()
        }
    }
    
    /// 点击了贴纸，使成为第一响应者
    @objc fileprivate func handleTap(tapGesture: UITapGestureRecognizer) {
        isOnFirst = true
        delegate?.makePasterBecomeFirstRespond(pasterID: pasterID)
    }
    
    /// 旋转手势
    @objc fileprivate func handleRotation(rotateGesture: UIRotationGestureRecognizer) {
        isOnFirst = true
        delegate?.makePasterBecomeFirstRespond(pasterID: pasterID)
        transform = transform.rotated(by: rotateGesture.rotation)
        rotateGesture.rotation = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isOnFirst = true
        delegate?.makePasterBecomeFirstRespond(pasterID: pasterID)
        touchStart = (touches.first?.location(in: superview))!
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation: CGPoint = touches.first!.location(in: self)
        if rotationButton.frame.contains(touchLocation) {
            return
        }
        let touch: CGPoint = touches.first!.location(in: superview)
        translateUsingTouchLocation(touchPoint: touch)
        touchStart = touch
    }
    
    fileprivate func translateUsingTouchLocation(touchPoint: CGPoint) {
        var newCenter: CGPoint = CGPoint(x: center.x + touchPoint.x - touchStart.x, y: center.y + touchPoint.y - touchStart.y)
        
        let midPointX: CGFloat = bounds.midX
        if newCenter.x > (superview?.bounds.size.width)! - midPointX + SECURITY_LENGTH {
            newCenter.x = (superview?.bounds.size.width)! - midPointX + SECURITY_LENGTH
        }
        if newCenter.x < midPointX - SECURITY_LENGTH {
            newCenter.x = midPointX - SECURITY_LENGTH
        }
        let midPointY: CGFloat = bounds.midY
        if newCenter.y > (superview?.bounds.size.height)! - midPointY + SECURITY_LENGTH {
            newCenter.y = (superview?.bounds.size.height)! - midPointY + SECURITY_LENGTH
        }
        if newCenter.y < midPointY - SECURITY_LENGTH {
            newCenter.y = midPointY - SECURITY_LENGTH
        }
        center = newCenter
    }
    
    // MARK: - 懒加载
    /// 贴纸图片
    fileprivate lazy var imageContentView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(
            x: FLEX_SLIDE,
            y: FLEX_SLIDE,
            width: self.imgWidth - FLEX_SLIDE * 2,
            height: self.imgHeight - FLEX_SLIDE * 2))
        imageView.backgroundColor = nil
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = BORDER_LINE_WIDTH
        imageView.layer.cornerRadius = 3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 删除图标
    fileprivate lazy var deleteButton: UIImageView = {
        let imageView = UIImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: BT_SLIDE,
            height: BT_SLIDE))
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "paster_delete_icon")
        var tap = UITapGestureRecognizer(target: self, action: #selector(deleteButtonPressed(recognizer:)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    /// 旋转缩放图标
    fileprivate lazy var rotationButton: UIImageView = {
        let imageView = UIImageView(frame: CGRect(
            x: self.frame.size.width - BT_SLIDE,
            y: self.frame.size.height - BT_SLIDE,
            width: BT_SLIDE,
            height: BT_SLIDE))
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "paster_modify_size_icon")
        var panResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(resizeTranslate(recognizer:)))
        imageView.addGestureRecognizer(panResizeGesture)
        return imageView
    }()
    
    /// 翻转图标
    fileprivate lazy var turnButton: UIImageView = {
        let imageView = UIImageView(frame: CGRect(
            x: 0,
            y: self.frame.size.height - BT_SLIDE,
            width: BT_SLIDE,
            height: BT_SLIDE))
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "paster_transition_icon")
        var panResizeGesture = UITapGestureRecognizer(target: self, action: #selector(transition(recognizer:)))
        imageView.addGestureRecognizer(panResizeGesture)
        return imageView
    }()
    
}

