//
//  JFAlbumListViewController.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit
import pop

fileprivate let JFAlbumItemId = "JFAlbumItemId"
fileprivate let JFAlbumItemCols = 2               // 一行2列
fileprivate let JFAlbumItemMargin: CGFloat = layoutVertical(iPhone6: 5)  // item间隔

protocol JFAlbumListViewControllerDelegate: NSObjectProtocol {
    
    /// 切换了相册
    func didChangedAlbum()
    
}

class JFAlbumListViewController: UIViewController {
    
    // MARK: - 属性
    var albumItemList = [JFAlbumItem]()
    
    weak var delegate: JFAlbumListViewControllerDelegate?
    
    // tableview重用标识符
    let popoverIdentifier = "popoverCell"
    
    // MARK: - 视图声明周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 准备UI
        prepareUI()
        
    }
    
    // MARK: - 懒加载
    // 背景图片
    lazy var backgroundView: UIImageView = {
        let imageView = UIImageView()
        var image = UIImage(named: "photo_popover_background") ?? UIImage()
        image = image.resizableImage(withCapInsets: UIEdgeInsets(top: image.size.height * 0.5, left: image.size.width * 0.5 - 100, bottom: image.size.height * 0.5, right: image.size.width * 0.5 - 100), resizingMode: UIImageResizingMode.stretch)
        imageView.image = image
        return imageView
    }()
    
    /// 列表容器视图
    fileprivate lazy var containerView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let JFAlbumItemWidth = (layoutHorizontal(iPhone6: 300) - JFAlbumItemMargin * CGFloat(JFAlbumItemCols - 1) * 2 - 24) / CGFloat(JFAlbumItemCols)
        layout.itemSize = CGSize(width: JFAlbumItemWidth, height: JFAlbumItemWidth + layoutVertical(iPhone6: 30))
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = JFAlbumItemMargin * 2
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = BACKGROUND_COLOR
        collectionView.register(JFAlbumItemCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: JFAlbumItemId)
        return collectionView
    }()
    
}

// MARK: - 设置界面
extension JFAlbumListViewController {
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        // 背景颜色透明
        view.backgroundColor = UIColor.clear
        
        // 添加子控件
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.right.equalTo(-12)
        }
        
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension JFAlbumListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JFAlbumItemId, for: indexPath) as! JFAlbumItemCollectionViewCell
        cell.albumItem = albumItemList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 如果没有改变相册，则直接返回并不刷新
        if albumItemList[indexPath.item].isSelected {
            dismiss(animated: true, completion: nil)
            return
        }
        
        // 切换相册选中状态
        for albumItem in albumItemList {
            albumItem.isSelected = false
        }
        let albumItem = albumItemList[indexPath.item]
        albumItem.isSelected = !albumItem.isSelected
        collectionView.reloadData()
        
        // 延迟回调刷新新相册数据
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { [weak self] in
            self?.dismiss(animated: true) {
                self?.delegate?.didChangedAlbum()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! JFAlbumItemCollectionViewCell
        UIView.animate(withDuration: 0.25) {
            cell.shadowView.alpha = 1.0
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! JFAlbumItemCollectionViewCell
        UIView.animate(withDuration: 0.25) {
            cell.shadowView.alpha = 0.0
        }
    }
    
}
