//
//  UtilTool.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/9.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

public class UtilTools {
    
    //ASCII码获取
    public class func getASCIIForChar (_ char : String) -> Int? {
        var str = ""
        for cu in char.utf8 {
            str += String(cu)
        }
        return Int(str)
    }
    
    //获取十六进制颜色值
    public class func colorWithHexString (_ rgba: String) -> UIColor {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        if rgba.hasPrefix("#") {
            let index = rgba.index(rgba.startIndex, offsetBy: 1)
            let hex = rgba[index...]
            let scanner = Scanner(string: String(hex))
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                switch String(hex).count {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                   break
                }
            }
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public class func getDeviceModel() -> String {
        let name = UIDevice.current.modelName
        return name
    }
    
    public class func getAppDelegate() -> UIApplication? {
        return UIApplication.shared.delegate as? UIApplication
    }
    
    public class func getSessionId(needNew tag : Bool = false) -> String {
        if !tag {
            if let sessionId = getUserDefaults("sessionId") as? String {
                return sessionId
            }
        }
        let sessionId = getSessionOrChildId()
        setUserDefaults(sessionId, key: "sessionId")
        return sessionId
    }
    
    public class func getChid(needNew tag : Bool = false) -> String {
        if !tag {
            if let chId = getUserDefaults("chId") as? String {
                return chId
            }
        }
        let chId = getSessionOrChildId()
        setUserDefaults(chId, key: "chId")
        return chId
    }
    
    public class func getAnalyseUUID() -> String {
        if let analyseUUID = getUserDefaults("analyseUUID") as? String {
            return analyseUUID
        }
        let date = Date()
        let time = date.timeIntervalSince1970
        var timeStr = String(format: "%.4f", time)
        timeStr = timeStr.replacingOccurrences(of: ".", with: "")
        let str = String((timeStr + "\(Int64(arc4random_uniform(9) + 1))").reversed())
        let rm = Int64(arc4random_uniform(89999999) + 10000000)
        let result = "\(Int64(str)! + rm)\(rm)"
        setUserDefaults(result, key: "analyseUUID")
        return result
    }
    
    //获取设备唯一号 （UUID + TOKEN）
    public class func getUniqueDeviceId() -> String {
        let uuid = self.getUUID()
        let token = self.getDeviceToken()
        let deviceId = "\(token)_" + uuid
        return deviceId
    }
    
    public class func getUUID() -> String {
        if let uuid = getUserDefaults("uuid") as? String {
            return uuid
        }
        let puuid = CFUUIDCreate(nil)
        let uuidStr = CFUUIDCreateString(nil, puuid)
        let result = String(CFStringCreateCopy(nil, uuidStr))
        setUserDefaults(result, key: "uuid")
        return result
    }
    
    public class func setDeviceToken(_ str: String) {
        setUserDefaults(str, key: "deviceToken")
    }
    
    public class func getDeviceToken() -> String {
        var token = ""
        if let t = getUserDefaults("deviceToken") as? String {
            token = t
        }
        return token
    }
    
    //日志分析中的 sessionId 和 chid 的算法
    public class func getSessionOrChildId() -> String {
        let date = Date()
        let time = date.timeIntervalSince1970
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let referDate = formatter.date(from: formatter.string(from: date))
        let referTime = referDate!.timeIntervalSince1970
        let targetId = "\(Int64(time - referTime) * 1000 + (Int64(arc4random_uniform(8999))+1000))"
        return targetId
    }
    
    //获取用户偏好信息
    public class func getUserDefaults(_ key : String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    //设置用户偏好信息
    public class func setUserDefaults(_ obj : Any , key : String) {
        UserDefaults.standard.set(obj, forKey: key)
        UserDefaults.standard.synchronize()
    }
    //删除某条偏好信息
    public class func removeUserDefaults(_ key : String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    ///拼接url
    public class func getUrlWithParameter(_ url : String, parameters : Dictionary<String, Any>) -> String? {
        var result : String? = nil
        if url.isEmpty {
            result = nil
        }
        if parameters.count == 0 {
            result = url
        }
        let range0 = url.range(of: "?")
        
        var tmpUrl0 = url
        if range0 == nil {
            tmpUrl0 = tmpUrl0 + "?"
        }
        
        let range = tmpUrl0.range(of: "?")
        
        if range!.upperBound == tmpUrl0.endIndex {
            var tmpUrl  = tmpUrl0
            for (key, value) in parameters {
                let vEncoded = (value + "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? ""
                let v = String(describing: vEncoded)
                tmpUrl += "\(key)=\(v)&"
            }
            result = String(tmpUrl[..<tmpUrl.index(tmpUrl.endIndex, offsetBy: -1)])
        }else{
            if range!.upperBound < tmpUrl0.endIndex {
                let range1 = tmpUrl0.range(of: "&")
                if range1 != nil {
                    if range1!.upperBound == tmpUrl0.endIndex {
                        var tmpUrl  = tmpUrl0
                        for (key, value) in parameters {
                            let vEncoded = (value + "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? ""
                            let v = String(describing: vEncoded)
                            tmpUrl += "\(key)=\(v)&"
                        }
                        result = String(tmpUrl[..<tmpUrl.index(tmpUrl.endIndex, offsetBy: -1)])
                    }else{
                        var tmpUrl  = tmpUrl0 + "&"
                        for (key, value) in parameters {
                            let vEncoded = (value + "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? ""
                            let v = String(describing: vEncoded)
                            tmpUrl += "\(key)=\(v)&"
                        }
                        result = String(tmpUrl[..<tmpUrl.index(tmpUrl.endIndex, offsetBy: -1)])
                    }
                }else{
                    var tmpUrl  = tmpUrl0 + "&"
                    for (key, value) in parameters {
                        let vEncoded = (value + "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? ""
                        let v = String(describing: vEncoded)
                        tmpUrl += "\(key)=\(v)&"
                    }
                    result = String(tmpUrl[..<tmpUrl.index(tmpUrl.endIndex, offsetBy: -1)])
                }
            }else{
                result = tmpUrl0
            }
        }
        return result
    }
}
