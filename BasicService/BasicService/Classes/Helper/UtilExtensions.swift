//
//  UtilExtension.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/9.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit
import CommonCrypto

public extension String {
    //MD5加密
    public func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: digestLen)
        return String(hash)
    }
    
    //正则表达式
    public func isMatch(_ regex: String, options: NSRegularExpression.Options = .caseInsensitive) -> Bool {
        guard !regex.isEmpty else {
            return false
        }
        var error: NSError?
        var exp: NSRegularExpression?
        do {
            exp = try NSRegularExpression(pattern: regex, options: options)
        } catch let error1 as NSError {
            error = error1
            exp = nil
        }
        if let error = error {
            logPrint(error.description)
        }
        let matchCount = exp?.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matchCount > 0
    }
    
    public func matchs(_ regex: String, options: NSRegularExpression.Options = .caseInsensitive) -> [NSRange] {
        guard !regex.isEmpty else {
            return []
        }
        var error: NSError?
        var exp: NSRegularExpression?
        do {
            exp = try NSRegularExpression(pattern: regex, options: options)
        } catch let error1 as NSError {
            error = error1
            exp = nil
        }
        if let error = error {
            logPrint(error.description)
        }
        if let range = exp?.matches(in: self, range: NSMakeRange(0, self.count)) {
            var ranges = [NSRange]()
            for r in range {
                ranges.append(r.range)
            }
            return ranges
        }else{
            return []
        }
    }
    
    public func firstMatch(_ regex: String, options: NSRegularExpression.Options = .caseInsensitive) -> NSRange? {
        guard !regex.isEmpty else {
            return nil
        }
        var error: NSError?
        var exp: NSRegularExpression?
        do {
            exp = try NSRegularExpression(pattern: regex, options: options)
        } catch let error1 as NSError {
            error = error1
            exp = nil
        }
        if let error = error {
            logPrint(error.description)
        }
        if let range = exp?.rangeOfFirstMatch(in: self, options: [], range: NSMakeRange(0, self.count)), range.length > 0 {
            return range
        }else{
            return nil
        }
    }
    
    //给子串添加属性
    public func addAttributeToSubString(_ subString : String , withAttributes attributes : [NSAttributedString.Key : Any], afterStr: String? = nil) -> NSAttributedString {
        let mutableAttri    = NSMutableAttributedString(string: self)
        if afterStr != nil && !afterStr!.isEmpty {
            let afterRange = (self as NSString).range(of: afterStr!)
            let tarStr = (self as NSString).substring(from: afterRange.location + afterRange.length) as NSString
            var tarRange = tarStr.range(of: subString)
            tarRange.location += afterRange.location + afterRange.length
            mutableAttri.addAttributes(attributes, range: tarRange)
        }else{
            mutableAttri.addAttributes(attributes, range: (self as NSString).range(of: subString))
        }
        return mutableAttri
    }
    
    //计算字符串的宽高
    public func sizeWith(attributes: [NSAttributedString.Key: Any], size: CGSize = CGSize(width:999, height: 999)) -> CGSize {
        return NSString(string: self).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
    
    ///截取字符串特定范围的子串
    public subscript(r: Range<Int>) -> String {
        set {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            let strRange = Range(uncheckedBounds: (startIndex, endIndex))
            self.replaceSubrange(strRange, with: newValue)
        }
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[Range(uncheckedBounds: (startIndex, endIndex))])
        }
    }
    
}

public extension Dictionary {
    public func getNumberForKey(_ key : Key) -> NSNumber {
        if let value = Double(self[key] + "") {
            return NSNumber(value: value as Double)
        }else{
            return NSNumber(value: 0 as Double)
        }
    }
    
    public func getJSONString() -> String {
        if (!JSONSerialization.isValidJSONObject(self)) {
            return ""
        }
        if let data = try? JSONSerialization.data(withJSONObject: self, options: []), let JSONString = String(data:data, encoding: String.Encoding.utf8) {
            return JSONString
        }else{
            return ""
        }
    }
}

public extension UIFont {
    
    public class func normalFontOfSize(_ fontSize : CGFloat , needScale : Bool = false) -> UIFont {
        let scale : CGFloat = IS_SMALL_SCREEN && needScale ? SCALE_WIDTH_6 : 1
        return UIFont.systemFont(ofSize: fontSize * scale)
    }
    
    public class func boldFontOfSize(_ fontSize : CGFloat , needScale : Bool = false, weight: CGFloat = 0.2) -> UIFont {
        let scale : CGFloat = IS_SMALL_SCREEN && needScale ? SCALE_WIDTH_6 : 1
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: fontSize * scale, weight: UIFont.Weight(rawValue: weight))
        } else {
            return UIFont.boldSystemFont(ofSize: fontSize * scale)
        }
    }
}

public extension UIDevice {
    
    public var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,3":                               return "iPhone SE"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

public extension UIButton {
    
    /**
     按钮图片及文字上下布局
     - parameter image: 图片
     - parameter title: 文字
     - parameter space: 间隔
     */
    public func setVerticalImage(_ image: UIImage, title: String, space: CGFloat) {
        self.setImage(image, for: .normal)
        self.setTitle(title, for: .normal)
        let imageSize = image.size
        let textSize = title.sizeWith(attributes: [NSAttributedString.Key.font : self.titleLabel!.font])
        let totalHeight = imageSize.height + space + textSize.height
        let totalWidth = imageSize.width + textSize.width
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -(totalWidth - imageSize.width))
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(totalWidth - textSize.width), bottom: -(totalHeight - textSize.height), right: 0)
    }
    
    /**
     按钮图片在文字右侧布局
     - parameter image: 图片
     - parameter title: 文字
     - parameter space: 间隔
     */
    public func setHorizontalImage(_ image: UIImage, title: String, space: CGFloat) {
        self.setImage(image, for: .normal)
        self.setTitle(title, for: .normal)
        let imageSize = image.size
        let textSize = title.sizeWith(attributes: [NSAttributedString.Key.font : self.titleLabel!.font])
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: textSize.width + space / 2, bottom: 0, right: -textSize.width - space / 2)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width - space / 2, bottom: 0, right: imageSize.width + space / 2)
    }
}

public extension UIApplication {
    public class func appTopViewController(root: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navi = root as? UINavigationController {
            return appTopViewController(root: navi.visibleViewController)
        }
        if let tabBar = root as? UITabBarController {
            if let selected = tabBar.selectedViewController {
                return appTopViewController(root: selected)
            }
        }
        if let presented = root?.presentedViewController {
            return appTopViewController(root: presented)
        }
        return root
    }
}
