//
//  APNsCenter.swift
//  QminiFund
//
//  Created by zhangyr on 15/10/28.
//  Copyright © 2015年 quchaogu. All rights reserved.
//

import UIKit
import UserNotifications
import QCGURLRouter

public struct PushMsgData {
    var type: String = ""
    var url: String = ""
    var content: String = ""
    var para: Dictionary<String, Any>?
    var lastMsgTime: String = ""
    var id: String = ""
}

public class APNsCenter: NSObject, DxwPushAlertViewDelegate {
    
    public static let center : APNsCenter = APNsCenter()
    public var uInfo: [AnyHashable: Any]?
    
    public class func inputPushInfo(_ userInfo : [AnyHashable: Any] , isActivity : Bool = false) {
        let info = userInfo as! Dictionary<String , AnyObject>
        let action  = info["action"] as! Dictionary<String , AnyObject>
        let url = action["url"] + ""
        //let id      = action["id"] + ""
        if isActivity {
            if let aps = info["aps"] as? Dictionary<String , Any> {
                UtilTools.getAppDelegate()?.keyWindow?.endEditing(true)
                var td = PushMsgData()
                td.type = action["type"] + ""
                td.url = action["url"] + ""
                td.content = aps["alert"] + ""
                td.para = action["para"] as? Dictionary<String, Any>
                td.id = action["id"] + ""
                let pushAlert = DxwPushAlertView()
                pushAlert.delegate = center
                pushAlert.data = td
                pushAlert.show()
            }
            center.uInfo = userInfo
            
        }else{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.45 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                if let tmpPara = action["para"] as? Dictionary<String, Any>
                {
                    if let urlWithPara = UtilTools.getUrlWithParameter(url, parameters: tmpPara) {
                        Behavior.eventReport("push_read_bg", isPage: false,to : urlWithPara)
                    }else{
                        Behavior.eventReport("push_read_bg", isPage: false,to : url)
                    }
                }else{
                    Behavior.eventReport("push_read_bg", isPage: false,to : url)
                }
            }
            dealPushNotification(userInfo)
        }
    }
    
    public class func dealPushNotification(_ userInfo : [AnyHashable: Any]?) {
        if userInfo == nil {
            return
        }
        let info = userInfo as! Dictionary<String , Any>
        jumpPage(info: info, isPush: true)
    }
    
    public func dxwPushAlertViewAllMsg() {
        Behavior.behaviorRefer = "push_fg"
    }
    
    public func dxwPushAlertViewDetail(type: String, url: String, param: DxwDic?) {
        Behavior.eventReport("push_read_fg", isPage: false,to : url)
        Behavior.behaviorRefer = "push_fg"
        if let uri = URL(string: url) {
            QCGURLRouter.shareInstance.route(withUrl: uri)
        }
    }
    
    public func dxwPushAlertViewOpenNoti() {
        if #available(iOS 10.0, *) {
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }else{
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

public class APNsSetter: NSObject, SMAlertViewDelegate {
    public static let apnsSetter = APNsSetter()
    public static var isOpenNotification: Bool = false
    
    public class func setupNotification(_ notiStr : String, forceAlert : Bool = false) {
        if forceAlert {
            let alert = SMAlertView(title: "允许通知", message: notiStr, delegate: apnsSetter, cancelButtonTitle: "暂不开启", otherButtonTitles: "开启")
            alert.show()
        }else{
            apnsSetter.registerForNotification()
        }
    }
    
    public class func registerNotification() {
        apnsSetter.registerForNotification()
    }
    
    private func smAlert(_ alert: SMAlertView, clickButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alert.cancelButtonIndex {
            registerForNotification()
        }
    }
    
    fileprivate func registerForNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [UNAuthorizationOptions.badge,UNAuthorizationOptions.sound,UNAuthorizationOptions.alert], completionHandler: { (granted, error) in
                if granted {
                }else{
                }
            })
        }else{
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.sound, UIUserNotificationType.badge, UIUserNotificationType.alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    public class func checkNotification() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                switch settings.authorizationStatus {
                case .notDetermined: //未注册
                    isOpenNotification = false
                    break
                case .denied: //未开启
                    isOpenNotification = false
                    break
                case .authorized: //开启
                    isOpenNotification = true
                    break
                default:
                    break
                }
            })
        }else{
            if UIApplication.shared.currentUserNotificationSettings?.types != UIUserNotificationType() { //开启
                isOpenNotification = true
            }else{
                isOpenNotification = false
            }
        }
    }
}

