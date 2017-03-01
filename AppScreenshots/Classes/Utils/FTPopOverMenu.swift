//
//  FTPopOverMenu.swift
//  FTPopOverMenu
//
//  Created by liufengting on 16/11/2016.
//  Copyright © 2016 LiuFengting (https://github.com/liufengting) . All rights reserved.
//

import UIKit

extension FTPopOverMenu {
    
    public static func showForSender(sender : UIView, with menuArray: [String], done: @escaping (NSInteger)->(), cancel:@escaping ()->()) {
        self.sharedMenu.showForSender(sender: sender, or: nil, with: menuArray, menuImageArray: [], done: done, cancel: cancel)
    }
    public static func showForSender(sender : UIView, with menuArray: [String], menuImageArray: [String], done: @escaping (NSInteger)->(), cancel:@escaping ()->()) {
        self.sharedMenu.showForSender(sender: sender, or: nil, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func showForEvent(event : UIEvent, with menuArray: [String], done: @escaping (NSInteger)->(), cancel:@escaping ()->()) {
        self.sharedMenu.showForSender(sender: event.allTouches?.first?.view!, or: nil, with: menuArray, menuImageArray: [], done: done, cancel: cancel)
    }
    public static func showForEvent(event : UIEvent, with menuArray: [String], menuImageArray: [String], done: @escaping (NSInteger)->(), cancel:@escaping ()->()) {
        self.sharedMenu.showForSender(sender: event.allTouches?.first?.view!, or: nil, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func showFromSenderFrame(senderFrame : CGRect, with menuArray: [String], done: @escaping (NSInteger)->(), cancel:@escaping ()->()) {
        self.sharedMenu.showForSender(sender: nil, or: senderFrame, with: menuArray, menuImageArray: [], done: done, cancel: cancel)
    }
    public static func showFromSenderFrame(senderFrame : CGRect, with menuArray: [String], menuImageArray: [String], done: @escaping (NSInteger)->(), cancel:@escaping ()->()) {
        self.sharedMenu.showForSender(sender: nil, or: senderFrame, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func dismiss() {
        self.sharedMenu.dismiss()
    }
}

public class FTConfiguration : NSObject {
    
    public var menuRowHeight : CGFloat = FTDefaultMenuRowHeight
    public var menuWidth : CGFloat = FTDefaultMenuWidth
    public var textColor : UIColor = UIColor.white
    public var textFont : UIFont = UIFont.systemFont(ofSize: 14)
    public var borderColor : UIColor = FTDefaultTintColor
    public var borderWidth : CGFloat = FTDefaultBorderWidth
    public var backgoundTintColor : UIColor = FTDefaultTintColor
    public var cornerRadius : CGFloat = FTDefaultCornerRadius
    public var textAlignment : NSTextAlignment = NSTextAlignment.left
    public var ignoreImageOriginalColor : Bool = false
    public var menuSeparatorColor : UIColor = UIColor.lightGray
    public var menuSeparatorInset : UIEdgeInsets = UIEdgeInsetsMake(0, FTDefaultCellMargin, 0, FTDefaultCellMargin)
    
    public static var shared : FTConfiguration {
        struct StaticConfig {
            static let instance : FTConfiguration = FTConfiguration()
        }
        return StaticConfig.instance
    }
    
}

fileprivate let FTDefaultMargin : CGFloat = layoutHorizontal(iPhone6: 4)
fileprivate let FTDefaultCellMargin : CGFloat = layoutHorizontal(iPhone6: 15)
fileprivate let FTDefaultMenuIconSize : CGFloat = layoutHorizontal(iPhone6: 20)
fileprivate let FTDefaultMenuCornerRadius : CGFloat = layoutHorizontal(iPhone6: 4)
fileprivate let FTDefaultMenuArrowWidth : CGFloat = layoutHorizontal(iPhone6: 8)
fileprivate let FTDefaultMenuArrowHeight : CGFloat = layoutVertical(iPhone6: 10)
fileprivate let FTDefaultAnimationDuration : TimeInterval = 0.2
fileprivate let FTDefaultBorderWidth : CGFloat = layoutHorizontal(iPhone6: 0.5)
fileprivate let FTDefaultCornerRadius : CGFloat = layoutHorizontal(iPhone6: 6)
fileprivate let FTDefaultMenuRowHeight : CGFloat = layoutVertical(iPhone6: 40)
fileprivate let FTDefaultMenuWidth : CGFloat = layoutHorizontal(iPhone6: 120)
fileprivate let FTDefaultTintColor : UIColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)

fileprivate let FTPopOverMenuTableViewCellIndentifier : String = "FTPopOverMenuTableViewCellIndentifier"

fileprivate enum FTPopOverMenuArrowDirection {
    case Up
    case Down
}

public class FTPopOverMenu : NSObject {

    var sender : UIView?
    var senderFrame : CGRect?
    var menuNameArray : [String]!
    var menuImageArray : [String]!
    var done : ((_ selectedIndex : NSInteger)->())!
    var cancel : (()->())!

    fileprivate static var sharedMenu : FTPopOverMenu {
        struct Static {
            static let instance : FTPopOverMenu = FTPopOverMenu()
        }
        return Static.instance
    }

    fileprivate lazy var configuration : FTConfiguration = {
        return FTConfiguration.shared
    }()
    
    fileprivate lazy var backgroundView : UIView = {
        let view = UIView(frame: SCREEN_BOUNDS)
        view.backgroundColor = UIColor.clear
        view.addGestureRecognizer(self.tapGesture)
        return view
    }()
    
    fileprivate lazy var popOverMenu : FTPopOverMenuView = {
        let menu = FTPopOverMenuView(frame: CGRect.zero)
        menu.alpha = 0
        self.backgroundView.addSubview(menu)
        return menu
    }()
    
    fileprivate var isOnScreen : Bool = false {
        didSet {
            if isOnScreen {
                self.addOrientationChangeNotification()
            }else{
                self.removeOrientationChangeNotification()
            }
        }
    }

    fileprivate lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onBackgroudViewTapped(gesture:)))
        gesture.delegate = self
        return gesture
    }()

    fileprivate func showForSender(sender: UIView?, or senderFrame: CGRect?, with menuNameArray: [String]!, menuImageArray: [String]?, done: @escaping (NSInteger)->(), cancel:@escaping ()->()){
        
        if sender == nil && senderFrame == nil {
            return
        }
        if menuNameArray.count == 0 {
            return
        }

        self.sender = sender
        self.senderFrame = senderFrame
        self.menuNameArray = menuNameArray
        self.menuImageArray = menuImageArray
        self.done = done
        self.cancel = cancel
        
        UIApplication.shared.keyWindow?.addSubview(self.backgroundView)
        
        self.adjustPostionForPopOverMenu()
    }

    fileprivate func adjustPostionForPopOverMenu() {
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.ft_width(), height: UIScreen.ft_height())

        self.setupPopOverMenu()
        
        self.showIfNeeded()
    }
    
    fileprivate func setupPopOverMenu() {
        popOverMenu.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        self.configurePopMenuFrame()
        
        popOverMenu.showWithAnglePoint(point: menuArrowPoint, frame: popMenuFrame, menuNameArray: menuNameArray, menuImageArray: menuImageArray, arrowDirection: arrowDirection, done: { (selectedIndex: NSInteger) in
            self.isOnScreen = false
            self.doneActionWithSelectedIndex(selectedIndex: selectedIndex)
        })
        
        popOverMenu.setAnchorPoint(anchorPoint: self.getAnchorPointForPopMenu())
    }
    
    fileprivate func getAnchorPointForPopMenu() -> CGPoint {
        var anchorPoint = CGPoint(x: menuArrowPoint.x/popMenuFrame.size.width, y: 0)
        if arrowDirection == .Down {
            anchorPoint = CGPoint(x: menuArrowPoint.x/popMenuFrame.size.width, y: 1)
        }
        return anchorPoint
    }
    
    fileprivate var senderRect : CGRect = CGRect.zero
    fileprivate var popMenuOriginX : CGFloat = 0
    fileprivate var popMenuFrame : CGRect = CGRect.zero
    fileprivate var menuArrowPoint : CGPoint = CGPoint.zero
    fileprivate var arrowDirection : FTPopOverMenuArrowDirection = .Up
    fileprivate var popMenuHeight : CGFloat {
        return configuration.menuRowHeight * CGFloat(self.menuNameArray.count) + FTDefaultMenuArrowHeight
    }
    
    fileprivate func configureSenderRect() {
        if self.sender != nil {
            if sender?.superview != nil {
                senderRect = (sender?.superview?.convert((sender?.frame)!, to: backgroundView))!
            }else{
                senderRect = (sender?.frame)!
            }
        }else if senderFrame != nil {
            senderRect = senderFrame!
        }
        senderRect.origin.y = min(UIScreen.ft_height(), senderRect.origin.y)
        
        if senderRect.origin.y + senderRect.size.height/2 < UIScreen.ft_height()/2 {
            arrowDirection = .Up
        }else{
            arrowDirection = .Down
        }
    }
    
    fileprivate func configurePopMenuOriginX() {
        var senderXCenter : CGPoint = CGPoint(x: senderRect.origin.x + (senderRect.size.width)/2, y: 0)
        let menuCenterX : CGFloat = configuration.menuWidth/2 + FTDefaultMargin
        var menuX : CGFloat = 0
        if (senderXCenter.x + menuCenterX > UIScreen.ft_width()) {
            senderXCenter.x = min(senderXCenter.x - (UIScreen.ft_width() - configuration.menuWidth - FTDefaultMargin), configuration.menuWidth - FTDefaultMenuArrowWidth - FTDefaultMargin)
            menuX = UIScreen.ft_width() - configuration.menuWidth - FTDefaultMargin
        }else if (senderXCenter.x - menuCenterX < 0){
            senderXCenter.x = max(FTDefaultMenuCornerRadius + FTDefaultMenuArrowWidth, senderXCenter.x - FTDefaultMargin)
            menuX = FTDefaultMargin
        }else{
            senderXCenter.x = configuration.menuWidth/2
            menuX = senderRect.origin.x + (senderRect.size.width)/2 - configuration.menuWidth/2
        }
        popMenuOriginX = menuX
    }
    
    fileprivate func configurePopMenuFrame() {
        self.configureSenderRect()
        self.configureMenuArrowPoint()
        self.configurePopMenuOriginX()
        
        if (arrowDirection == .Up) {
            popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y + senderRect.size.height), width: configuration.menuWidth, height: popMenuHeight)
            if (popMenuFrame.origin.y + popMenuFrame.size.height > UIScreen.ft_height()) {
                popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y + senderRect.size.height), width: configuration.menuWidth, height: UIScreen.ft_height() - popMenuFrame.origin.y - FTDefaultMargin)
            }
        }else{
            popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y - popMenuHeight), width: configuration.menuWidth, height: popMenuHeight)
            if (popMenuFrame.origin.y  < 0) {
                popMenuFrame = CGRect(x: popMenuOriginX, y: FTDefaultMargin, width: configuration.menuWidth, height: senderRect.origin.y - FTDefaultMargin)
            }
        }
    }

     fileprivate func configureMenuArrowPoint() {
        var point : CGPoint = CGPoint(x: senderRect.origin.x + (senderRect.size.width)/2, y: 0)
        let menuCenterX : CGFloat = configuration.menuWidth/2 + FTDefaultMargin
        if senderRect.origin.y + senderRect.size.height/2 < UIScreen.ft_height()/2 {
            point.y = 0
        }else{
            point.y = popMenuHeight
        }
        if (point.x + menuCenterX > UIScreen.ft_width()) {
            point.x = min(point.x - (UIScreen.ft_width() - configuration.menuWidth - FTDefaultMargin), configuration.menuWidth - FTDefaultMenuArrowWidth - FTDefaultMargin)
        }else if (point.x - menuCenterX < 0){
            point.x = max(FTDefaultMenuCornerRadius + FTDefaultMenuArrowWidth, point.x - FTDefaultMargin)
        }else{
            point.x = configuration.menuWidth/2
        }
        menuArrowPoint = point
    }

    @objc fileprivate func onBackgroudViewTapped(gesture : UIGestureRecognizer) {
        self.dismiss()
    }
    
    fileprivate func showIfNeeded() {
        if self.isOnScreen == false {
            self.isOnScreen = true
            popOverMenu.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: FTDefaultAnimationDuration, animations: { [weak self] in
                self?.popOverMenu.alpha = 1
                self?.popOverMenu.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    fileprivate func dismiss() {
        self.isOnScreen = false
        self.doneActionWithSelectedIndex(selectedIndex: -1)
    }
    
    fileprivate func doneActionWithSelectedIndex(selectedIndex: NSInteger) {
        UIView.animate(withDuration: FTDefaultAnimationDuration,
                       animations: { [weak self] in
                        self?.popOverMenu.alpha = 0
                        self?.popOverMenu.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { [weak self] (isFinished) in
            if isFinished {
                self?.backgroundView.removeFromSuperview()
                if selectedIndex < 0 {
                    if (self?.cancel != nil) {
                        self?.cancel()
                    }
                }else{
                    if (self?.done != nil) {
                        self?.done(selectedIndex)
                    }
                }
                
            }
        }
    }

}
extension UIControl {
    
    // solution found at: http://stackoverflow.com/a/5666430/6310268
    
    fileprivate func setAnchorPoint(anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position = self.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
    
}

extension FTPopOverMenu {
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self,selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
                                               object: nil)
        
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.adjustPostionForPopOverMenu()
        })
    }
    
}

extension FTPopOverMenu: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: backgroundView)
        let touchClass : String = NSStringFromClass((touch.view?.classForCoder)!) as String
        if touchClass == "UITableViewCellContentView" {
            return false
        }else if CGRect(x: 0, y: 0, width: configuration.menuWidth, height: configuration.menuRowHeight).contains(touchPoint){
            // when showed at the navgation-bar-button-item, there is a chance of not respond around the top arrow, so :
            self.doneActionWithSelectedIndex(selectedIndex: 0)
            return false
        }
        return true
    }

}

private class FTPopOverMenuView: UIControl {
    
    fileprivate var menuNameArray : [String]!
    fileprivate var menuImageArray : [String]?
    fileprivate var arrowDirection : FTPopOverMenuArrowDirection = .Up
    fileprivate var done : ((NSInteger)->())!
    
    fileprivate lazy var configuration : FTConfiguration = {
        return FTConfiguration.shared
    }()
    
    lazy var menuTableView : UITableView = {
       let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = FTConfiguration.shared.menuSeparatorColor
        tableView.layer.cornerRadius = FTConfiguration.shared.cornerRadius
        tableView.clipsToBounds = true
        return tableView
    }()
    
    fileprivate func showWithAnglePoint(point: CGPoint, frame: CGRect, menuNameArray: [String]!, menuImageArray: [String]!, arrowDirection: FTPopOverMenuArrowDirection, done: @escaping ((NSInteger)->())) {
        
        self.frame = frame
        


        self.menuNameArray = menuNameArray
        self.menuImageArray = menuImageArray
        self.arrowDirection = arrowDirection
        self.done = done
        
        self.repositionMenuTableView()
        
        self.drawBackgroundLayerWithArrowPoint(arrowPoint: point)
    }
    
    fileprivate func repositionMenuTableView() {
        var menuRect : CGRect = CGRect(x: 0, y: FTDefaultMenuArrowHeight, width: self.frame.size.width, height: self.frame.size.height - FTDefaultMenuArrowHeight)
        if (arrowDirection == .Down) {
            menuRect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - FTDefaultMenuArrowHeight)
        }
        self.menuTableView.frame = menuRect
        self.menuTableView.reloadData()
        if menuTableView.frame.height < configuration.menuRowHeight * CGFloat(menuNameArray.count) {
            self.menuTableView.isScrollEnabled = true
        }else{
            self.menuTableView.isScrollEnabled = false
        }
        self.addSubview(self.menuTableView)
    }

    fileprivate lazy var backgroundLayer : CAShapeLayer = {
        let layer : CAShapeLayer = CAShapeLayer()
        return layer
    }()
    
    
    fileprivate func drawBackgroundLayerWithArrowPoint(arrowPoint : CGPoint) {
        if self.backgroundLayer.superlayer != nil {
            self.backgroundLayer.removeFromSuperlayer()
        }
    
        backgroundLayer.path = self.getBackgroundPath(arrowPoint: arrowPoint).cgPath
        backgroundLayer.fillColor = configuration.backgoundTintColor.cgColor
        backgroundLayer.strokeColor = configuration.borderColor.cgColor
        backgroundLayer.lineWidth = configuration.borderWidth
        self.layer.insertSublayer(backgroundLayer, at: 0)
        //        backgroundLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI))) //CATransform3DMakeRotation(CGFloat(M_PI), 1, 1, 0)
    }
    
    func getBackgroundPath(arrowPoint : CGPoint) -> UIBezierPath {
        let radius : CGFloat = configuration.cornerRadius/2
        
        let path : UIBezierPath = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        if (arrowDirection == .Up){
            path.move(to: CGPoint(x: arrowPoint.x - FTDefaultMenuArrowWidth, y: FTDefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
            path.addLine(to: CGPoint(x: arrowPoint.x + FTDefaultMenuArrowWidth, y: FTDefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: self.bounds.size.width - radius, y: FTDefaultMenuArrowHeight))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: FTDefaultMenuArrowHeight + radius),
                        radius: radius,
                        startAngle: CGFloat(M_PI_2*3),
                        endAngle: 0,
                        clockwise: true)
            path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - radius))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: self.bounds.size.height - radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: CGFloat(M_PI_2),
                        clockwise: true)
            path.addLine(to: CGPoint(x: radius, y: self.bounds.size.height))
            path.addArc(withCenter: CGPoint(x: radius, y: self.bounds.size.height - radius),
                        radius: radius,
                        startAngle: CGFloat(M_PI_2),
                        endAngle: CGFloat(M_PI),
                        clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: FTDefaultMenuArrowHeight + radius))
            path.addArc(withCenter: CGPoint(x: radius, y: FTDefaultMenuArrowHeight + radius),
                        radius: radius,
                        startAngle: CGFloat(M_PI),
                        endAngle: CGFloat(M_PI_2*3),
                        clockwise: true)
            path.close()
            //            path = UIBezierPath(roundedRect: CGRect.init(x: 0, y: FTDefaultMenuArrowHeight, width: self.bounds.size.width, height: self.bounds.height - FTDefaultMenuArrowHeight), cornerRadius: configuration.cornerRadius)
            //            path.move(to: CGPoint(x: arrowPoint.x - FTDefaultMenuArrowWidth, y: FTDefaultMenuArrowHeight))
            //            path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
            //            path.addLine(to: CGPoint(x: arrowPoint.x + FTDefaultMenuArrowWidth, y: FTDefaultMenuArrowHeight))
            //            path.close()
        }else{
            path.move(to: CGPoint(x: arrowPoint.x - FTDefaultMenuArrowWidth, y: self.bounds.size.height - FTDefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: self.bounds.size.height))
            path.addLine(to: CGPoint(x: arrowPoint.x + FTDefaultMenuArrowWidth, y: self.bounds.size.height - FTDefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: self.bounds.size.width - radius, y: self.bounds.size.height - FTDefaultMenuArrowHeight))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: self.bounds.size.height - FTDefaultMenuArrowHeight - radius),
                        radius: radius,
                        startAngle: CGFloat(M_PI_2),
                        endAngle: 0,
                        clockwise: false)
            path.addLine(to: CGPoint(x: self.bounds.size.width, y: radius))
            path.addArc(withCenter: CGPoint(x: self.bounds.size.width - radius, y: radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: CGFloat(M_PI_2*3),
                        clockwise: false)
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(withCenter: CGPoint(x: radius, y: radius),
                        radius: radius,
                        startAngle: CGFloat(M_PI_2*3),
                        endAngle: CGFloat(M_PI),
                        clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: self.bounds.size.height - FTDefaultMenuArrowHeight - radius))
            path.addArc(withCenter: CGPoint(x: radius, y: self.bounds.size.height - FTDefaultMenuArrowHeight - radius),
                        radius: radius,
                        startAngle: CGFloat(M_PI),
                        endAngle: CGFloat(M_PI_2),
                        clockwise: false)
            path.close()
            //            path = UIBezierPath(roundedRect: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.height - FTDefaultMenuArrowHeight), cornerRadius: configuration.cornerRadius)
            //            path.move(to: CGPoint(x: arrowPoint.x - FTDefaultMenuArrowWidth, y: self.bounds.size.height - FTDefaultMenuArrowHeight))
            //            path.addLine(to: CGPoint(x: arrowPoint.x, y: self.bounds.size.height))
            //            path.addLine(to: CGPoint(x: arrowPoint.x + FTDefaultMenuArrowWidth, y: self.bounds.size.height - FTDefaultMenuArrowHeight))
            //            path.close()
        }
        return path
    }
    
    
    
}

extension FTPopOverMenuView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configuration.menuRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (self.done != nil) {
            self.done(indexPath.row)
        }
    }
    
}

extension FTPopOverMenuView : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FTPopOverMenuCell = FTPopOverMenuCell(style: .default, reuseIdentifier: FTPopOverMenuTableViewCellIndentifier)
        var imageName = ""
        if menuImageArray != nil {
            if (menuImageArray?.count)! >= indexPath.row + 1 {
                imageName = (menuImageArray?[indexPath.row])!
            }
        }
        cell.setupCellWith(menuName: menuNameArray[indexPath.row], menuImage: imageName)
        if (indexPath.row == menuNameArray.count-1) {
            cell.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0)
        }else{
            cell.separatorInset = configuration.menuSeparatorInset
        }
        return cell
    }

}

class FTPopOverMenuCell: UITableViewCell {
    
    fileprivate lazy var configuration : FTConfiguration = {
        return FTConfiguration.shared
    }()

    fileprivate lazy var iconImageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    fileprivate lazy var nameLabel : UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.backgroundColor = UIColor.clear
        self.contentView.addSubview(label)
        return label
    }()
    
    fileprivate func setupCellWith(menuName: String, menuImage: String?) {
        self.backgroundColor = UIColor.clear
        if menuImage != nil {
            if var iconImage : UIImage = UIImage(named: menuImage!) {
                if  configuration.ignoreImageOriginalColor {
                    iconImage = iconImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                }
                iconImageView.tintColor = configuration.textColor
                iconImageView.frame =  CGRect(x: FTDefaultCellMargin, y: (configuration.menuRowHeight - FTDefaultMenuIconSize)/2, width: FTDefaultMenuIconSize, height: FTDefaultMenuIconSize)
                iconImageView.image = iconImage
                nameLabel.frame = CGRect(x: FTDefaultCellMargin*2 + FTDefaultMenuIconSize, y: (configuration.menuRowHeight - FTDefaultMenuIconSize)/2, width: (configuration.menuWidth - FTDefaultMenuIconSize - FTDefaultCellMargin*3), height: FTDefaultMenuIconSize)
            }else{
                nameLabel.frame = CGRect(x: FTDefaultCellMargin, y: 0, width: configuration.menuWidth - FTDefaultCellMargin*2, height: configuration.menuRowHeight)
            }
        }
        nameLabel.font = configuration.textFont
        nameLabel.textColor = configuration.textColor
        nameLabel.textAlignment = configuration.textAlignment
        nameLabel.text = menuName
    }

    /**
     修改cell点击后高亮颜色
     */
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            contentView.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 0.9)
        } else {
            contentView.backgroundColor = FTDefaultTintColor
        }
    }
    
}

extension UIScreen {
    
    public static func ft_width() -> CGFloat {
        return self.main.bounds.size.width
    }
    public static func ft_height() -> CGFloat {
        return self.main.bounds.size.height
    }
    
}
