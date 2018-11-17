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

let QQ_OAUTH2_URL = "http://oauth2.quchaogu.com/qq"

public class BaseWebViewController: BaseViewController, DxwWebViewDelegate {
    private var _url: String = ""
    public var url: String {
        get {
            return _url;
        }
        set {
            if !newValue.contains("#hy123") && newValue.contains(".pdf") {
                _url = newValue + "#hy123"
            }else{
                _url = newValue
            }
        }
    }
    public var relativeUrl: String = "" {
        didSet {
            if relativeUrl.hasPrefix("/") {
                relativeUrl = (relativeUrl as NSString).substring(from: 1)
            }
        }
    }
    var headers: Dictionary<String, String>?
    public override var param: Dictionary<String, Any>? {
        didSet {
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
    }
    public var needLoading: Bool = true
    public var needPopStack: Bool = true
    public var callBack: ((String) -> Void)?
    
    deinit {
        self.webView = nil
    }
    
    override public func initUI() {
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
                url = ServerType.base.rawValue + relativeUrl
            }
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
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
    
    override public func viewWillDisappear(_ animated: Bool) {
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
    
    private func dxwWebViewStart(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        if needLoading{
//            let tmpToast = ToastView.showMessage("加载中...", withParentView : self.webView, withTarget: nil, andAction: nil)
//            if tmpToast != nil
//            {
//                _toastView      = tmpToast
//            }
//        }else
//        {
//            _toastView?.dismiss()
//            _toastView  = nil
//        }
    }
    
    private func dxwWebViewFinished(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { (data, error) in
            self.title = (data + "").count > 0 ? data + "" : "详情"
        }
//        _toastView?.dismiss()
//        _toastView  = nil
    }
    
    private func dxwWebViewFailed(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        _toastView?.dismiss()
//        _toastView  = nil
    }
    
    private func dxwWebViewHasDecidePolicy(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    }
    
    override public func needSendPv() -> Bool {
        if url.contains(".pdf") && url.contains("#hy123") {
            return true
        }
        return false
    }
    
    override public func getTo() -> String {
        if url.contains(".pdf") && url.contains("#hy123") {
            return self.url
        }
        return super.getTo()
    }
    
    public func reloadData() {
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
    
    
    public var webView: DxwWebView!
//    private var _toastView           : ToastView?
    public var viewDidAppearCallBack: (() -> Void)?
}
