//
//  JFDiyViewController.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/7.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

fileprivate let PasterGroupItemId = "PasterGroupItemId"
fileprivate let PasterItemId = "PasterItemId"

/// 贴纸各种UI的背景颜色
fileprivate let PasterBgColor = UIColor.colorWithHexString("#333333", alpha: 0.7)

fileprivate let PasterItemWidth: CGFloat = layoutHorizontal(iPhone6: 80)

class JFDiyViewController: UIViewController {
    
    /// 图片集合
    var photoImageList: [UIImage]?
    
    /// 备份原图的集合
    fileprivate var originImageList = [UIImage]()
    
    /// 贴纸编辑视图
    fileprivate var stageView: JFPasterStageView?
    
    /// 贴纸组模型集合
    fileprivate lazy var pasterGroupList = JFPasterGroup.getPasterGroupList()
    
    /// 当前选择的贴纸组下标 - 默认是第一组
    fileprivate var currentPasterGroupIndex = 0
    
    /// 是否显示了贴纸UI
    fileprivate var isShowPasterWidget = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        prepareData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    /**
     scrollView触摸事件
     */
    @objc fileprivate func didTappedScrollView(_ gestureRecognizer: UITapGestureRecognizer) {
        if contextSheet.isShow {
            contextSheet.dismiss()
        } else {
            contextSheet.startWithGestureRecognizer(gestureRecognizer, inView: view)
        }
    }
    
    // MARK: - 懒加载
    /// 预览滚动视图
    fileprivate lazy var containerView: UIScrollView = {
        let scrollView = UIScrollView(frame: SCREEN_BOUNDS)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    /// 页码
    fileprivate lazy var pageLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: 44))
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        return label
    }()
    
    /// 触摸屏幕后弹出视图
    fileprivate lazy var contextSheet: JFContextSheet = {
        let contextItem1 = JFContextItem(itemName: "返回", itemIcon: "diy_item_fanhuijiantou")
        let contextItem2 = JFContextItem(itemName: "原图", itemIcon: "diy_item_tupian")
        let contextItem3 = JFContextItem(itemName: "贴纸", itemIcon: "diy_item_katie")
        let contextItem4 = JFContextItem(itemName: "打码", itemIcon: "diy_item_smear")
        let contextItem5 = JFContextItem(itemName: "保存", itemIcon: "diy_item_save")
        
        let contextSheet = JFContextSheet(items: [contextItem1, contextItem2, contextItem3, contextItem4, contextItem5])
        contextSheet.delegate = self
        return contextSheet
    }()
    
    /// 贴纸组底部集合视图
    fileprivate lazy var pasterGroupBottomView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: PasterItemWidth, height: PasterItemWidth)
        layout.minimumInteritemSpacing = layoutHorizontal(iPhone6: 8)
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = PasterBgColor
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(JFPasterGroupCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PasterGroupItemId)
        return collectionView
    }()
    
    /// 贴纸底部集合视图
    fileprivate lazy var pasterBottomView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: PasterItemWidth, height: PasterItemWidth)
        layout.minimumInteritemSpacing = layoutHorizontal(iPhone6: 8)
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = PasterBgColor
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(JFPasterCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PasterItemId)
        return collectionView
    }()
    
    /// 贴纸顶部视图
    fileprivate lazy var pasterTopView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = PasterBgColor
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 14))
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addTarget(self, action: #selector(didTappedPasterTopView(cancelButton:)), for: .touchUpInside)
        
        let confirmButton = UIButton(type: .custom)
        confirmButton.setTitleColor(UIColor.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 14))
        confirmButton.setTitle("应用", for: .normal)
        confirmButton.addTarget(self, action: #selector(didTappedPasterTopView(confirmButton:)), for: .touchUpInside)
        
        view.addSubview(cancelButton)
        view.addSubview(confirmButton)
        
        cancelButton.snp.makeConstraints({ (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(0)
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 54), height: layoutVertical(iPhone6: 44)))
        })
        
        confirmButton.snp.makeConstraints({ (make) in
            make.centerY.equalTo(view)
            make.right.equalTo(0)
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 54), height: layoutVertical(iPhone6: 44)))
        })
        return view
    }()
    
}

// MARK: - 设置界面
extension JFDiyViewController {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        view.backgroundColor = BACKGROUND_COLOR
        view.addSubview(containerView)
        view.addSubview(pageLabel)
        
        view.addSubview(pasterTopView)
        view.addSubview(pasterBottomView)
        view.addSubview(pasterGroupBottomView)
        
        pasterTopView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(layoutVertical(iPhone6: -44))
            make.height.equalTo(layoutVertical(iPhone6: 44))
        }
        
        pasterBottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(PasterItemWidth)
            make.height.equalTo(PasterItemWidth)
        }
        
        pasterGroupBottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(PasterItemWidth)
            make.height.equalTo(PasterItemWidth)
        }
        
        // 轻敲手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedScrollView(_:)))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    /// 准备数据
    fileprivate func prepareData() {
        
        guard let photoImageList = photoImageList else { return }
        
        // 初始化备份数组
        originImageList.removeAll()
        for photoImage in photoImageList {
            if let image = photoImage.copy() as? UIImage {
                originImageList.append(image)
            }
        }
        
        // 默认页码
        pageLabel.text = "1 / \(photoImageList.count)"
        
        // 滚动范围
        containerView.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(photoImageList.count), height: 0)
        
        // 添加图片
        for (index, image) in photoImageList.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.tag = index + 1000
            imageView.frame = CGRect(x: CGFloat(index) * SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            containerView.addSubview(imageView)
        }
        
    }
    
}

// MARK: - 贴纸视图操作
extension JFDiyViewController: UICollectionViewDelegate, UICollectionViewDataSource, JFPasterStageViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pasterGroupBottomView {
            return pasterGroupList.count
        } else {
            return pasterGroupList[currentPasterGroupIndex].pasterList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pasterGroupBottomView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PasterGroupItemId, for: indexPath) as! JFPasterGroupCollectionViewCell
            cell.pasterGroup = pasterGroupList[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PasterItemId, for: indexPath) as! JFPasterCollectionViewCell
            cell.paster = pasterGroupList[currentPasterGroupIndex].pasterList[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == pasterGroupBottomView {
            currentPasterGroupIndex = indexPath.item
            // 刷新贴纸集合视图
            UIView.transition(with: self.pasterBottomView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.pasterBottomView.reloadData()
            }, completion: { (_) in
                self.pasterBottomView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            })
        } else {
            // 添加贴纸图片
            let image = UIImage(contentsOfFile: Bundle.main.path(forResource: pasterGroupList[currentPasterGroupIndex].pasterList[indexPath.item].iconName , ofType: nil) ?? "")
            stageView?.addPasterWithImg(imgPater: image!)
        }
    }
    
    /// 弹出贴纸操作UI
    fileprivate func showPasterWidget() {
        
        isShowPasterWidget = true
        
        // 显示顶部视图
        pasterTopView.isHidden = false
        
        // 从顶部弹出贴纸顶部视图
        pasterTopView.snp.updateConstraints { (make) in
            make.top.equalTo(0)
        }
        
        // 从底部弹出贴纸组集合视图
        pasterGroupBottomView.snp.updateConstraints { (make) in
            make.bottom.equalTo(-PasterItemWidth)
        }
        
        // 从底部弹出贴纸集合视图
        pasterBottomView.snp.updateConstraints { (make) in
            make.bottom.equalTo(0)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 隐藏贴纸操作UI
    fileprivate func hidePasterWidget() {
        
        isShowPasterWidget = false
        
        // 隐藏贴纸顶部视图
        // 从顶部弹出贴纸顶部视图
        pasterTopView.snp.updateConstraints { (make) in
            make.top.equalTo(layoutVertical(iPhone6: -44))
        }
        
        // 隐藏贴纸组集合视图
        pasterGroupBottomView.snp.updateConstraints { (make) in
            make.bottom.equalTo(PasterItemWidth)
        }
        
        // 隐藏贴纸集合视图
        pasterBottomView.snp.updateConstraints { (make) in
            make.bottom.equalTo(PasterItemWidth)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            // 隐藏顶部视图
            self.pasterTopView.isHidden = true
        }
    }
    
    /// 点击了贴纸顶部取消按钮
    ///
    /// - Parameter cancelButton: 取消按钮
    @objc fileprivate func didTappedPasterTopView(cancelButton: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.stageView?.alpha = 0
        }) { (_) in
            self.stageView?.removeFromSuperview()
            self.stageView = nil
        }
        hidePasterWidget()
    }
    
    /// 点击了贴纸顶部应用按钮
    ///
    /// - Parameter confirmButton: 应用按钮
    @objc fileprivate func didTappedPasterTopView(confirmButton: UIButton) {
        
        let index = Int(containerView.contentOffset.x / SCREEN_WIDTH)
        guard let image = stageView?.doneEdit(), let imageView = containerView.viewWithTag(index + 1000) as? UIImageView else { return }
        photoImageList?[index] = image
        imageView.image = image
        
        UIView.animate(withDuration: 0.25, animations: {
            self.stageView?.alpha = 0
        }) { (_) in
            self.stageView?.removeFromSuperview()
            self.stageView = nil
        }
        hidePasterWidget()
        
    }
    
    /**
     点击了背景视图 - XTPasterStageViewDelegate
     */
    public func didTappedBgView() {
        if isShowPasterWidget {
            hidePasterWidget()
        } else {
            showPasterWidget()
        }
    }
    
}

// MARK: - 监听滚动
extension JFDiyViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageLabel.text = "\(Int(scrollView.contentOffset.x / SCREEN_WIDTH) + 1) / \(photoImageList?.count ?? 0)"
    }
    
}

// MARK: - 选项操作
extension JFDiyViewController: JFContextSheetDelegate {
    
    // MARK: - JFContextSheetDelegate
    func contextSheet(_ contextSheet: JFContextSheet, didSelectItemWithItemName itemName: String) {
        switch (itemName) {
        case "返回":
            exitDiy()
        case "原图":
            originImage()
        case "贴纸":
            paster()
        case "打码":
            gaussianblur()
        case "保存":
            save()
        default:
            break
        }
    }
    
    /// 退出DIY
    fileprivate func exitDiy() {
        let alertC = UIAlertController(title: "确定要退出吗？", message: "退出后所有DIY的操作都会清空哦！O(∩_∩)O~", preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertC.addAction(UIAlertAction(title: "退出", style: .destructive, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertC, animated: true, completion: nil)
    }
    
    /// 恢复原图
    fileprivate func originImage() {
        
        let index = Int(containerView.contentOffset.x / SCREEN_WIDTH)
        guard let imageView = containerView.viewWithTag(index + 1000) as? UIImageView else { return }
        photoImageList?[index] = originImageList[index]
        imageView.image = originImageList[index]
    }
    
    /// 贴纸
    fileprivate func paster() {
        stageView = JFPasterStageView(frame: SCREEN_BOUNDS)
        stageView?.delegate = self
        stageView?.originImage = photoImageList?[Int(containerView.contentOffset.x / SCREEN_WIDTH)]
        view.insertSubview(stageView!, belowSubview: pasterTopView)
        
        // 弹出贴纸操作UI
        showPasterWidget()
    }
    
    /// 模糊处理
    fileprivate func gaussianblur() {
        if let image = photoImageList?[Int(containerView.contentOffset.x / SCREEN_WIDTH)] {
            print(image)
            let smearVc = CTImageSmearViewController(image: image)
            smearVc.delegate = self
            smearVc.transitioningDelegate = self
            smearVc.modalPresentationStyle = UIModalPresentationStyle.custom
            present(smearVc, animated: true, completion: nil)
        }
    }
    
    /// 保存
    fileprivate func save() {
        
        // 判断有没有分享过，如果没有则要求分享一次 - 如有需要分享则返回true
        if JFAdManager.shared.showShareAlert(vc: self) {
            return
        }
        
        // 弹出插页广告
        if let interstitial = JFAdManager.shared.getReadyIntersitial() {
            interstitial.present(fromRootViewController: self)
            return
        }
        
        let alertC = UIAlertController(title: "保存图片到相册", message: nil, preferredStyle: .actionSheet)
        alertC.addAction(UIAlertAction(title: "当前图片", style: .default, handler: { [weak self] (_) in
            self?.saveOnImage()
        }))
        alertC.addAction(UIAlertAction(title: "全部图片", style: .default, handler: { [weak self] (_) in
            self?.saveMoreImage()
        }))
        alertC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertC, animated: true, completion: nil)
    }
    
    /// 保存单图
    fileprivate func saveOnImage() {
        let index = Int(containerView.contentOffset.x / SCREEN_WIDTH)
        guard let photoImage = photoImageList?[index] else { return }
        // 重绘后的图片尺寸需要和原图一样大
        UIImageWriteToSavedPhotosAlbum(photoImage.redrawImage(size: originImageList.first?.size ?? SCREEN_BOUNDS.size)!, self, #selector(imageSavedToPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    /// 保存多图
    fileprivate func saveMoreImage() {
        for photoImage in photoImageList ?? [UIImage]() {
            // 重绘后的图片尺寸需要和原图一样大
            UIImageWriteToSavedPhotosAlbum(photoImage.redrawImage(size: originImageList.first?.size ?? SCREEN_BOUNDS.size)!, self, #selector(imageSavedToPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    /// 图片保存回调
    @objc fileprivate func imageSavedToPhotosAlbum(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: Any?) {
        if error == nil {
            JFProgressHUD.showSuccessWithStatus("保存成功")
        } else {
            JFProgressHUD.showErrorWithStatus("保存失败 \(error.debugDescription)")
        }
    }
    
}

// MARK: - CTImageSmearViewControllerDelegate
extension JFDiyViewController: CTImageSmearViewControllerDelegate {
    
    /// 已经涂抹过了图片
    ///
    /// - Parameter image: 被涂抹的图片
    func didSmearPhoto(withResultImage image: UIImage) {
        print(image)
        let index = Int(containerView.contentOffset.x / SCREEN_WIDTH)
        guard let imageView = containerView.viewWithTag(index + 1000) as? UIImageView else { return }
        photoImageList?[index] = image
        imageView.image = image
        
    }
    
}

// MARK: - 相册列表转场动画
extension JFDiyViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return JFSmearPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFSmearPopoverModalAnimation()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFSmearPopoverDismissAnimation()
    }
}
