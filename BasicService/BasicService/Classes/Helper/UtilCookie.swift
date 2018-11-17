//
//  UtilCookie.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/6/21.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

class UtilCookie: NSObject {

    //加载Cookie
    class func loadCookie() {
        let userData = UserDefaults()
        let cookiesData = userData.object(forKey: "cookies") as? Data
        if cookiesData != nil {
            var cookies : Array<HTTPCookie> = Array()
            if #available(iOS 12.0, *) {
                do {
                    cookies = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cookiesData!) as? Array<HTTPCookie> ?? Array()
                }catch{
                }
            }else{
                cookies = NSKeyedUnarchiver.unarchiveObject(with: cookiesData!) as? Array<HTTPCookie> ?? Array()
            }
            for cookie: HTTPCookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    //删除Cookie
    class func logout() {
        let cookies : Array? = HTTPCookieStorage.shared.cookies
        for c in cookies! {
            let cookie = c
            let cookieName = cookie.name as String
            if cookieName == "web_qtstr" {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        saveCookie()
    }
    //保存Cookie
    class func saveCookie() {
        guard let cookies = HTTPCookieStorage.shared.cookies else {
            return
        }
        var cookiesData: Any?
        if #available(iOS 12.0, *) {
            do {
                cookiesData = try NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
            }catch{
            }
        }else{
            cookiesData = NSKeyedArchiver.archivedData(withRootObject: cookies)
        }
        
        if cookiesData != nil {
            let userData = UserDefaults()
            userData.set(cookiesData!, forKey: "cookies")
            userData.synchronize()
        }
    }
    //获取Cookie
    class func getCookieByKey(_ key:String) -> String {
        let cookies : NSArray? = HTTPCookieStorage.shared.cookies as NSArray?
        if cookies == nil {
            return ""
        }
        for c in cookies! {
            let cookie = c as! HTTPCookie
            let cookieName = cookie.name as String
            if cookieName == key && cookie.value != "deleted" {
                return cookie.value as String
            }
        }
        return ""
    }
    
}
