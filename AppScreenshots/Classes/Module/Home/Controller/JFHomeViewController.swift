//
//  JFHomeViewController.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/1.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

fileprivate let HomeItemId = "HomeItemId"

class JFHomeViewController: UIViewController {
    
    /// 素材模型集合
    let materialList = JFMaterial.getMaterialList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    // MARK: - 懒加载UI
    /// 导航视图
    fileprivate lazy var navigationView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "nav_bg"))
        return imageView
    }()
    
    /// 列表容器视图
    fileprivate lazy var containerView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: HomeItemWidth, height: HomeItemHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = layoutVertical(iPhone6: 8)
        layout.sectionInset = UIEdgeInsets(
            top: layoutVertical(iPhone6: 4),
            left: layoutHorizontal(iPhone6: 4),
            bottom: layoutVertical(iPhone6: 4),
            right: layoutHorizontal(iPhone6: 4))
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = BACKGROUND_COLOR
        collectionView.contentInset = UIEdgeInsets(
            top: layoutVertical(iPhone6: 8),
            left: layoutHorizontal(iPhone6: 4),
            bottom: layoutVertical(iPhone6: 4),
            right: layoutHorizontal(iPhone6: 4))
        collectionView.register(JFHomeCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: HomeItemId)
        return collectionView
    }()
    
}

// MARK: - 准备节目
extension JFHomeViewController {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        view.backgroundColor = BACKGROUND_COLOR
        view.addSubview(navigationView)
        view.addSubview(containerView)
        
        navigationView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(layoutVertical(iPhone6: 44) + 20)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(navigationView.snp.bottom)
        }
        
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension JFHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return materialList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeItemId, for: indexPath) as! JFHomeCollectionViewCell
        cell.material = materialList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 转换坐标系
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: HomeItemId, for: indexPath) as! JFHomeCollectionViewCell
        let rect = item.convert(item.frame, to: view)
        
        // 计算item相对于窗口的frame
        let x = indexPath.item % 2 == 0 ? rect.origin.x : rect.origin.x / 2 + layoutHorizontal(iPhone6: 4)
        let y = layoutVertical(iPhone6: 44) + 20
            + CGFloat(indexPath.item / 2) * (rect.size.height + layoutVertical(iPhone6: 8))
            - collectionView.contentOffset.y
            + layoutVertical(iPhone6: 4)
        let width = rect.size.width
        let height = rect.size.height
        
        let material = materialList[indexPath.item]
        let tempImageView = UIImageView()
        tempImageView.image = UIImage(named: material.listImageName ?? "")
        tempImageView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        UIApplication.shared.keyWindow?.addSubview(tempImageView)
        
        UIView.animate(withDuration: 0.5, animations: { 
            tempImageView.frame = CGRect(
                x: layoutHorizontal(iPhone6: 79.5),
                y: layoutVertical(iPhone6: 225) + 20,
                width: layoutHorizontal(iPhone6: 56),
                height: layoutVertical(iPhone6: 100))
        }) { (_) in
            tempImageView.removeFromSuperview()
        }
        
        // 素材参数模型集合，创建一个新的集合。防止对原集合修改
        var materialParameterList = [JFMaterialParameter]()
        for materialParameter in material.materialParameterList ?? [JFMaterialParameter]() {
            materialParameterList.append(materialParameter.copy() as! JFMaterialParameter)
        }
        
        let settingVc = JFSettingViewController()
        settingVc.materialParameterList = materialParameterList
        settingVc.transitioningDelegate = self
        settingVc.modalPresentationStyle = .custom
        present(settingVc, animated: true) { 
            
        }
    }
    
}

// MARK: - 栏目管理自定义转场动画事件
extension JFHomeViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return JFPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPopoverModalAnimation()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPopoverDismissAnimation()
    }
    
}
