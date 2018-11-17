//
//  Behavior.swift
//  quchaogu
//
//  Created by focus on 16/5/25.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

public let DOMAIN = "new_subject"

public class Behavior: NSObject {
    public static var domain : String {
        get {
            return DOMAIN
        }
    }
    
    public static var behaviorRefer: String? {
        set {
            _refer = newValue
        }
        
        get {
            let re = _refer
            _refer = nil
            return re
        }
    }
    
    public static var behaviorParam: Dictionary<String, String>? {
        set {
            _param = newValue
        }
        get {
            let p = _param
            _param = nil
            return p
        }
    }
    
    static private var _refer: String?
    static private var _param: Dictionary<String, String>?
    
    public class func eventReport(_ eventId : String = "" ,isPage : Bool = false, from : String = "-", to : String = "-") {
        var dic : Dictionary<String, String>    = Dictionary<String, String>()
        dic["uuid"] = UtilTools.getAnalyseUUID()
        dic["sid"] = UtilTools.getSessionId()
        dic["chid"] = UtilTools.getChid()
        dic["domain"] = domain
        
        var fromStr: String = "-"
        var toStr: String = "-"
        if from.count > 1 || to.count > 1 {
            if isPage {
                if let r = behaviorRefer {
                    fromStr = r
                }else{
                    fromStr = from
                }
            }else{
                fromStr = from
            }
            
            toStr       = to
        }else{
            if let vc = UIApplication.appTopViewController() as? BaseViewController {
                if isPage {
                    if let r = behaviorRefer {
                        fromStr = r
                    }else{
                        fromStr = vc.getFrom()
                    }
                }else{
                    fromStr = vc.getFrom()
                }
                toStr = vc.getTo()
            }
        }
        dic["url"] = toStr
        dic["refer"] = fromStr
        if let p = behaviorParam {
            for (k, v) in p {
                dic.updateValue(v, forKey: k)
            }
        }
        var request: BaseRequest?
        if isPage{
            request = BehaviorPRequest(paraDic: dic)
        }else{
            dic["elog"] = eventId
            request = BehaviorERequest(paraDic: dic)
        }
        request!.doRequest()
    }
    
    public static var currentPage: String = ""
    public class func eventReportByUrl(_ eventId : String = "" ,isPage : Bool = false, fromClass : AnyClass = UIViewController.self) {
        var dic : Dictionary<String, String>    = Dictionary<String, String>()
        dic["uuid"] = UtilTools.getAnalyseUUID()
        dic["sid"] = UtilTools.getSessionId()
        dic["chid"] = UtilTools.getChid()
        dic["domain"]   = domain
        dic["url"] = currentPage
        if fromClass !== UIViewController.self {
            dic["refer"] = fromClass + ""
        }else{
            dic["refer"] = "-"
        }
        var request: BaseRequest?
        if isPage {
            request = BehaviorPRequest(paraDic: dic)
        }else{
            dic["elog"] = eventId
            request = BehaviorERequest(paraDic: dic)
        }
        request!.doRequest()
    }
}
