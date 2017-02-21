//
//  JFContextSheet.swift
//  JianSan Wallpaper
//
//  Created by zhoujianfeng on 16/4/22.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFContextSheetDelegate {
    func contextSheet(_ contextSheet: JFContextSheet, didSelectItemWithItemName itemName: String)
}

class JFContextSheet: UIView {
    
    var delegate: JFContextSheetDelegate?
    
    /// 圆的半径 触摸点到选项的直线距离
    fileprivate var pathRadius: CGFloat = 100
    
    /// 横纵边界区域 可以想象成contentInset
    fileprivate var insetX: CGFloat = 100
    fileprivate var insetY: CGFloat = 120
    
    /// 是否正在显示
    var isShow = false
    
    // MARK: - 初始化
    init(items: Array<JFContextItem>) {
        super.init(frame: SCREEN_BOUNDS)
        
        for itemView in items {
            itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedItemWithItemName(_:))))
            addSubview(itemView)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTappedBgView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func didTappedBgView() {
        if isShow {
            dismiss()
        }
    }
    
    /**
     item触摸手势
     */
    @objc fileprivate func didTappedItemWithItemName(_ tap: UITapGestureRecognizer) {
        let itemView = tap.view as! JFContextItem
        
        // 回调触摸itemName
        delegate?.contextSheet(self, didSelectItemWithItemName: itemView.itemLabel.text!)
        
        // 移除视图
        dismiss()
    }
    
    /**
     隐藏视图
     */
    func dismiss() {
        
        isShow = false
        
        self.removeFromSuperview()
        centerView.removeFromSuperview()
    }
    
    /**
     根据圆心、角度、半径，计算圆上的点坐标
     
     - parameter center: 圆心
     - parameter angle:  角度
     - parameter radius: 半径
     
     - returns: 返回点坐标
     */
    fileprivate func getCircleCoordinate(_ center: CGPoint, angle: CGFloat, radius: CGFloat) -> CGPoint {
        let x = radius * CGFloat(cosf(Float(angle) * Float(M_PI) / 180))
        let y = radius * CGFloat(sinf(Float(angle) * Float(M_PI) / 180))
        return CGPoint(x: center.x + x, y: center.y + y)
    }
    
    /**
     制造弹簧动画
     
     - parameter startAngle:  开始角度
     - parameter endAngle:    结束角度
     - parameter centerPoint: 圆心点
     - parameter index:       角标
     - parameter itemView:    选项
     */
    fileprivate func makeSpringAnimation(_ startAngle: CGFloat, endAngle: CGFloat, centerPoint: CGPoint, index: Int, itemView: JFContextItem) -> Void {
        // 每个选项之间的角度间距
        let angleDistance = (endAngle - startAngle) / CGFloat(subviews.count - 1)
        let angle = startAngle + CGFloat(index) * angleDistance
        let destinationPoint = getCircleCoordinate(centerPoint, angle: angle, radius: pathRadius)
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: {
            itemView.alpha = 1.0
            let tx = destinationPoint.x - centerPoint.x
            let ty = destinationPoint.y - centerPoint.y
            itemView.transform = itemView.transform.translatedBy(x: tx, y: ty)
            }, completion: { (_) in
                
        })
    }
    
    /**
     开始弹簧动画
     
     - parameter centerPoint: 中心点
     */
    fileprivate func startSpringAnimation(_ centerPoint: CGPoint) {
        // item布局
        let itemWidth: CGFloat = 40
        let itemHeight: CGFloat = 50
        
        // 把所有item都以触摸点为原点
        for (index, item) in subviews.enumerated() {
            let itemView = item as! JFContextItem
            itemView.frame = CGRect(x: centerPoint.x - itemWidth * 0.5, y: centerPoint.y - itemHeight * 0.5, width: itemWidth, height: itemHeight)
            itemView.alpha = 0.0
            
            // 布局角度范围
            var startAngle: CGFloat = 0     // 开始角度
            var endAngle: CGFloat = 0       // 结束角度
            let extendAngle: CGFloat = 8    // 在四角的时候扩大角度
            let cornerRadius: CGFloat = 120 // 在四角时半径
            let sideRadius: CGFloat = 90    // 在四边时半径
            
            // 左上
            if centerPoint.x <= insetX && centerPoint.y <= insetY {
                pathRadius = cornerRadius
                startAngle = 0 - extendAngle
                endAngle = 90 + extendAngle
            }
            
            // 上
            if centerPoint.x > insetX && centerPoint.x <= SCREEN_WIDTH - insetX && centerPoint.y <= insetY {
                pathRadius = sideRadius
                switch subviews.count {
                case 1:
                    startAngle = 90
                    endAngle = 90
                    break
                case 2, 3:
                    startAngle = 135
                    endAngle = 45
                    break
                case 4:
                    startAngle = 150
                    endAngle = 30
                    break
                case 5:
                    startAngle = 180
                    endAngle = 0
                    break
                default:
                    break
                }
            }
            
            // 右上角
            if centerPoint.x > SCREEN_WIDTH - insetX && centerPoint.y <= insetY {
                pathRadius = cornerRadius
                startAngle = 180 + extendAngle
                endAngle = 90 - extendAngle
            }
            
            // 左
            if centerPoint.x <= insetX && centerPoint.y > insetY && centerPoint.y <= SCREEN_HEIGHT - insetY {
                pathRadius = sideRadius
                switch subviews.count {
                case 1:
                    startAngle = 90
                    endAngle = 90
                    break
                case 2, 3:
                    startAngle = -45
                    endAngle = 45
                    break
                case 4:
                    startAngle = -60
                    endAngle = 60
                    break
                case 5:
                    startAngle = -90
                    endAngle = 90
                    break
                default:
                    break
                }
            }
            
            // 左下
            if centerPoint.x <= insetX && centerPoint.y > SCREEN_HEIGHT - insetY {
                pathRadius = cornerRadius
                startAngle = -90 - extendAngle
                endAngle = 0 + extendAngle
            }
            
            // 中间区域/下
            if centerPoint.x > insetX && centerPoint.x < SCREEN_WIDTH - insetX && centerPoint.y > insetY {
                pathRadius = sideRadius
                switch subviews.count {
                case 1:
                    startAngle = -90
                    endAngle = -90
                    break
                case 2, 3:
                    startAngle = -135
                    endAngle = -45
                    break
                case 4:
                    startAngle = -150
                    endAngle = -30
                    break
                case 5:
                    startAngle = -180
                    endAngle = 0
                    break
                default:
                    break
                }
            }
            
            // 右
            if centerPoint.x > SCREEN_WIDTH - insetX && centerPoint.y > insetY && centerPoint.y <= SCREEN_HEIGHT - insetY {
                pathRadius = sideRadius
                switch subviews.count {
                case 1:
                    startAngle = 180
                    endAngle = 180
                    break
                case 2, 3:
                    startAngle = 225
                    endAngle = 135
                    break
                case 4:
                    startAngle = 130
                    endAngle = 240
                    break
                case 5:
                    startAngle = 270
                    endAngle = 90
                    break
                default:
                    break
                }
            }
            
            // 右下
            if centerPoint.x > SCREEN_WIDTH - insetX && centerPoint.y > SCREEN_HEIGHT - insetY {
                pathRadius = cornerRadius
                startAngle = 270 + extendAngle
                endAngle = 180 - extendAngle
            }
            
            // 制造动画
            makeSpringAnimation(startAngle, endAngle: endAngle, centerPoint: centerPoint, index: index, itemView: itemView)
            
        }
    }
    
    /**
     根据手势弹出sheet
     
     - parameter gestureRecognizer: 手势
     - parameter inView:            手势所在视图
     */
    func startWithGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, inView: UIView) {
        
        isShow = true
        
        // 添加弹出视图
        inView.addSubview(self)
        
        // 遮罩用当前view
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        // 触摸圆点
        let centerPoint = gestureRecognizer.location(in: inView)
        
        // 开始弹簧动画
        startSpringAnimation(centerPoint)
        
        // 圆点视图
        centerView.frame = CGRect(x: centerPoint.x - 20, y: centerPoint.y - 20, width: 40, height: 40)
        inView.addSubview(centerView)
        
    }
    
    // MARK: - 懒加载
    fileprivate lazy var centerView: UIView = {
        let centerView = UIView()
        centerView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        centerView.layer.cornerRadius = 20
        centerView.layer.masksToBounds = true
        centerView.layer.borderColor = UIColor(red:0.502,  green:0.502,  blue:0.502, alpha:0.5).cgColor
        centerView.layer.borderWidth = 2.0
        return centerView
    }()
    
    
}
