//
//  BaseModel.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/9.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit
import MJExtension

open class BaseModel: NSObject {
    
    @objc public var resultCode: NSNumber?
    @objc public var errorMsg: String?
    @objc public var resultData: AnyObject?
    
    override open class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        let subDic = ["resultCode" : "code", "errorMsg" : "msg", "resultData" : "data"]
        return subDic
    }
}
