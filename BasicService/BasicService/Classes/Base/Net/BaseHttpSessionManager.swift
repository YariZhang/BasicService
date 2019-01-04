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
        
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        securityPolicy.validatesDomainName = false
        securityPolicy.allowInvalidCertificates = true
        manager.requestSerializer.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        manager.securityPolicy = securityPolicy
        manager.responseSerializer.acceptableContentTypes = ["application/json",
                                                             "text/json",
                                                             "text/javascript",
                                                             "text/html",
                                                             "text/plain"]
        Inner.instance = manager
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
