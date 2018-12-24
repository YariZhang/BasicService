//
//  BaseWebViewController.swift
//  Dxw
//
//  Created by zhangyr on 2018/11/16.
//  Copyright © 2017年 quchaogu. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import Toast

let QQ_OAUTH2_URL = "http://oauth2.quchaogu.com/qq"

open class BaseWebViewController: BaseViewController, DxwWebViewDelegate {
    open var url: String = ""
    open var relativeUrl: String = "" {
        didSet {
            if relativeUrl.hasPrefix("/") {
                relativeUrl = (relativeUrl as NSString).substring(from: 1)
            }
        }
    }
    public var headers: Dictionary<String, String>?
    public var webView: DxwWebView!
    public var viewDidAppearCallBack: (() -> Void)?
    public var needLoadingProgress: Bool = true
    public var progressLeftColor: UIColor = HexColor("#ffcc00")
    public var progressRightColor: UIColor = HexColor("#ffcc00")
    public var needPopStack: Bool = true
    public var callBack: ((String) -> Void)?
    
    deinit {
        self.webView.delegate = nil
        self.webView = nil
    }
    
    open override func initData() {
        if param != nil {
            if let url = param!["abUrl"] as? String {
                self.url = url
            }else if let url = param!["url"] as? String {
                self.url = url
            }
            
            if let relateUrl = param!["relativeUrl"] as? String {
                self.relativeUrl = relateUrl
            }
        }
    }
    
    override open func initUI() {
        super.initUI()
        webView = DxwWebView(url: url)
        webView.backgroundColor = UIColor.clear
        webView.delegate = self
        webView.isOpaque = false
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.view)
            maker.bottom.equalTo(self.view)
            maker.left.equalTo(self.view)
            maker.width.equalTo(self.view)
        }
       
        if relativeUrl.isEmpty && url.isEmpty {
            return
        }else{
            if relativeUrl.count > 0 {
                url = BaseRequest.glBaseServerUrl + relativeUrl
            }
        }
        if needLoadingProgress {
            initProgressView()
        }
    }
    
    private func initProgressView() {
        gradientView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 2))
        gradientView.isHidden = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.zPosition = -1
        gradientLayer.colors = [progressLeftColor.cgColor, progressRightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientView.layer.addSublayer(gradientLayer)
        self.view.addSubview(gradientView)
        
        maskView = UIView(frame: gradientView.bounds)
        maskView.backgroundColor = UIColor.white
        gradientView?.addSubview(maskView)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            var url1 = url
            if headers != nil{
                if let ul = UtilTools.getUrlWithParameter(url, parameters: headers!) {
                    url1 = ul
                }else{
                    url1 = url
                }
            }
            webView.loadUrlStr(url1, headers: headers ?? [:])
        }
        self.viewDidAppearCallBack?()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.webView.stopLoading()
    }
    
    override public func popAction() {
        if needPopStack && webView.webView.canGoBack {
            webView.webView.goBack()
        }else{
            super.popAction()
        }
    }
    
    open func dxwWebViewStart(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressStatus(.start)
    }
    
    open func dxwWebViewFinished(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { (data, error) in
            self.title = (data + "").count > 0 ? data + "" : "详情"
        }
        progressStatus(.end)
    }
    
    open func dxwWebViewFailed(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressStatus(.end)
    }
    
    open func dxwWebViewHasDecidePolicy(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    }
    
    override open func needSendPv() -> Bool {
        if url.contains(".pdf") && url.contains("#hy123") {
            return true
        }
        return false
    }
    
    override open func getTo() -> String {
        if url.contains(".pdf") && url.contains("#hy123") {
            return self.url
        }
        return super.getTo()
    }
    
    open func reloadData() {
        self.loadUrlStr(self.url)
    }
    
    public func loadUrlStr(_ urlStr : String, headers : Dictionary<String, Any> = [:]) {
        var url1 = urlStr
        if let ul = UtilTools.getUrlWithParameter(urlStr, parameters: headers) {
            url1 = ul
        }else{
            url1 = urlStr
        }
        H5Helpler.sharedInstance.loadUrlStr(webview: webView.webView, urlStr: url1,headers: headers)
        H5Helpler.sharedInstance.loginForOAuth2 = {[weak self] (url) in
            self?.callBack?(url)
            self?.popAction()
        }
    }
    
    public func loadURL(_ url : URL, headers : Dictionary<String, Any> = [:]) {
        var url1 = url.absoluteString
        if let ul = UtilTools.getUrlWithParameter(url.absoluteString, parameters: headers) {
            url1 = ul
        }else{
            url1 = url.absoluteString
        }
        H5Helpler.sharedInstance.loadUrlStr(webview: webView.webView, urlStr: url1,headers: headers)
        H5Helpler.sharedInstance.loginForOAuth2 = {[weak self] (url) in
            self?.callBack?(url)
            self?.popAction()
        }
    }
    
    private func progressStatus(_ status: ProgressStatus) {
        if gradientView == nil || maskView == nil {
            return
        }
        switch status {
        case .start:
            gradientView.isHidden = false
            maskView.frame = gradientView.bounds
            UIView.animate(withDuration: 2, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.maskView.frame.origin.x = self.gradientView.bounds.width * 0.6
            }) { (bool) in
                self.progressStatus(.progressing)
            }
        case .progressing:
            UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.maskView.frame.origin.x = self.gradientView.bounds.width * 0.9
            }) { (bool) in
            }
        case .end:
            UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.maskView.frame.origin.x = self.gradientView.bounds.width
            }) { (bool) in
                self.gradientView.isHidden = true
            }
        }
    }

    private enum ProgressStatus: CaseIterable {
        case start, progressing, end
    }
    private var gradientView: UIView!
    private var maskView: UIView!
}
