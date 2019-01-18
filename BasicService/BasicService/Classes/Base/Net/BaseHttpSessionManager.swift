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
        securityPolicy.allowInvalidCertificates = true //是否信任非法证书https下false
        //获取服务器证书 "openssl s_client -connect www.demodomain.com:443 </dev/null 2>/dev/null | openssl x509 -outform DER > https.cer"
        //if let cerPath = Bundle.main.path(forResource: "https", ofType: "cer"), let uri = URL(string: cerPath) {
        //  do {
        //      let certData = try Data(contentsOf: uri)
        //      securityPolicy.pinnedCertificates = [certData]
        //  }catch{
        //  }
        //} //指定证书，不指定不需要
        //securityPolicy.sslPinningMode = .certificate //开启证书验证
        //securityPolicy.validatesDomainName = true
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
