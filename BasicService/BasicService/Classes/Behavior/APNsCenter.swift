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
    public init() {
    }
    public var type: String = ""
    public var url: String = ""
    public var content: String = ""
    public var para: Dictionary<String, Any>?
    public var lastMsgTime: String = ""
    public var id: String = ""
}

public class APNsCenter: NSObject, DxwPushAlertViewDelegate {
    
    public static let shared : APNsCenter = APNsCenter()
    public var uInfo: [AnyHashable: Any]?
    public var readPushBlock: (((url: String, param: Dictionary<String, Any>?)) -> Void)?
    
    public class func inputPushInfo(_ userInfo : [AnyHashable: Any] , isActivity : Bool = false) {
        let info = userInfo as! Dictionary<String , Any>
        let action = info["action"] as? Dictionary<String , Any> ?? DxwDic()
        let url = action["url"] + ""
        if isActivity {
            if let aps = info["aps"] as? Dictionary<String , Any> {
                UtilTools.getAppDelegate()?.window??.endEditing(true)
                var td = PushMsgData()
                td.type = action["type"] + ""
                td.url = action["url"] + ""
                td.content = aps["alert"] + ""
                td.para = action["para"] as? Dictionary<String, Any>
                td.id = action["id"] + ""
                if !DxwPushAlertView.existMsg(id: td.id) {
                    let pushAlert = DxwPushAlertView()
                    pushAlert.delegate = shared
                    pushAlert.data = td
                    pushAlert.show()
                }
            }
            shared.uInfo = userInfo
            
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
            let id = action["id"] + ""
            if !id.isEmpty {
                var ids: Array<String> = []
                if let msgIds = UtilTools.getUserDefaults(PUSH_MSG_IDS) as? Array<String> {
                    ids = msgIds
                }
                ids.append(id)
                UtilTools.setUserDefaults(ids, key: PUSH_MSG_IDS)
            }
            dealPushNotification(userInfo)
        }
    }
    
    public class func dealPushNotification(_ userInfo : [AnyHashable: Any]?) {
        if userInfo == nil {
            return
        }
        let info = userInfo as! Dictionary<String , Any>
        let action = info["action"] as? Dictionary<String , Any> ?? DxwDic()
        let url = action["url"] + ""
        let para = action["para"] as? Dictionary<String, Any>
        
        let backUrl = action["back_url"] as? String
        let backPara = action["back_para"] as? Dictionary<String, Any>
        
        //            let id = action["id"] + ""
        //            if !id.isEmpty { //通知服务器推送被阅读
        //                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
        //                    //EventService.pushReadBy(id: id)
        //                })
        //            }
        if backUrl != nil && backUrl!.count > 0 {
            shared.readPushBlock?((backUrl!, backPara))
            shared.readPushBlock?((url, para))
        }else{
            shared.readPushBlock?((url, para))
        }
    }
    
    public func dxwPushAlertViewAllMsg() {
        Behavior.behaviorRefer = "push_fg"
        readPushBlock?(("/sy/xxzx", nil))
    }
    
    public func dxwPushAlertViewDetail(type: String, url: String, param: DxwDic?) {
        Behavior.eventReport("push_read_fg", isPage: false,to : url)
        Behavior.behaviorRefer = "push_fg"
        readPushBlock?((url, param))
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
    
    @available(iOS 10.0, *)
    public class func registerNotification(unDelegate: UNUserNotificationCenterDelegate?) {
        UNUserNotificationCenter.current().delegate = unDelegate
        apnsSetter.registerForNotification()
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
        }
        let settings = UIUserNotificationSettings(types: [UIUserNotificationType.sound, UIUserNotificationType.badge, UIUserNotificationType.alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
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

