//
//  BaseViewModel.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/9.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

class RequestTaskData {
    var taskIdentifier: Int?
    var taskUrl: String?
    var task: URLSessionDataTask?
}

@objc public protocol ViewModelProtocol: NSObjectProtocol {
    @objc optional var tableView: UITableView? {get set}
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
    public weak var delegate: ViewModelProtocol?
    private lazy var tasks: Array<RequestTaskData> = Array()
    
    required public init(delegate: ViewModelProtocol?) {
        super.init()
        self.delegate = delegate
    }
    
    open func updateReqParam(_ param: Dictionary<String, Any>) {
        //TODO: 更新参数后逻辑
    }
    
    @discardableResult
    public func doRequest(_ request : BaseRequest, completion : @escaping ((BaseModel?) -> Void), failure : @escaping ((BaseError?) -> Void)) -> Int {
        let url = request.getAbsoluteUrl() ?? request.getRelatedUrl() ?? ""
        request.completionBlock = {[weak self] model in
            self?.removeTaskWithUrl(url)
            completion(model)
        }
        request.failureBlock = {[weak self] error in
            self?.removeTaskWithUrl(url)
            failure(error)
        }
        let task = request.doRequest()
        if task != nil {
            var exist: Bool = false
            for rtd in tasks {
                if rtd.taskUrl == url {
                    if request.needCancelSameReq() {
                        rtd.task?.cancel()
                    }
                    rtd.task = task
                    rtd.taskIdentifier = task?.taskIdentifier
                    exist = true
                }
            }
            if !exist {
                let rtd = RequestTaskData()
                rtd.taskIdentifier = task?.taskIdentifier
                rtd.taskUrl = url
                rtd.task = task
                tasks.append(rtd)
            }
        }
        return task?.taskIdentifier ?? 0
    }
    
    public func cancelRequest(id: Int?) {
        _ = tasks.map { (id == nil || $0.taskIdentifier == id) ? $0.task?.cancel() : () }
    }

    public func suspendTask(id: Int?) {
        _ = tasks.map { (id == nil || $0.taskIdentifier == id) ? $0.task?.suspend() : () }
    }

    public func resumeTask(id: Int?) {
        _ = tasks.map { (id == nil || $0.taskIdentifier == id) ? $0.task?.resume() : () }
    }
    
    private func removeTaskWithUrl(_ url: String) {
        var list = Array<RequestTaskData>()
        for rtd in tasks {
            if rtd.taskUrl != url {
                list.append(rtd)
            }
        }
        tasks = list
    }
}
