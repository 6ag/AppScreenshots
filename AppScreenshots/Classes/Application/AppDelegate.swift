//
//  AppDelegate.swift
//  AppScreenshots
//
//  Created by zhoujianfeng on 2017/2/1.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupRootViewController() // 配置控制器
        setupKeyBoardManager()    // 配置键盘管理
        setupADManager()          // 初始化广告管理者
        setupMobClick()           // 初始化友盟统计
        setupUSharePlatforms()    // 初始化友盟分享
        checkShowShare()
        return true
    }
    
    /// 检查是否需要弹出分享
    fileprivate func checkShowShare() {
        
        // 如果正在更新版本中，则隐藏功能
        JFAppStoreApp.getAppStoreApp { (app, isUpdatingVersion) in
            if let _ = app {
                UserDefaults.standard.set(isUpdatingVersion, forKey: "isUpdatingVersion")
            } else {
                // 请求出了问题，为了防止意外，也当成正在更新版本中
                UserDefaults.standard.set(true, forKey: "isUpdatingVersion")
            }
        }
        
    }
    
    /// 初始化友盟分享
    fileprivate func setupUSharePlatforms() {
        
        UMSocialManager.default().openLog(false)
        UMSocialGlobal.shareInstance().isUsingHttpsWhenShareContent = true
        
        // 设置友盟appKey
        UMSocialManager.default().umSocialAppkey = UM_APP_KEY
        
        // 微信聊天
        UMSocialManager.default().setPlaform(UMSocialPlatformType.wechatSession, appKey: WX_APP_ID, appSecret: WX_APP_SECRET, redirectURL: "http://mobile.umeng.com/social")
        
        // 微信收藏
        UMSocialManager.default().setPlaform(UMSocialPlatformType.wechatFavorite, appKey: WX_APP_ID, appSecret: WX_APP_SECRET, redirectURL: "http://mobile.umeng.com/social")
        
        // 微信朋友圈
        UMSocialManager.default().setPlaform(UMSocialPlatformType.wechatTimeLine, appKey: WX_APP_ID, appSecret: WX_APP_SECRET, redirectURL: "http://mobile.umeng.com/social")
        
        // 腾讯
        UMSocialManager.default().setPlaform(UMSocialPlatformType.QQ, appKey: QQ_APP_ID, appSecret: nil, redirectURL: "http://mobile.umeng.com/social")

        // 新浪
        UMSocialManager.default().setPlaform(UMSocialPlatformType.sina, appKey: SINA_APP_KEY, appSecret: SINA_APP_SECRET, redirectURL: "https://sns.whalecloud.com/sina2/callback")
        
    }
    
    /// 初始化友盟统计
    fileprivate func setupMobClick() {
        let config = UMAnalyticsConfig.sharedInstance()
        config?.appKey = UM_APP_KEY
        config?.channelId = "App Store"
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        MobClick.setAppVersion(currentVersion)
        MobClick.start(withConfigure: config)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let result = UMSocialManager.default().handleOpen(url)
        if result {
            
        }
        return result
    }
    
    /// 初始化广告管理者
    fileprivate func setupADManager() {
        JFAdConfiguration.shared.config(
            applicationId: "ca-app-pub-3941303619697740~8182246519",
            interstitialId: "ca-app-pub-3941303619697740/9658979714",
            bannerId: "",
            timeInterval: 120)
    }
    
    /**
     配置键盘管理者
     */
    fileprivate func setupKeyBoardManager() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    /**
     全局样式
     */
    func setupGlobalStyle() {
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        // 配置HUD
        JFProgressHUD.setupHUD()
    }
    
    /**
     添加根控制器
     */
    fileprivate func setupRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        if isNewVersion() {
            window?.rootViewController = JFNewFeatureViewController()
        } else {
            window?.rootViewController = JFHomeViewController()
            setupGlobalStyle()
        }
        window?.makeKeyAndVisible()
    }
    
    /**
     判断是否是新版本
     */
    fileprivate func isNewVersion() -> Bool {
        // 获取当前的版本号
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        // 获取到之前的版本号
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxVersion = UserDefaults.standard.string(forKey: sandboxVersionKey)
        
        // 保存当前版本号
        UserDefaults.standard.set(currentVersion, forKey: sandboxVersionKey)
        UserDefaults.standard.synchronize()
        
        // 当前版本和沙盒版本不一致就是新版本
        return currentVersion != sandboxVersion
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

