//
//  JFAppStoreApp.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/13.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFAppStoreApp: NSObject {
    
    // 版本号
    var version: String?
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}

    /// 获取AppStore内当前app的信息
    ///
    /// - Parameter finished: 回调
    class func getAppStoreApp(finished: @escaping (_ app: JFAppStoreApp?, _ isUpdatingVersion: Bool) -> ()) {
        
        JFNetworkTools.shared.get("https://itunes.apple.com/lookup", parameters: ["id" : APPSTORE_ID]) { (isSuccess, result, error) in
            guard let results = result?["results"] as? [[String : AnyObject]] else {
                finished(nil, false)
                return
            }
            
            if results.count != 1 {
                finished(nil, false)
                return
            }
            
            let app = JFAppStoreApp(dict: results.first!)
            guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                let serverVersion = app.version,
                currentVersion == serverVersion else {
                    log("正在审核新版本中 currentVersion = \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) serverVersion = \(app.version)")
                    finished(app, true)
                return
            }
            
            log("已经更新了新版本 currentVersion = \(currentVersion) serverVersion = \(serverVersion)")
            finished(app, false)
        }
        
    }
    
}
