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

//  https://itunes.apple.com/lookup?id=app_id
//{
//    "resultCount": 1,
//    "results": [
//    {
//    "artistViewUrl": "https://itunes.apple.com/us/developer/yijing-pan/id1110293593?uo=4",
//    "artworkUrl60": "http://is1.mzstatic.com/image/thumb/Purple111/v4/79/79/70/797970b6-a21b-95ad-2b45-88141e486f0f/source/60x60bb.jpg",
//    "artworkUrl100": "http://is1.mzstatic.com/image/thumb/Purple111/v4/79/79/70/797970b6-a21b-95ad-2b45-88141e486f0f/source/100x100bb.jpg",
//    "ipadScreenshotUrls": [
//    "http://a2.mzstatic.com/us/r30/Purple71/v4/53/f1/22/53f122d7-4171-5852-4275-1078933ab090/sc1024x768.jpeg",
//    "http://a5.mzstatic.com/us/r30/Purple71/v4/66/1b/07/661b07e7-c08e-853f-7678-f6c67d228524/sc1024x768.jpeg",
//    "http://a3.mzstatic.com/us/r30/Purple71/v4/43/9c/61/439c6103-b223-b0fe-f972-60831faf2b2b/sc1024x768.jpeg",
//    "http://a4.mzstatic.com/us/r30/Purple71/v4/0a/2a/71/0a2a71ce-4fa5-e6bd-e1d4-bb42c0df0ffc/sc1024x768.jpeg"
//    ],
//    "appletvScreenshotUrls": [],
//    "artworkUrl512": "http://is1.mzstatic.com/image/thumb/Purple111/v4/79/79/70/797970b6-a21b-95ad-2b45-88141e486f0f/source/512x512bb.jpg",
//    "screenshotUrls": [
//    "http://a1.mzstatic.com/us/r30/Purple62/v4/c0/e8/60/c0e8603a-f584-aa66-e677-6165d8a4d37a/screen696x696.jpeg",
//    "http://a3.mzstatic.com/us/r30/Purple71/v4/0b/f1/2e/0bf12eb3-1536-cfce-b912-9139012aa33c/screen696x696.jpeg",
//    "http://a3.mzstatic.com/us/r30/Purple71/v4/4d/50/13/4d50136f-1742-fe7b-7d94-a9ee6a940f29/screen696x696.jpeg",
//    "http://a4.mzstatic.com/us/r30/Purple71/v4/71/26/2a/71262aac-53e0-6f72-194b-cde65cb57b64/screen696x696.jpeg"
//    ],
//    "isGameCenterEnabled": false,
//    "kind": "software",
//    "features": [
//    "iosUniversal"
//    ],
//    "supportedDevices": [
//    "iPad2Wifi",
//    "iPad23G",
//    "iPhone4S",
//    "iPadThirdGen",
//    "iPadThirdGen4G",
//    "iPhone5",
//    "iPodTouchFifthGen",
//    "iPadFourthGen",
//    "iPadFourthGen4G",
//    "iPadMini",
//    "iPadMini4G",
//    "iPhone5c",
//    "iPhone5s",
//    "iPhone6",
//    "iPhone6Plus",
//    "iPodTouchSixthGen"
//    ],
//    "advisories": [],
//    "trackCensoredName": "自学英语 - 海量英语视频教程任你学！",
//    "trackViewUrl": "https://itunes.apple.com/us/app/zi-xue-ying-yu-hai-liang-ying/id1146271758?mt=8&uo=4",
//    "contentAdvisoryRating": "4+",
//    "languageCodesISO2A": [
//    "ZH"
//    ],
//    "fileSizeBytes": "59480064",
//    "trackContentRating": "4+",
//    "genreIds": [
//    "6017",
//    "6006"
//    ],
//    "minimumOsVersion": "8.0",
//    "currency": "USD",
//    "wrapperType": "software",
//    "version": "1.0.7",
//    "artistId": 1110293593,
//    "artistName": "Yijing Pan",
//    "genres": [
//    "Education",
//    "Reference"
//    ],
//    "price": 0,
//    "description": "自学英语精选4000余集免费英语视频教程，本app包含音标、单词、语法、口语、听力、阅读、作文等全方面的英语视频教程。\n无论你现在处于什么阶段，都能找到合适您学习的视频教程。\n\n特色：\n1.海量视频教程，你想要的我就给你。\n2.离线视频缓存，随时随地不用流量也能学习哦。\n3.语法手册，视频看累了也可以看看手册。\n4.内置微社区，互相监督学习进度！\n\n英语学习QQ群：576706713\nbug反馈邮箱：admin@6ag.cn",
//    "trackName": "自学英语 - 海量英语视频教程任你学！",
//    "bundleId": "cn.6ag.EnglishCommunity-swift",
//    "trackId": 1146271758,
//    "releaseDate": "2016-09-10T07:37:01Z",
//    "primaryGenreName": "Education",
//    "isVppDeviceBasedLicensingEnabled": true,
//    "formattedPrice": "Free",
//    "currentVersionReleaseDate": "2017-02-08T16:14:51Z",
//    "releaseNotes": "适配iOS10\n优化整体性能",
//    "sellerName": "Yijing Pan",
//    "primaryGenreId": 6017
//    }
//    ]
//}
