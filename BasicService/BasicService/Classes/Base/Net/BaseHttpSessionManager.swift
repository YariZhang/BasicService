//
//  BaseRequest.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/8.
//  Copyright © 2018年 zhangyr. All rights reserved.
//
import AFNetworking

public class BaseHttpSessionManager: AFHTTPSessionManager {
    public static var __once: () = {
            let manager = BaseHttpSessionManager()
            Inner.instance = manager
            let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
            securityPolicy.validatesDomainName = false
            securityPolicy.allowInvalidCertificates = true
            manager.requestSerializer.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
            Inner.instance?.securityPolicy = securityPolicy
        }()
    
    public class var sharedOperationManager: BaseHttpSessionManager {
        _ = BaseHttpSessionManager.__once
        return Inner.instance!
    }
    
    public struct Inner {
        static var instance: BaseHttpSessionManager?
        static var token: Int = 0
    }
}
