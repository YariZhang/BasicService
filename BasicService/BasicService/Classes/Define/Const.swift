//
//  Const.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/9.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit
import QCGURLRouter
import Toast

public typealias DxwDic = Dictionary<String, Any>
///是否是iPhoneX
public let CURRENT_SIZE    = UIScreen.main.currentMode?.size
public let IS_IPHONE_10    = CURRENT_SIZE == CGSize(width: 1125, height: 2436)
public let IS_IPHONE_XR    = CURRENT_SIZE == CGSize(width:750,height:1624)
public let IS_IPHONE_XSM   = CURRENT_SIZE == CGSize(width:1242,height:2688)
public let IS_IPHONE_X     = IS_IPHONE_10 || IS_IPHONE_XR || IS_IPHONE_XSM
///小屏幕手机（4）
public let IS_SMALL_SCREEN = UIScreen.main.bounds.width < 375
///navi顶部的高度
public let TOP_AREA_HEIGHT: CGFloat = IS_IPHONE_X ? 88 : 64
public let SCALE_WIDTH_6 = UIScreen.main.bounds.width / 375
public let SCALE_HEIGHT_6 = UIScreen.main.bounds.height / 667
//当前屏幕宽
public let SCREEN_WIDTH = UIScreen.main.bounds.width
//当前屏幕高
public let SCREEN_HEIGHT = UIScreen.main.bounds.height

public func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

public func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

//Any转String
public func +(left : Any?, right : String) -> String {
    return left == nil ? "" : "\(left!)" + right
}

//log打印
public func logPrint<T>(_ message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line) {
    #if !RELEASE
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

@discardableResult
public func jumpPageNative(param: DxwDic, callBack: (() -> Void)? = nil) -> Bool {
    let url = param["url"] + ""
    let para = param["param"] as? Dictionary<String, Any>
    if let uri = URL(string: url), !QCGURLRouter.shareInstance.route(withUrl: uri, param: para) {
        UIApplication.appTopViewController()?.view.makeToast("无效跳转", duration: 3, position: CSToastPositionBottom)
        return false
    }else{
        callBack?()
        return true
    }
}

public func jumpPage(info : Dictionary<String , Any>, isPush : Bool = false) {
    let action = info["action"] as! Dictionary<String , Any>
    let url = action["url"] + ""
    let para = action["para"] as? Dictionary<String, Any>
    
    let backUrl = action["back_url"] as? String
    let backPara = action["back_para"] as? Dictionary<String, Any>
    
    if isPush {
        let id      = action["id"] + ""
        if !id.isEmpty { //通知服务器推送被阅读
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                //EventService.pushReadBy(id: id)
            })
        }
    }
    if backUrl != nil && backUrl!.count > 0 {
        if jumpPageNative(param: ["url": backUrl!, "param": backPara as Any]) {
            jumpPageNative(param: ["url": url, "param": para as Any])
        }
    }else{
        jumpPageNative(param: ["url": url, "param": para as Any])
    }
}
