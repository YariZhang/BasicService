//
//  BaseViewModel.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/9.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

@objc public protocol ViewModelProtocol: NSObjectProtocol {
    var viewModel: BaseViewModel! {set get}
    @objc optional func updateUI()
}

open class BaseViewModel: NSObject {
    
    public weak var view: UIView? {
        if let control = delegate as? UIViewController {
            return control.view
        }else if let v = delegate as? UIView {
            return v
        }else{
            return nil
        }
    }
    
    public weak var controller: BaseViewController? {
        if let control = delegate as? BaseViewController {
            return control
        }else{
            return nil
        }
    }
    
    ///页面请求参数
    open var reqParam: Dictionary<String, Any>? {
        didSet {
            if reqParam != nil {
                updateReqParam(reqParam!)
            }
        }
    }
    
    ///代理
    private weak var delegate: ViewModelProtocol?
    private var task: URLSessionDataTask?
    
    required public init(delegate: ViewModelProtocol?) {
        super.init()
        self.delegate = delegate
    }
    
    public func updateReqParam(_ param: Dictionary<String, Any>) {
        //TODO: 更新参数后逻辑
    }
    
    public func doRequest(_ request : BaseRequest, completion : @escaping ((BaseModel?) -> Void), failure : @escaping ((BaseError?) -> Void)) {
        request.completionBlock = completion
        request.failureBlock = failure
        task = request.doRequest()
    }
    
    public func cancelRequest() {
        task?.cancel()
    }
    
    public func suspendTask() {
        task?.suspend()
    }
    
    public func resumeTask() {
        task?.resume()
    }
}
