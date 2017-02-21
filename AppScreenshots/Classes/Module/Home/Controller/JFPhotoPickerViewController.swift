//
//  JFPhotoPickerViewController.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/7.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import Photos
import pop

fileprivate let JFPhotoPickerViewItemId = "JFPhotoPickerViewItemId"
fileprivate let JFPhotoPickerViewItemCols = 4               // 一行4列
fileprivate let JFPhotoPickerViewItemMargin: CGFloat = layoutVertical(iPhone6: 1.5)  // item间隔
let JFPhotoPickerViewItemWidth = (SCREEN_WIDTH - JFPhotoPickerViewItemMargin * CGFloat(JFPhotoPickerViewItemCols - 1) * 2) / CGFloat(JFPhotoPickerViewItemCols)

protocol JFPhotoPickerViewControllerDelegate: NSObjectProtocol {
    
    /// 回调选中的图片集合
    ///
    /// - Parameter imageList: 图片集合
    func didSelected(imageList: [UIImage])
}

class JFPhotoPickerViewController: UIViewController {

    /// 相册模型集合
    fileprivate var albumItemList = [JFAlbumItem]() {
        didSet {
            // 默认加载第一个相册
            if albumItemList.count > 0 {
                albumItemList.first?.isSelected = true
                currentAlbumItem = albumItemList.first
            }
        }
    }
    
    /// 当前加载的相册模型
    fileprivate var currentAlbumItem: JFAlbumItem? {
        didSet {
            if let currentAlbumItem = currentAlbumItem {
                currentAssetItemList.removeAll()
                selectedCount = 0
                currentAlbumItem.fetchResult.enumerateObjects({ [weak self] (asset, index, _) in
                    let assetItem = JFAssetItem(asset: asset)
                    self?.currentAssetItemList.append(assetItem)
                })
                
                // 更新标题
                updateTitle()
                
                // 刷新集合视图
                DispatchQueue.main.async {
                    UIView.transition(with: self.containerView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                        self.containerView.reloadData()
                    }, completion: { (_) in
                        
                    })
                }
            }
        }
    }
    
    /// 当前加载的相册内图片资源模型集合
    fileprivate var currentAssetItemList = [JFAssetItem]()
    
    /// 当前选中图片的数量
    fileprivate var selectedCount = 0
    
    weak var delegate: JFPhotoPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        
        // 获取相册数据
        getAlbumItemList()
        
        // 注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(albumListViewDismiss), name: NSNotification.Name(rawValue: AlbumListViewControllerWillDismiss), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 监听相册列表隐藏
    @objc fileprivate func albumListViewDismiss() {
        UIView.animate(withDuration: 0.25) { 
            self.titleButton.imageView?.transform = CGAffineTransform.identity
        }
    }
    
    /// 点击了标题
    ///
    /// - Parameter titleButton: 标题按钮
    @objc fileprivate func didTapped(titleButton: UIButton) {
        // 标题下的控制器
        let albumListVc = JFAlbumListViewController()
        albumListVc.albumItemList = albumItemList
        albumListVc.delegate = self
        albumListVc.transitioningDelegate = self
        albumListVc.modalPresentationStyle = UIModalPresentationStyle.custom
        present(albumListVc, animated: true, completion: nil)
        
        UIView.animate(withDuration: 0.25) {
            self.titleButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        }
    }

    /// 点击了取消
    ///
    /// - Parameter cancelButton: 取消按钮
    @objc fileprivate func didTapped(cancelButton: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// 点击了确定
    ///
    /// - Parameter confirmButton: 确认按钮
    @objc fileprivate func didTapped(confirmButton: UIButton) {
        
        let group = DispatchGroup()
        var assetItemList = [UIImage]()
        for assetItem in currentAssetItemList {
            if assetItem.isSelected {
                group.enter()
                PHCachingImageManager.default().requestImage(
                    for: assetItem.asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFill,
                    options: nil) { (image, info) in
                        if let image = image {
                            assetItemList.append(image)
                        }
                        group.leave()
                }
            }
        }
        
        // 因为这里是异步，所以得用调度组来控制数据加载完毕
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.dismiss(animated: true, completion: { 
                self?.delegate?.didSelected(imageList: assetItemList)
            })
        }
        
    }
    
    /// 更新标题显示
    fileprivate func updateTitle() {
        titleButton.setTitle("(\(selectedCount)/5) \(currentAlbumItem?.title ?? "")", for: .normal)
        let size = ("(\(selectedCount)/5) \(currentAlbumItem?.title ?? "")" as NSString).boundingRect(with: CGSize.zero, options: [], attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: layoutFont(iPhone6: 17))], context: nil).size
        titleButton.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: (SCREEN_WIDTH - layoutHorizontal(iPhone6: 150) - size.width) * 0.5 + size.width,
            bottom: 0,
            right: 0)
        titleButton.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: layoutHorizontal(iPhone6: 20))
    }
    
    // MARK: - 懒加载UI
    /// 导航视图
    fileprivate lazy var navigationView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "photo_picker_nav"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    /// 取消
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 14))
        button.addTarget(self, action: #selector(didTapped(cancelButton:)), for: .touchUpInside)
        return button
    }()
    
    /// 确定
    fileprivate lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.isEnabled = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.gray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 14))
        button.addTarget(self, action: #selector(didTapped(confirmButton:)), for: .touchUpInside)
        return button
    }()
    
    /// 标题
    fileprivate lazy var titleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentHorizontalAlignment = .center
        button.setImage(UIImage(named: "photo_picker_title_arrow"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 17))
        button.addTarget(self, action: #selector(didTapped(titleButton:)), for: .touchUpInside)
        return button
    }()
    
    /// 列表容器视图
    fileprivate lazy var containerView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: JFPhotoPickerViewItemWidth, height: JFPhotoPickerViewItemWidth)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = JFPhotoPickerViewItemMargin * 2
        layout.footerReferenceSize = CGSize(width: SCREEN_WIDTH, height: layoutVertical(iPhone6: 44))
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = BACKGROUND_COLOR
        collectionView.register(JFAlbumImageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: JFPhotoPickerViewItemId)
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView")
        return collectionView
    }()

}

// MARK: - 设置界面
extension JFPhotoPickerViewController {
    
    /// 准备UI
    fileprivate func prepareUI() {
        view.backgroundColor = BACKGROUND_COLOR
        
        view.addSubview(navigationView)
        navigationView.addSubview(cancelButton)
        navigationView.addSubview(confirmButton)
        navigationView.addSubview(titleButton)
        view.addSubview(containerView)
        
        navigationView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(layoutVertical(iPhone6: 44) + 20)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(layoutHorizontal(iPhone6: 5))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 44), height: layoutVertical(iPhone6: 44)))
        }
        
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.right.equalTo(layoutHorizontal(iPhone6: -5))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 44), height: layoutVertical(iPhone6: 44)))
        }
        
        titleButton.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.centerX.equalTo(navigationView)
            make.height.equalTo(layoutVertical(iPhone6: 44))
            make.width.equalTo(SCREEN_WIDTH - layoutHorizontal(iPhone6: 150))
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(navigationView.snp.bottom)
        }
        
    }
    
}

// MARK: - 处理相册集合
extension JFPhotoPickerViewController {
    
    /// 获取相册集合
    fileprivate func getAlbumItemList() {
        
        // 获取相册访问权限
        if #available(iOS 9.0, *) {
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                // 子线程回调，所以需要回主线程
                PHPhotoLibrary.requestAuthorization({ [weak self] (status) in
                    DispatchQueue.main.async {
                        self?.requestAuthorizationHandler(status: status)
                    }
                })
            } else {
                requestAuthorizationHandler(status: .authorized)
            }
        }
        
    }
    
    /// 处理授权结果
    ///
    /// - Parameter status: 授权状态
    fileprivate func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            albumItemList = JFAlbumItem.getAlbumItemList()
        case .denied:
            showAuthorizationDeniedTip()
        case .notDetermined:
            print("notDetermined")
            break
        case .restricted:
            print("restricted")
            break
        }
    }
    
    /// 显示授权拒绝提示信息并引导用户去设置
    fileprivate func showAuthorizationDeniedTip() {
        
        let alertC = UIAlertController(title: "授权被用户拒绝", message: "无法加载您的相册，如果您想使用这个功能，请在【设置】-【ScreenShot】，允许访问照片", preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "取消", style: .cancel, handler:  { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        alertC.addAction(UIAlertAction(title: "设置", style: .destructive, handler: { (_) in
            // 打开设置界面
            if let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) {
                self.dismiss(animated: false, completion: nil)
                UIApplication.shared.openURL(url)
            }
            
        }))
        present(alertC, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension JFPhotoPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentAssetItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JFPhotoPickerViewItemId, for: indexPath) as! JFAlbumImageCollectionViewCell
        cell.assetItem = currentAssetItemList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView", for: indexPath)
        if footView.subviews.count == 0 {
            let countLabel = UILabel()
            countLabel.textColor = UIColor.gray
            countLabel.textAlignment = .center
            countLabel.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: layoutVertical(iPhone6: 44))
            footView.addSubview(countLabel)
        }
        (footView.subviews[0] as! UILabel).text = "\(currentAssetItemList.count)张图片"
        return footView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetItem = currentAssetItemList[indexPath.item]
        
        // 选中才有弹簧动画，取消则没有 并且计算当前选中图片数量
        if assetItem.isSelected {
            assetItem.isSelected = false
            selectedCount -= 1
            collectionView.reloadItems(at: [indexPath])
        } else if selectedCount < 5 {
            assetItem.isSelected = true
            selectedCount += 1
            collectionView.reloadItems(at: [indexPath])
            if let cell = collectionView.cellForItem(at: indexPath) as? JFAlbumImageCollectionViewCell {
                startViewSpringAnimation(cell.selectedButton)
            }
        } else {
            JFProgressHUD.showInfoWithStatus("建议应用截图最多5张")
        }
        
        // 每次选择图片后都判断是否需要激活确认按钮
        var isEnabled = false
        for assetItem in currentAssetItemList {
            if assetItem.isSelected {
                isEnabled = true
            }
        }
        confirmButton.isEnabled = isEnabled
        
        // 更新数量显示
        updateTitle()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! JFAlbumImageCollectionViewCell
        UIView.animate(withDuration: 0.25) { 
            cell.shadowView.alpha = 1.0
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! JFAlbumImageCollectionViewCell
        UIView.animate(withDuration: 0.25) {
            cell.shadowView.alpha = 0.0
        }
    }
    
    /// 给控件添加弹簧动画
    ///
    /// - Parameter view: 需要加动画的视图
    func startViewSpringAnimation(_ view: UIView) {
        let sprintAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        sprintAnimation?.velocity = NSValue(cgPoint: CGPoint(x: 8, y: 8)) // 速率
        sprintAnimation?.dynamicsTension = 10  // 拉力
        sprintAnimation?.dynamicsFriction = 10 // 摩擦力
        sprintAnimation?.springBounciness = 20
        print(view.description)
        view.pop_add(sprintAnimation, forKey: "springAnimation")
    }
    
}

// MARK: - 相册列表转场动画
extension JFPhotoPickerViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return JFPhotoPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPhotoPopoverModalAnimation()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPhotoPopoverDismissAnimation()
    }
}

// MARK: - 切换相册
extension JFPhotoPickerViewController: JFAlbumListViewControllerDelegate {
    
    /// 切换了相册，重新刷新视图
    func didChangedAlbum() {
        
        // 切换相册后切换确定
        confirmButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { [weak self] in
            for albumItem in self?.albumItemList ?? [JFAlbumItem]() {
                if albumItem.isSelected {
                    self?.currentAlbumItem = albumItem
                }
            }
        }
    }
    
}
