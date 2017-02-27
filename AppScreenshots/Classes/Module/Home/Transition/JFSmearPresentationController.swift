//
//  JFSmearPresentationController.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFSmearPresentationController: UIPresentationController {
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = SCREEN_BOUNDS
    }
    
}
