//
//  UtilCheck.swift
//  quchaogu
//
//  Created by wangdong on 15/3/15.
//  Copyright (c) 2015年 wangdong. All rights reserved.
//

import UIKit
import UserNotifications

public enum LoginPlatformType: CaseIterable {
    case qq
    case wechat
    case mobile
    case none
}

public class UtilCheck {
    //检测手机号
    //^1[3|4|5|7|8]\d{9}$
    public class func checkMobile(_ mobile: String) -> Bool {
        if mobile.count == 11 && Int(mobile) != nil {
            return true
        }
        return false
    }
    
    //检测密码
    //>6位 不能全数字或字母
    public class func checkPasswd(_ passwd: String) -> Bool {
        //判断字符串中每个字符的ASCII码
        let pwdMin: Int = 6
        let pwdMax: Int = 16
        func checkSubChar(_ subChar : String) -> Bool {
            var charASC : Int = 0
            if let asc = UtilTools.getASCIIForChar(subChar) {
                charASC = asc
            }else{
                return true
            }
            switch charASC {
            case 97...122:
                fallthrough
            case 65...90:
                return true
            default:
                return false
            }
        }
        let passwdLength = passwd.lengthOfBytes(using: String.Encoding.utf8)
        if passwdLength >= pwdMin && passwdLength <= pwdMax {
            if let _ = Int(passwd) {
                return false
            }
            var count = 0
            for char in passwd {
                let str = String(char)
                if checkSubChar(str) {
                    count += 1
                }
            }
            if count == passwdLength {
                return false
            }
            return true
        }
        return false
    }
    
    //检测手机验证码
    //6位数字
    public class func checkMbCode(_ mobilecode: String, mbCount: Int = 6) -> Bool {
        if mobilecode.count == mbCount {
            if let _ = Int(mobilecode) {
                return true
            }
        }
        return false
    }
    
    //是否登录 true:已登录 false:没有登录
    public class func isLogin() -> Bool {
        let web_qtstr = UtilCookie.getCookieByKey("web_qtstr")
        let strArr = web_qtstr.components(separatedBy: "%253A")
        var loginStatus = "6"
        if strArr.count >= 5 {
            loginStatus = strArr[4]
        }
        if loginStatus != "6" {
            return true
        }
        return false
    }
    
    /**
     获取当前的登录方式
     */
    public class func getLoginPlatform() -> LoginPlatformType {
        let web_qtstr = UtilCookie.getCookieByKey("web_qtstr")
        let strArr = web_qtstr.components(separatedBy: "%253A")
        var loginStatus = "6"
        if strArr.count >= 5 {
            loginStatus = strArr[4]
        }
        var type = LoginPlatformType.none
        switch loginStatus {
        case "1":
            type = .mobile
        case "4":
            type = .qq
        case "5":
            type = .wechat
        default:
            type = .none
        }
        return type
    }
    
    public class func hasCookie() -> Bool {
        let web_qtstr = UtilCookie.getCookieByKey("web_qtstr")
        return !web_qtstr.isEmpty
    }
    
    public class func setCurrentLoginStatus() {
        if isLogin() {
            var str: String?
            switch getLoginPlatform() {
            case .mobile:
                str = "提示：您上一次使用手机号码登录"
            case .qq:
                str = "提示：您上一次使用QQ登录"
            case .wechat:
                str = "提示：您上一次使用微信登录"
            default:
                break
            }
            if str != nil {
                UtilTools.setUserDefaults(str!, key: "last_login_status")
            }else{
                UtilTools.removeUserDefaults("last_login_status")
            }
        }
    }
    
    public class func getLastLoginStatus() -> String? {
        if let loginStr = UtilTools.getUserDefaults("last_login_status") as? String {
            return loginStr
        }else if !(UtilTools.getUserDefaults("username") + "").isEmpty {
            return "提示：您上一次使用手机号码登录"
        }else{
            return nil
        }
    }
    
    public class func checkAppUpdate() -> Bool {
        let appVersion = getAppVersion()
        let versionNumbers = appVersion.components(separatedBy: ".")
        let lastGuideVersion = UtilTools.getUserDefaults("lastGuideVersion") + ""
        let lastNumbers = lastGuideVersion.components(separatedBy: ".")
        if versionNumbers.count == lastNumbers.count && versionNumbers.count >= 3 {
            for i in 0 ..< versionNumbers.count - 1 {
                if let num = Int(versionNumbers[i]) {
                    if let lNum = Int(lastNumbers[i]) {
                        if num > lNum {
                            return true
                        }
                    }
                }
            }
        }else{
            return true
        }
        return false
    }
    
    public class func getAppVersion() -> String {
        let bundleInfo = Bundle.main.infoDictionary
        let appVersion = bundleInfo!["CFBundleShortVersionString"] + ""
        return appVersion
    }
    
}
