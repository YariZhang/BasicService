//
//  BaseViewController.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/9.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit
import RxSwift
import QCGURLRouter

open class BaseViewController: UIViewController, UIGestureRecognizerDelegate, ViewModelProtocol, QCGURLReceiver {
    
    public required init(parameters: Dictionary<String, Any>? = nil) {
        super.init(nibName: nil, bundle: nil)
        param = parameters
        viewModel = getViewModelType().init(delegate: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static var isTabChanged: Bool = false
    open var isTabVc: Bool = false
    open var param : Dictionary<String, Any>? {
        didSet {
            referDic = param
            viewModel.reqParam = param
        }
    }
    public var baseBgView  : UIView!
    public var disposeBag = DisposeBag()
    open var backgroundColor: UIColor? {
        set {
            self.view.backgroundColor = backgroundColor
            baseForeBackView?.backgroundColor = backgroundColor
        }
        get {
            return self.view.backgroundColor
        }
    }
    public var isFirstLoad: Bool = true
    private var baseForeBackView : UIView!
    private var statusBarHidden : Bool = false
    private var referDic: Dictionary<String, Any>?
    open var viewModel: BaseViewModel!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if canSlideToLast() {
            if self.navigationController != nil && self.navigationController!.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
                self.navigationController!.interactivePopGestureRecognizer?.isEnabled   = true
            }
        }else{
            if self.navigationController != nil && self.navigationController!.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
                self.navigationController!.interactivePopGestureRecognizer?.isEnabled   = false
            }
        }
        
        if self.navigationController != nil && self.navigationController!.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            if self.navigationController!.viewControllers.count >= 2 {
                self.navigationController!.interactivePopGestureRecognizer!.delegate = self
            }else{
                self.navigationController!.interactivePopGestureRecognizer?.delegate    = nil
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled     = false
            }
        }
        if needSendPv() {
            sendPStatistics()
        }
        isFirstLoad = false
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.navigationController != nil && self.navigationController!.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.navigationController?.interactivePopGestureRecognizer?.delegate    = nil
        }
    }
    
    public func sendPStatistics() {
        if isFirstLoad || (isTabVc && BaseViewController.isTabChanged) {
            let to: String = self.getTo()
            if !to.contains("/?") {
                let from: String = self.getFrom()
                Behavior.eventReport("", isPage: true, from: from, to: to)
            }
        }
    }
    
    open func getViewModelType() -> BaseViewModel.Type {
        return BaseViewModel.self
    }
    /**
     初始化界面
     - returns: 无
     */
    open func initUI() {
        self.edgesForExtendedLayout = UIRectEdge()
        baseBgView = UIView()
        self.view.addSubview(baseBgView)
        self.view.clipsToBounds = false
        baseBgView.backgroundColor  = HexColor("#fff")
        baseBgView.snp.makeConstraints({ (maker) -> Void in
            maker.top.equalTo(self.view).offset(-TOP_AREA_HEIGHT)
            maker.bottom.equalTo(self.view)
            maker.left.equalTo(self.view)
            maker.right.equalTo(self.view)
        })
        
        baseForeBackView = UIView()
        baseForeBackView?.backgroundColor  = HexColor("#eeecf1")
        baseBgView.addSubview(baseForeBackView!)
        baseForeBackView?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(baseBgView)
            maker.right.equalTo(baseBgView)
            maker.bottom.equalTo(baseBgView)
            maker.top.equalTo(baseBgView).offset(TOP_AREA_HEIGHT)
        })
        
        self.view.sendSubviewToBack(baseBgView)
        
        if self.needSetBackIcon() {
            self.setBackIcon()
        }else{
            self.navigationController?.navigationItem.hidesBackButton           = true
            self.navigationItem.hidesBackButton                                 = true
            self.navigationController?.navigationBar.backItem?.hidesBackButton  = true
        }
    }
    
    /**
     请求数据
     - returns: 无
     */
    open func refreshData() {
    }
    
    /**
     是否可以左滑返回
    
     - returns: 是否可以
     */
    open func canSlideToLast() -> Bool {
        return true
    }
    
    /**
     是否需要返回按钮
     
     - returns: 是否需要
     */
    open func needSetBackIcon()  -> Bool {
        return true
    }
    
    /**
     设置返回图标
     
     - returns: 无
     */
    open func setBackIcon() {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 18))
        btn.setImage(UIImage(named: "back"), for: UIControl.State())
        btn.imageEdgeInsets = UIEdgeInsets(top: 3, left: -8, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(BaseViewController.popAction), for: UIControl.Event.touchUpInside)
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: btn)
    }
    
    open func needSendPv() -> Bool {
        return true
    }
    
    open func getFrom() -> String {
        var from: String = "-"
        if let vc = UIApplication.appTopViewController() as? BaseViewController {
            from = vc.getTo()
        }
        if let p = referDic {
            if let ref = p["refer"] {
                from = ref + ""
            }
        }
        return from
    }
    
    open func getTo() -> String {
        var para : String = ""
        if self.referDic != nil && !self.referDic!.isEmpty {
            para = "?"
            for (key, value) in self.referDic! {
                para += "\(key)=\(value)&"
            }
            para = String(para[..<para.index(para.endIndex, offsetBy: -1)])
        }
        return getVcId() + para
    }
    
    open func getVcId() -> String {
        return "/"
    }
    
    @objc public func popAction() {
        if let _ = self.presentingViewController {
            self.dismiss(animated: true, completion: nil)
        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController!.interactivePopGestureRecognizer {
            return self.navigationController!.viewControllers.count > 1
        }
        return true
    }
    
    
    override open var prefersStatusBarHidden : Bool {
        return statusBarHidden
    }
    
    public func hideStatusBar(_ hidden : Bool) {
        statusBarHidden = hidden
        if self.responds(to: #selector(UIViewController.setNeedsStatusBarAppearanceUpdate)) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

public extension BaseViewController {
    public func setTopBar(withAlpha alpha: CGFloat, animated: Bool, duration: TimeInterval, complition: ((Bool) -> Void)?) {
        guard let tv = (self.navigationController as? BaseNavigationController)?.barBackView else{
            return
        }
        if animated {
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                tv.alpha = alpha
            }, completion: complition)
        }else{
            tv.alpha = alpha
            complition?(false)
        }
    }
}
