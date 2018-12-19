//
//  BaseRequest.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/8.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit
import AFNetworking
import Toast

public enum ServerType {
    case base(String)
    case uc(String)
    case analyse(String)
}

public class BaseError: NSObject {
    public var msg : String?
    public var error : Error?
    public var reqTask : URLSessionTask?
    
    public required init(msg : String?, error : Error?, reqTask : URLSessionTask?) {
        self.msg = msg
        self.error = error
        self.reqTask = reqTask
    }
}

public enum RequestOutputType: Int {
    case json = 1
    case xml
    case bin
}

open class BaseRequest: NSObject {
    
    ///默认api version， 用于整体版本提升
    public static var glApiVersion: String = "1.0"
    ///默认服务器地址, 相对地址时不可为空
    public static var glBaseServerUrl: String = ""
    public let requestManager : BaseHttpSessionManager = BaseHttpSessionManager.sharedOperationManager
    ///请求完成的回调
    open var completionBlock: ((BaseModel) -> Void)?
    ///请求失败的回调
    open var failureBlock: ((BaseError) -> Void)?
    ///请求方式get post
    open var isPostMethod: Bool = false
    ///请求超时时长
    open var timeout: TimeInterval = 20.0
    ///请求所有参数，不建议直接操作，建议用addReqParam方法添加请求参数
    public var requestParamDic: Dictionary<String, Any>?
    ///请求通用参数，可携带设备信息等通用信息
    public var requestCommonDic: Dictionary<String, Any>?
    private var outputType: RequestOutputType = .json
    private var postFileParaDic: Dictionary<String, Any>?    //需要post上传的文件字典
    private var httpHeader: Dictionary<String , String>? = nil   //http头

    /**
     重写方法->相对链接服务器根目录类型
     */
    open func getServerType() -> ServerType {
        return .base(BaseRequest.glBaseServerUrl)
    }
    
    /**
     重写方法->相对链接url
     */
    open func getRelativeUrl() -> String? {
        return nil
    }
    
    /**
     重写方法->绝对链接url
     */
    open func getAbsoluteUrl() -> String? {
        return nil
    }
    
    /**
     重写方法->此接口的api version
     */
    open func getRequestVersion() -> String {
        return BaseRequest.glApiVersion
    }
    
    /**
     重写方法->请求时是否需要弹出toast
     */
    open func needRequestToast() -> Bool {
        return true
    }
    
    /**
     重写方法->请求时是否需要将上一次的相同请求取消
     */
    open func needCancelSameReq() -> Bool {
        return true
    }
    
    /**
     重写方法->请求完成数据解析，json模式
     - parameter responseDic: 返回的json对象
     - returns: BaseModel对象
     */
    open func decodeJsonRequestData(responseDic : Dictionary<String,Any>?) -> BaseModel? {
        guard responseDic != nil else {
            return nil
        }
        let baseData : BaseModel = BaseModel.mj_object(withKeyValues: responseDic)
        return baseData
    }
    
    /**
     重写方法->请求完成数据解析，bin模式
     - parameter data: 返回的Data数据
     - returns: BaseModel对象
     */
    open func decodeBinRequestData(_ data : Any?) -> BaseModel? {
        preconditionFailure("The method 'decodeBinRequestData' must be overridden")
    }
    
    /**
     重写方法->请求完成数据解析，xml模式
     - parameter responseDic: 返回的xml数据
     - returns: BaseModel对象
     */
    open func decodeXmlRequestData(_ data : Any?) -> BaseModel? {
        preconditionFailure("The method 'decodeXmlRequestData' must be overridden")
    }
    
    /**
     调用方法->设置请求数据返回的输出方式
     - paramter type: 输出类型 json xml bin
     - returns: 无
     */
    public func setOutputType(type: RequestOutputType) {
        self.outputType = type
    }
    
    /**
     调用方法->为请求增加参数。签名为后续做准备
     - parameter key:    参数键
     - parameter value:  参数值
     - parameter isSign: 该参数是否参与签名算法
     - returns: 无
     */
    public func addReqParam(_ param: Dictionary<String,Any>, isSign :Bool) {
        if requestParamDic == nil {
            requestParamDic = param
        }else{
            for (k, v) in param {
                requestParamDic?.updateValue(v, forKey: k)
            }
        }
        if isSign {
            //TODO: 签名算法
        }
    }
    
    /**
     调用方法->为请求增加参数。签名为后续做准备
     - parameter key:    参数键
     - parameter value:  参数值
     - parameter isSign: 该参数是否参与签名算法
     - returns: 无
     */
    public func addReqParam(key : String, value : String, isSign :Bool) {
        if requestParamDic == nil {
            requestParamDic = Dictionary<String,Any>()
        }
        requestParamDic![key] = value
        if isSign {
            //TODO: 签名算法
        }
    }
    
    /**
     调用方法->为请求增加http请求头。
     - parameter header: 请求头集合字典
     - returns: 无
     */
    public func addHttpHeader(header : Dictionary<String , String>?) {
        self.httpHeader = header
    }
    
    /**
     调用方法->上传文件，post文件地址
     - parameter key:   文件参数key
     - parameter value: 文件值，绝对路径
     */
    public func addPostFileURL(key: String ,value: String, isSign : Bool) {
        if postFileParaDic == nil {
            self.postFileParaDic = Dictionary<String,Any>()
        }
        self.postFileParaDic![key] = value
        if isSign {
            //TODO: 签名算法
        }
    }
    /**
     调用方法->上传文件，post文件元数据
     - parameter key:   文件参数key
     - parameter value: 文件二进制数据
     */
    public func addPostFileData(key : String ,value : Data, isSign : Bool) {
        if postFileParaDic == nil {
            self.postFileParaDic = Dictionary<String,Any>()
        }
        self.postFileParaDic![key] = value
        if isSign {
            //TODO: 签名算法
        }
    }
    
    /**
     调用方法->发起请求
     - parameter success: 请求完成的回调
     - parameter failure: 请求失败的回调
     */
    @discardableResult
    public func doRequest() -> URLSessionDataTask? {
        var reqUrl = ""
        if let abs = getAbsoluteUrl() {
            reqUrl = abs
        }else if let rel = getRelatedUrl() {
            reqUrl = rel
        }else{
            return nil
        }
        //StatusBar请求状态
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        UIApplication.shared.keyWindow?.hideToastActivity()
        
        if needRequestToast() {
            UIApplication.shared.keyWindow?.makeToastActivity(CSToastPositionCenter)
        }
        
        let requestSuccess =
        {
            (operation : URLSessionTask, responseObject : Any?) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            var baseData : BaseModel?
            switch self.outputType {
            case .json:
                baseData = self.decodeJsonRequestData(responseDic: responseObject as? Dictionary<String,Any>)
                if baseData != nil {
                    //处理公共数据
                }else{
                }
                break
            case .xml:
                baseData = self.decodeXmlRequestData(responseObject)
                if baseData != nil{
                    //处理公共数据
                }
                break
            case .bin:
                baseData = self.decodeBinRequestData(responseObject)
                if baseData != nil{
                    //处理公共数据
                }
                break
            }
            
            if baseData != nil
            {
                self.completionBlock?(baseData!)
            }
            UIApplication.shared.keyWindow?.hideToastActivity()
        }
        
        let requestFailure =
        {
            (operation :URLSessionDataTask?, erro :Error) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if self.failureBlock != nil
            {
                var resError : BaseError?
                
                if erro._code == 404 {
                    resError = BaseError(msg: "服务器不可用", error: erro, reqTask : operation)
                }else if erro._code != -999 {
                    resError = BaseError(msg: "网络异常(code:\(erro._code))", error: erro, reqTask : operation)
                }
                if resError != nil {
                    self.failureBlock?(resError!)
                }
            }
            UIApplication.shared.keyWindow?.hideToastActivity()
        }
        
        self.prepareCommonParameters()
        
        if self.requestParamDic == nil {
            self.requestParamDic = Dictionary<String,Any>()
        }
        
        requestManager.requestSerializer.timeoutInterval = timeout
        
        self.perpareCommonHeader()
        
        if httpHeader != nil {
            for (key , value) in httpHeader! {
                requestManager.requestSerializer.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if isPostMethod {
            //服务处理公共参数在一个公共区，在做doget，dopost之前处理的。需要client提供一个不分httpmethod的url
            let postUrl = self.getUrlWithParameter(reqUrl, parameters: requestCommonDic!)
            if postFileParaDic != nil && postFileParaDic!.count > 0 {
                return requestManager.post(postUrl!, parameters: self.requestParamDic, constructingBodyWith: { (formData) in
                    for (_, value) in self.postFileParaDic! {
                        if value is String {
                            do {
                                try formData.appendPart(withFileURL: NSURL.fileURL(withPath: value as! String), name: "file")
                            }catch{
                            }
                        }else if value is Data {
                            formData.appendPart(withForm: value as! Data, name: "file")
                        }else{
                            preconditionFailure("post文件只支持全路径和NSData两种类型")
                        }
                    }
                    }, progress: nil ,success: requestSuccess, failure: requestFailure)
            }else{
                return requestManager.post(postUrl!, parameters: self.requestParamDic, progress: nil ,success: requestSuccess, failure: requestFailure)
            }
        }else{
            if requestCommonDic != nil {
                for key: String in self.requestCommonDic!.keys {
                    self.requestParamDic![key] = self.requestCommonDic![key]
                }
            }
            return requestManager.get(reqUrl, parameters: requestParamDic, progress: nil ,success: requestSuccess, failure: requestFailure)
        }
    }
    
    internal func getRelatedUrl() -> String? {
        if let rel = getRelativeUrl() {
            var serverUrl = ""
            switch getServerType() {
            case .base(let url):
                serverUrl = url
            case .uc(let url):
                serverUrl = url
            case .analyse(let url):
                serverUrl = url
            }
            if !serverUrl.isEmpty {
                return serverUrl + rel
            }
        }
        return nil
    }
    
    ///parameter中的<key:value>会update url中自带的<key,value>
    private func getUrlWithParameter(_ url : String, parameters : Dictionary<String, Any>) -> String? {
        var result : String? = nil
        if url.isEmpty {
            result = nil
        }
        if parameters.isEmpty {
            result = url
        }else{
            let range0 = url.range(of: "?")
            var tmpUrl0 = url
            if range0 == nil {
                tmpUrl0  = tmpUrl0 + "?"
            }
            let range = tmpUrl0.range(of: "?")
            if range!.upperBound == tmpUrl0.endIndex {
                var tmpUrl  = tmpUrl0
                for (key, value) in parameters {
                    let valueStr    = value + ""
                    tmpUrl += "\(key)=\(valueStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlUserAllowed) + "")&"
                }
                result = String(tmpUrl[..<tmpUrl.index(tmpUrl.endIndex, offsetBy: -1)])
            }else{
                if range!.upperBound < tmpUrl0.endIndex {
                    let range1 = tmpUrl0.range(of: "&")
                    if range1 != nil {
                        if range1!.upperBound == tmpUrl0.endIndex {
                            var tmpUrl = tmpUrl0
                            for (key, value) in parameters {
                                let valueStr = value + ""
                                tmpUrl += "\(key)=\(String(describing: valueStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)))&"
                            }
                            result = String(tmpUrl[..<tmpUrl.index(tmpUrl.endIndex, offsetBy: -1)])
                        }else{
                            var tmpUrl  = tmpUrl0 + "&"
                            for (key, value) in parameters {
                                let valueStr = value + ""
                                tmpUrl += "\(key)=\(String(describing: valueStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)))&"
                            }
                            result  = String(tmpUrl[..<tmpUrl.index(tmpUrl.endIndex, offsetBy: -1)])
                        }
                    }else{
                        var tmpUrl  = tmpUrl0 + "&"
                        for (key, value) in parameters {
                            let valueStr = value + ""
                            tmpUrl += "\(key)=\(String(describing: valueStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)))&"
                        }
                        result = String(tmpUrl[..<tmpUrl.index(tmpUrl.endIndex, offsetBy: -1)])
                    }
                }else{
                    result = tmpUrl0
                }
            }
        }
        return result
    }
    
    /**
     通用参数准备，设备id，设备平台,发布渠道等等信息
     */
    private func prepareCommonParameters() -> Void {
        if requestCommonDic == nil {
            self.requestCommonDic = Dictionary<String, String>()
        }
        self.requestCommonDic!["apiversion"] = self.getRequestVersion()
    }
    
    private func perpareCommonHeader() -> Void {
        let value = getUAStr()
        let dic = ["User-Agent" : value]
        self.addHttpHeader(header: dic)
    }
}
