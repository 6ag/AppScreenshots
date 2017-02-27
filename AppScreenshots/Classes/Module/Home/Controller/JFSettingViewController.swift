//
//  JFSettingViewController.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/4.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import pop

fileprivate let PhotoItemId = "PhotoItemId"
fileprivate let TemplateItemId = "TemplateItemId"

class JFSettingViewController: UIViewController {
    
    /// 素材模型参数数组 - 原模板
    var materialParameterList: [JFMaterialParameter]?
    
    /// 素材模型参数数组 - 做的截图
    fileprivate var photoMaterialParameterList = [JFMaterialParameter]()
    
    fileprivate var contentOffsetY: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingViewControllerWillPresent(notification:)), name: NSNotification.Name(SettingViewControllerWillPresent), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingViewControllerWillDismiss(notification:)), name: NSNotification.Name(SettingViewControllerWillDismiss), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 设置界面即将显示
    ///
    /// - Parameter notification: 通知
    @objc fileprivate func settingViewControllerWillPresent(notification: Notification) {
        log("设置界面即将显示")
    }
    
    /// 设置界面即将隐藏
    ///
    /// - Parameter notification: 通知
    @objc fileprivate func settingViewControllerWillDismiss(notification: Notification) {
        log("设置界面即将隐藏")
    }
    
    /// 点击了加号 - 弹出各种功能选项
    ///
    /// - Parameter saveButton: 加号按钮
    @objc fileprivate func didTapped(moreButton: UIButton) {
        
        view.endEditing(true)
        
        let configuration = FTConfiguration.shared
        configuration.menuRowHeight = layoutVertical(iPhone6: 45)
        configuration.menuWidth = layoutHorizontal(iPhone6: 135)
        configuration.textColor = UIColor.colorWithHexString("c4c4c4")
        configuration.textFont = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        configuration.textAlignment = .center
        configuration.menuSeparatorColor = UIColor(white: 1, alpha: 0.05)
        configuration.menuSeparatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        FTPopOverMenu.showForSender(
            sender: moreButton,
            with: ["添加图片", "移除当前", "清空图片", "保存图片", "DIY 定制"],
            menuImageArray: ["tianjiatupian", "yichuquanbu", "yichudangqian", "baocuntupian",  "diy"],
            done: { [weak self] (selectedIndex) -> () in
                switch selectedIndex {
                case 0:
                    self?.addPhoto()
                case 1:
                    self?.removeCurrentSelectedPhoto()
                case 2:
                    self?.removeAllPhoto()
                case 3:
                    self?.savePhotoToAlbum()
                case 4:
                    self?.diyPhoto()
                default:
                    break
                }
        }) {
            print("点击了menu之外")
        }
        
    }
    
    /// 文本框值改变
    ///
    /// - Parameter textField: 文本框
    @objc fileprivate func textFieldChanged(textField: UITextField) {
        for materialParameter in photoMaterialParameterList {
            if materialParameter.isSelected {
                if textField == titleField {
                    materialParameter.title = textField.text
                } else {
                    materialParameter.subtitle = textField.text
                }
            }
        }
        photoCollectionView.reloadData()
    }
    
    /// 切换了分辨率
    ///
    /// - Parameter button: 当前分辨率按钮
    @objc fileprivate func didTapped(button: UIButton) {
        guard let subviews = button.superview?.subviews else { return }
        for view in subviews {
            if view.isKind(of: UIButton.classForCoder()) {
                (view as! UIButton).isSelected = false
            }
        }
        button.isSelected = true
    }
    
    /// 点击了预览
    ///
    /// - Parameter previewButton: 预览按钮
    @objc fileprivate func didTapped(previewButton: UIButton) {
        
        view.endEditing(true)
        
        if photoMaterialParameterList.count == 0 {
            JFProgressHUD.showInfoWithStatus("请先添加图片")
            return
        }
        
        var photoViewList = [JFPhotoView]()
        var defaultIndex = 0
        for (index, materialParameter) in photoMaterialParameterList.enumerated() {
            let photoView = JFPhotoView(materialParameter: materialParameter)
            photoViewList.append(photoView)
            if materialParameter.isSelected {
                defaultIndex = index
            }
        }
        
        // 弹出预览可滚动的视图
        JFPreviewView(photoViewList: photoViewList, defaultIndex: defaultIndex).show()
        
    }
    
    // MARK: - 懒加载UI
    /// 导航视图
    fileprivate lazy var navigationView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "nav_bg"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    /// 更多操作
    fileprivate lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "nav_add_icon"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 14))
        button.addTarget(self, action: #selector(didTapped(moreButton:)), for: .touchUpInside)
        return button
    }()
    
    /// 容器
    fileprivate lazy var containerView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.backgroundColor = BACKGROUND_COLOR
        return scrollView
    }()
    
    /// 图片背景
    fileprivate lazy var photoBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("4c4c4c")
        view.layer.cornerRadius = 5
        
        let label = UILabel()
        label.text = "图片"
        label.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        label.textColor = UIColor.colorWithHexString("b4b7bb")
        
        view.addSubview(label)
        
        label.snp.makeConstraints({ (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 14))
            make.top.equalTo(layoutHorizontal(iPhone6: 16))
        })
        
        return view
    }()
    
    /// 图片集合视图
    fileprivate lazy var photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: SettingPhotoItemWidth, height: SettingPhotoItemHeight)
        layout.minimumInteritemSpacing = layoutHorizontal(iPhone6: 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInset = UIEdgeInsets(
            top: layoutVertical(iPhone6: 14),
            left: layoutHorizontal(iPhone6: 14),
            bottom: layoutVertical(iPhone6: 14),
            right: layoutHorizontal(iPhone6: 14))
        collectionView.register(JFPhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoItemId)
        return collectionView
    }()
    
    /// 模板背景
    fileprivate lazy var templateBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("4c4c4c")
        view.layer.cornerRadius = 5
        
        let label = UILabel()
        label.text = "模板"
        label.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        label.textColor = UIColor.colorWithHexString("b4b7bb")
        
        view.addSubview(label)
        
        label.snp.makeConstraints({ (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 14))
            make.top.equalTo(layoutHorizontal(iPhone6: 16))
        })
        
        return view
    }()
    
    /// 模板集合视图
    fileprivate lazy var templateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: SettingPhotoItemWidth, height: SettingPhotoItemHeight)
        layout.minimumInteritemSpacing = layoutHorizontal(iPhone6: 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInset = UIEdgeInsets(
            top: layoutVertical(iPhone6: 14),
            left: layoutHorizontal(iPhone6: 14),
            bottom: layoutVertical(iPhone6: 14),
            right: layoutHorizontal(iPhone6: 14))
        collectionView.register(JFTemplateCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: TemplateItemId)
        return collectionView
    }()
    
    /// 分辨率背景
    fileprivate lazy var sizeBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("4c4c4c")
        view.layer.cornerRadius = 5
        
        let label = UILabel()
        label.text = "分辨率"
        label.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        label.textColor = UIColor.colorWithHexString("b4b7bb")
        
        let button1 = UIButton(type: .custom)
        button1.contentHorizontalAlignment = .left
        button1.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button1.setTitleColor(UIColor.colorWithHexString("808080"), for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        button1.setImage(UIImage(named: "size_weixuanzhong"), for: .normal)
        button1.setImage(UIImage(named: "size_selected"), for: .selected)
        button1.setTitle("3.5英寸(640*960)", for: .normal)
        button1.addTarget(self, action: #selector(didTapped(button:)), for: .touchUpInside)
        
        let button2 = UIButton(type: .custom)
        button2.contentHorizontalAlignment = .left
        button2.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button2.setTitleColor(UIColor.colorWithHexString("808080"), for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        button2.setImage(UIImage(named: "size_weixuanzhong"), for: .normal)
        button2.setImage(UIImage(named: "size_selected"), for: .selected)
        button2.setTitle("4.0英寸(640*1136)", for: .normal)
        button2.addTarget(self, action: #selector(didTapped(button:)), for: .touchUpInside)
        
        let button3 = UIButton(type: .custom)
        button3.contentHorizontalAlignment = .left
        button3.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button3.setTitleColor(UIColor.colorWithHexString("808080"), for: .normal)
        button3.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        button3.setImage(UIImage(named: "size_weixuanzhong"), for: .normal)
        button3.setImage(UIImage(named: "size_selected"), for: .selected)
        button3.setTitle("4.7英寸(750*1334)", for: .normal)
        button3.addTarget(self, action: #selector(didTapped(button:)), for: .touchUpInside)
        
        let button4 = UIButton(type: .custom)
        button4.contentHorizontalAlignment = .left
        button4.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button4.setTitleColor(UIColor.colorWithHexString("808080"), for: .normal)
        button4.titleLabel?.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        button4.setImage(UIImage(named: "size_weixuanzhong"), for: .normal)
        button4.setImage(UIImage(named: "size_selected"), for: .selected)
        button4.setTitle("5.5英寸(1242*2208)", for: .normal)
        button4.addTarget(self, action: #selector(didTapped(button:)), for: .touchUpInside)
        
        // 默认选中4.7寸
        button4.isSelected = true
        
        view.addSubview(label)
        view.addSubview(button1)
        view.addSubview(button2)
        view.addSubview(button3)
        view.addSubview(button4)
        
        label.snp.makeConstraints({ (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 14))
            make.top.equalTo(layoutVertical(iPhone6: 16))
        })
        
        button1.snp.makeConstraints({ (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 75))
            make.top.equalTo(layoutVertical(iPhone6: 16))
            make.right.equalTo(0)
        })
        
        button2.snp.makeConstraints({ (make) in
            make.left.equalTo(button1.snp.left)
            make.top.equalTo(button1.snp.bottom).offset(layoutVertical(iPhone6: 16))
            make.right.equalTo(0)
        })
        
        button3.snp.makeConstraints({ (make) in
            make.left.equalTo(button1.snp.left)
            make.top.equalTo(button2.snp.bottom).offset(layoutVertical(iPhone6: 16))
            make.right.equalTo(0)
        })
        
        button4.snp.makeConstraints({ (make) in
            make.left.equalTo(button1.snp.left)
            make.top.equalTo(button3.snp.bottom).offset(layoutVertical(iPhone6: 16))
            make.right.equalTo(0)
        })
        
        return view
    }()
    
    /// 主标题背景
    fileprivate lazy var titleBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("4c4c4c")
        view.layer.cornerRadius = 5
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorWithHexString("808080")
        
        view.addSubview(self.titleField)
        view.addSubview(lineView)
        
        self.titleField.snp.makeConstraints({ (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 50))
            make.right.equalTo(layoutHorizontal(iPhone6: -50))
            make.top.equalTo(layoutVertical(iPhone6: 12))
            make.bottom.equalTo(layoutVertical(iPhone6: -12))
        })
        
        lineView.snp.makeConstraints({ (make) in
            make.left.equalTo(self.titleField.snp.left)
            make.right.equalTo(self.titleField.snp.right)
            make.height.equalTo(1)
            make.top.equalTo(self.titleField.snp.bottom)
        })
        
        return view
    }()
    
    /// 标题
    fileprivate lazy var titleField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        textField.textAlignment = .center
        textField.textColor = UIColor.colorWithHexString("d3d3d3")
        textField.attributedPlaceholder = NSAttributedString(string: "主标题", attributes: [NSForegroundColorAttributeName : UIColor.colorWithHexString("808080")])
        textField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        return textField
    }()
    
    /// 副标题背景
    fileprivate lazy var subtitleBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("4c4c4c")
        view.layer.cornerRadius = 5
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorWithHexString("808080")
        
        view.addSubview(self.subtitleField)
        view.addSubview(lineView)
        
        self.subtitleField.snp.makeConstraints({ (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 50))
            make.right.equalTo(layoutHorizontal(iPhone6: -50))
            make.top.equalTo(layoutVertical(iPhone6: 12))
            make.bottom.equalTo(layoutVertical(iPhone6: -12))
        })
        
        lineView.snp.makeConstraints({ (make) in
            make.left.equalTo(self.subtitleField.snp.left)
            make.right.equalTo(self.subtitleField.snp.right)
            make.height.equalTo(1)
            make.top.equalTo(self.subtitleField.snp.bottom)
        })
        
        return view
    }()
    
    /// 副标题
    fileprivate lazy var subtitleField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: layoutFont(iPhone6: 16))
        textField.textAlignment = .center
        textField.textColor = UIColor.colorWithHexString("d3d3d3")
        textField.attributedPlaceholder = NSAttributedString(string: "副标题", attributes: [NSForegroundColorAttributeName : UIColor.colorWithHexString("808080")])
        textField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        return textField
    }()
    
    /// 预览
    fileprivate lazy var previewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("预览", for: .normal)
        button.setTitleColor(UIColor.colorWithHexString("333333"), for: .normal)
        button.setBackgroundImage(
            UIColor
                .colorWithHexString("f7ce00")
                .toImage()
                .redrawRoundedImage(
                    size: CGSize(
                        width: layoutHorizontal(iPhone6: 334),
                        height: layoutVertical(iPhone6: 40)),
                    bgColor: UIColor.colorWithHexString("333333"),
                    cornerRadius: 5),
            for: .normal)
        button.addTarget(self, action: #selector(didTapped(previewButton:)), for: .touchUpInside)
        return button
    }()
    
}

// MARK: - 设置界面
extension JFSettingViewController {
    
    /// 准备UI
    fileprivate func prepareUI() {
        view.backgroundColor = BACKGROUND_COLOR
        
        view.addSubview(navigationView)
        navigationView.addSubview(moreButton)
        view.addSubview(containerView)
        containerView.addSubview(photoBgView)
        containerView.addSubview(templateBgView)
        containerView.addSubview(sizeBgView)
        containerView.addSubview(titleBgView)
        
        // 如果没有副标题，则不显示UI
        if let materialParameter = materialParameterList?.first {
            if materialParameter.subtitleY > 1 {
                titleField.returnKeyType = .next
                titleField.delegate = self
                subtitleField.returnKeyType = .done
                subtitleField.delegate = self
                containerView.addSubview(subtitleBgView)
            } else {
                titleField.returnKeyType = .done
                titleField.delegate = self
            }
        }
        
        containerView.addSubview(previewButton)
        photoBgView.addSubview(photoCollectionView)
        templateBgView.addSubview(templateCollectionView)
        
        navigationView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(layoutVertical(iPhone6: 44) + 20)
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.right.equalTo(layoutHorizontal(iPhone6: -5))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 44), height: layoutVertical(iPhone6: 44)))
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(navigationView.snp.bottom)
        }
        
        photoBgView.snp.makeConstraints { (make) in
            make.centerX.equalTo(containerView)
            make.top.equalTo(layoutVertical(iPhone6: 22))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 334), height: layoutVertical(iPhone6: 130)))
        }
        
        templateBgView.snp.makeConstraints { (make) in
            make.centerX.equalTo(containerView)
            make.top.equalTo(photoBgView.snp.bottom).offset(layoutVertical(iPhone6: 15))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 334), height: layoutVertical(iPhone6: 130)))
        }
        
        sizeBgView.snp.makeConstraints { (make) in
            make.centerX.equalTo(containerView)
            make.top.equalTo(templateBgView.snp.bottom).offset(layoutVertical(iPhone6: 15))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 334), height: layoutVertical(iPhone6: 163)))
        }
        
        titleBgView.snp.makeConstraints { (make) in
            make.centerX.equalTo(containerView)
            make.top.equalTo(sizeBgView.snp.bottom).offset(layoutVertical(iPhone6: 15))
            make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 334), height: layoutVertical(iPhone6: 54)))
        }
        
        // 如果没有副标题，则不显示UI
        if let materialParameter = materialParameterList?.first {
            if materialParameter.subtitleY > 1 {
                subtitleBgView.snp.makeConstraints { (make) in
                    make.centerX.equalTo(containerView)
                    make.top.equalTo(titleBgView.snp.bottom).offset(layoutVertical(iPhone6: 15))
                    make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 334), height: layoutVertical(iPhone6: 54)))
                }
                
                previewButton.snp.makeConstraints { (make) in
                    make.centerX.equalTo(containerView)
                    make.top.equalTo(subtitleBgView.snp.bottom).offset(layoutVertical(iPhone6: 15))
                    make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 334), height: layoutVertical(iPhone6: 40)))
                }
            } else {
                previewButton.snp.makeConstraints { (make) in
                    make.centerX.equalTo(containerView)
                    make.top.equalTo(titleBgView.snp.bottom).offset(layoutVertical(iPhone6: 15))
                    make.size.equalTo(CGSize(width: layoutHorizontal(iPhone6: 334), height: layoutVertical(iPhone6: 40)))
                }
            }
        }
        
        photoCollectionView.snp.makeConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 45))
            make.top.equalTo(layoutVertical(iPhone6: 0))
            make.height.equalTo(SettingPhotoItemHeight + layoutVertical(iPhone6: 28))
            make.width.equalTo((SettingPhotoItemWidth + layoutHorizontal(iPhone6: 8)) * 4 + layoutHorizontal(iPhone6: 28))
        }
        
        templateCollectionView.snp.makeConstraints { (make) in
            make.left.equalTo(layoutHorizontal(iPhone6: 45))
            make.top.equalTo(layoutVertical(iPhone6: 0))
            make.height.equalTo(SettingPhotoItemHeight + layoutVertical(iPhone6: 28))
            make.width.equalTo((SettingPhotoItemWidth + layoutHorizontal(iPhone6: 8)) * 4 + layoutHorizontal(iPhone6: 28))
        }
        
        view.layoutIfNeeded()
        containerView.contentSize = CGSize(width: 0, height: previewButton.frame.maxY + layoutVertical(iPhone6: 30))
        
    }
    
}

// MARK: - 右上角各种事件处理
extension JFSettingViewController {
    
    /// DIY图片
    fileprivate func diyPhoto() {
        
        // 弹出插页广告
        if let interstitial = JFAdManager.shared.getReadyIntersitial() {
            interstitial.present(fromRootViewController: self)
            return
        }
        
        if photoMaterialParameterList.count == 0 {
            JFProgressHUD.showInfoWithStatus("请先添加图片")
            return
        }
        
        var photoImageList = [UIImage]()
        for materialParameter in photoMaterialParameterList {
            let photoView = JFPhotoView(materialParameter: materialParameter)
            
            // 视图转换截图
            if let image = viewToImage(view: photoView) {
                photoImageList.append(image)
            }
        }
        
        let diyVc = JFDiyViewController()
        diyVc.photoImageList = photoImageList
        present(diyVc, animated: true, completion: nil)
    }
    
    /// 移除当前选中图片
    fileprivate func removeCurrentSelectedPhoto() {
        
        // 弹出插页广告
        if let interstitial = JFAdManager.shared.getReadyIntersitial() {
            interstitial.present(fromRootViewController: self)
            return
        }
        
        if photoMaterialParameterList.count == 0 {
            JFProgressHUD.showInfoWithStatus("请先添加图片")
            return
        }
        
        // 遍历获取当前选中图片的下标
        var currentIndex = 0
        for (index, photoMaterialParameter) in photoMaterialParameterList.enumerated() {
            if photoMaterialParameter.isSelected {
                currentIndex = index
            }
        }
        
        // 移除当前选中的图片
        photoMaterialParameterList.remove(at: currentIndex)
        
        // 移除后如果还有一张以上，就默认选中第一张图
        if photoMaterialParameterList.count > 0 {
            collectionView(photoCollectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        } else {
            photoCollectionView.reloadData()
            templateCollectionView.reloadData()
        }
        
    }
    
    /// 移除所有图片
    fileprivate func removeAllPhoto() {
        
        // 弹出插页广告
        if let interstitial = JFAdManager.shared.getReadyIntersitial() {
            interstitial.present(fromRootViewController: self)
            return
        }
        
        if photoMaterialParameterList.count == 0 {
            JFProgressHUD.showInfoWithStatus("请先添加图片")
            return
        }
        
        // 移除所有图片
        photoMaterialParameterList.removeAll()
        titleField.text = nil
        subtitleField.text = nil
        
        photoCollectionView.reloadData()
        templateCollectionView.reloadData()
        
    }
    
    /// 保存图片到相册
    fileprivate func savePhotoToAlbum() {
        
        // 弹出插页广告
        if let interstitial = JFAdManager.shared.getReadyIntersitial() {
            interstitial.present(fromRootViewController: self)
            return
        }
        
        // 判断有没有分享过，如果没有则要求分享一次 - 如有需要分享则返回true
        if JFAdManager.shared.showShareAlert(vc: self) {
            return
        }
        
        if photoMaterialParameterList.count == 0 {
            JFProgressHUD.showInfoWithStatus("请先添加图片")
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
        
        for materialParameter in photoMaterialParameterList {
            if materialParameter.isSelected {
                let photoView = JFPhotoView(materialParameter: materialParameter)
                // 视图转换截图
                if let image = viewToImage(view: photoView) {
                    // 保存图片到相册
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSavedToPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
        
    }
    
    /// 保存多图
    fileprivate func saveMoreImage() {
        
        for materialParameter in photoMaterialParameterList {
            let photoView = JFPhotoView(materialParameter: materialParameter)
            // 视图转换截图
            if let image = viewToImage(view: photoView) {
                // 保存图片到相册
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSavedToPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
            }
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
    
    /// 将做好的应用截图转成UIImage对象
    ///
    /// - Parameter view: 视图
    /// - Returns: UIImage
    fileprivate func viewToImage(view: UIView) -> UIImage? {
        
        // 将视图渲染成图片
        UIApplication.shared.keyWindow?.insertSubview(view, at: 0)
        UIGraphicsBeginImageContextWithOptions(SCREEN_BOUNDS.size, true, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        view.removeFromSuperview()
        
        // 获取当前选中的尺寸
        var size = CGSize.zero
        for subview in sizeBgView.subviews {
            if subview.isKind(of: UIButton.classForCoder()) {
                let button = subview as! UIButton
                if button.isSelected {
                    switch button.title(for: .normal) ?? "" {
                    case "3.5英寸(640*960)": // 3.5 - 640*960
                        size = CGSize(width: 640, height: 960)
                    case "4.0英寸(640*1136)": // 4.0 - 640*1136
                        size = CGSize(width: 640, height: 1136)
                    case "4.7英寸(750*1334)": // 4.7 - 750*1334
                        size = CGSize(width: 750, height: 1334)
                    case "5.5英寸(1242*2208)": // 5.5 - 1242*2208
                        size = CGSize(width: 1242, height: 2208)
                    default:
                        break
                    }
                }
            }
        }
        // 转换单位
        size = CGSize(width: size.width / UIScreen.main.scale, height: size.height / UIScreen.main.scale)
        
        // 根据尺寸重绘图片
        return image?.redrawImage(size: size)
    }
    
    /// 添加图片
    fileprivate func addPhoto() {
        
        // 弹出插页广告
        if let interstitial = JFAdManager.shared.getReadyIntersitial() {
            interstitial.present(fromRootViewController: self)
            return
        }
        
        // 判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoPickerVc = JFPhotoPickerViewController()
            photoPickerVc.delegate = self
            present(photoPickerVc, animated: true, completion: nil)
        } else {
            log("读取相册错误")
        }
    }
    
}

// MARK: - 设置做成的截图视图和模板视图
extension JFSettingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView {
            return photoMaterialParameterList.count
        } else {
            return materialParameterList?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemId, for: indexPath) as! JFPhotoCollectionViewCell
            cell.materialParameter = photoMaterialParameterList[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateItemId, for: indexPath) as! JFTemplateCollectionViewCell
            cell.materialParameter = materialParameterList?[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        view.endEditing(true)
        
        if collectionView == photoCollectionView {
            
            // 切换到当前选中item
            let materialParameter = photoMaterialParameterList[indexPath.item]
            // 如果点击的还是当前选中的图片则直接返回
            if materialParameter.isSelected == true {
                return
            }
            for materialParameter in photoMaterialParameterList {
                materialParameter.isSelected = false
            }
            materialParameter.isSelected = true
            
            // 设置文本框
            titleField.text = materialParameter.title
            subtitleField.text = materialParameter.subtitle
            
            // 切换模板选中状态
            for materialParameter in materialParameterList ?? [JFMaterialParameter]() {
                materialParameter.isSelected = false
            }
            if let sourceImageName = materialParameter.sourceImageName {
                let num = sourceImageName.substring(with: Range<String.Index>(sourceImageName.index(sourceImageName.endIndex, offsetBy: -5)..<sourceImageName.index(sourceImageName.endIndex, offsetBy: -4)))
                let index = Int(num) ?? 1
                if let materialParameter = materialParameterList?[index - 1] {
                    materialParameter.isSelected = true
                }
            }
            
        } else {
            
            // 切换到当前选中item
            let materialParameter = materialParameterList?[indexPath.item]
            // 如果点击的还是当前选中的模板则直接返回
            if materialParameter?.isSelected == true {
                return
            }
            for materialParameter in materialParameterList ?? [JFMaterialParameter]() {
                materialParameter.isSelected = false
            }
            materialParameter?.isSelected = true
            
            // 如果还没有图片则直接返回
            if photoMaterialParameterList.count == 0 {
                templateCollectionView.reloadData()
                return
            }
            
            // 切换图片里的模板
            var editIndex = 0
            var newPhotoMaterialParameter: JFMaterialParameter!
            for (index, photoMaterialParameter) in photoMaterialParameterList.enumerated() {
                if photoMaterialParameter.isSelected {
                    editIndex = index
                    
                    // 拷贝新的模板参数
                    newPhotoMaterialParameter = materialParameter?.copy() as! JFMaterialParameter
                    newPhotoMaterialParameter.title = photoMaterialParameter.title
                    newPhotoMaterialParameter.subtitle = photoMaterialParameter.subtitle
                    newPhotoMaterialParameter.screenShotImage = photoMaterialParameter.screenShotImage
                    newPhotoMaterialParameter.isSelected = photoMaterialParameter.isSelected
                }
            }
            photoMaterialParameterList[editIndex] = newPhotoMaterialParameter
            
        }
        
        photoCollectionView.reloadData()
        templateCollectionView.reloadData()
        
    }
    
}

// MARK: - 图片选择回调
extension JFSettingViewController: JFPhotoPickerViewControllerDelegate {
    
    func didSelected(imageList: [UIImage]) {
        
        // 一张图片都没有选择，则直接返回
        if imageList.count == 0 {
            return
        }
        
        // 取消上一个选择
        for materialParameter in photoMaterialParameterList {
            materialParameter.isSelected = false
        }
        
        // 添加图片模型
        for (index, image) in imageList.enumerated() {
            for materialParameter in materialParameterList ?? [JFMaterialParameter]() {
                // 防止内存峰值
                autoreleasepool { [weak self] in
                    if materialParameter.isSelected {
                        let photoMaterialParameter = materialParameter.copy() as! JFMaterialParameter
                        photoMaterialParameter.screenShotImage = image.redrawImage(size: CGSize(
                            width: photoMaterialParameter.screenShotWidth,
                            height: photoMaterialParameter.screenShotHeight))
                        // 每次添加图片，设置添加的首张图片为选中项
                        if index == 0 {
                            photoMaterialParameter.isSelected = true
                        } else {
                            photoMaterialParameter.isSelected = false
                        }
                        self?.photoMaterialParameterList.append(photoMaterialParameter)
                    }
                }
                
            }
        }
        
        // 清空文本框
        titleField.text = nil
        subtitleField.text = nil
        photoCollectionView.reloadData()
        
        // 如果一次性添加5张图，只偏移4个位置。否则影响美观
        var itemIndex = 0
        if imageList.count > 4 {
            itemIndex = photoMaterialParameterList.count - 2
        } else {
            itemIndex = photoMaterialParameterList.count - 1
        }
        
        photoCollectionView.scrollToItem(at: IndexPath(item: itemIndex, section: 0), at: .right, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension JFSettingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            subtitleField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if photoMaterialParameterList.count == 0 {
            JFProgressHUD.showInfoWithStatus("请先添加图片")
            view.endEditing(true)
            return false
        }
        return true
    }
    
}

// MARK: - UIScrollViewDelegate
extension JFSettingViewController: UIScrollViewDelegate {
    
    /// 开始拖拽视图记录y方向偏移量
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (scrollView == containerView) {
            contentOffsetY = scrollView.contentOffset.y
        }
    }
    
    /// 松开手开始减速
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == containerView) {
            if scrollView.contentOffset.y - contentOffsetY > 5.0 { // 向上拖拽
                view.endEditing(true)
            } else if contentOffsetY - scrollView.contentOffset.y > 5.0 { // 向下拖拽
                view.endEditing(true)
            }
        }
    }
    
}
