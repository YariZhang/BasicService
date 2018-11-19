//
//  DxwWebView.swift
//  quchaogu
//
//  Created by zhangyr on 2018/11/16.
//  Copyright © 2018年 quchaogu. All rights reserved.
//

import UIKit
import WebKit
import WebViewJavascriptBridge

@objc public protocol DxwWebViewDelegate : NSObjectProtocol {
    //life cycle
    @objc optional func dxwWebViewStart(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    @objc optional func dxwWebViewHasDecidePolicy(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    @objc optional func dxwWebViewFinished(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    @objc optional func dxwWebViewFailed(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
}

public class DxwWKWebView : WKWebView {
}

open class DxwWebView: BaseView, WKUIDelegate, WKNavigationDelegate {
    public weak var delegate: DxwWebViewDelegate?
    public var code: String = ""
    public var jsBase: WebViewJavascriptBridgeBase!
    private var oriUrl: String = ""
    
    convenience init(url : String) {
        self.init(frame: CGRect.zero)
        oriUrl = url
        if oriUrl.contains("pdf") {
            self.initUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        if !oriUrl.contains("pdf") {
            self.initUI()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        webView.configuration.userContentController.removeAllUserScripts()
        webView.removeFromSuperview()
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func initBaseData() {
        super.initBaseData()
    }
    
    override open func needLifeCycle() -> Bool {
        return false
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        webView.isOpaque = false
        webView.backgroundColor = HexColor(COLOR_COMMON_WHITE)
    }
    
    override open func initUI() {
        super.initUI()
        self.backgroundColor = HexColor(COLOR_COMMON_WHITE)
        let scaleConfig = WKWebViewConfiguration()
        scaleConfig.selectionGranularity = .dynamic
        if oriUrl.contains("pdf") {
            let injectJS = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let script = WKUserScript(source: injectJS, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
            let userController = WKUserContentController()
            userController.addUserScript(script)
            scaleConfig.userContentController = userController
        }
        
        webView = DxwWKWebView(frame: CGRect.zero, configuration: scaleConfig)
        webView.isOpaque = false
        webView.backgroundColor = HexColor(COLOR_COMMON_WHITE)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.addSubview(webView)
        webView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self)
        }
        jsBase = WebViewJavascriptBridgeBase()
        bridge = WebViewJavascriptBridge.init(forWebView: webView)
        bridge.setWebViewDelegate(self)
    }
    
    public func registerJsFunctionForKey(_ key: String, callBack: ((Any?) -> Void)?) {
        bridge?.registerHandler(key, handler: { (data, nil) in
            callBack?(data)
        })
    }
    
    /**
     通知web端用户行为
     - parameter key: 调用的js方法名
     - parameter param: 传递的参数
     - returns: 无
     */
    public func setWebUserDefault(key: String, param: Any) {
        bridge.callHandler(key, data: param)
    }
    
    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        hasLoaded = false
        self.delegate?.dxwWebViewStart?(webView, didStartProvisionalNavigation: navigation)
    }
    
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hasLoaded = true
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        self.delegate?.dxwWebViewFinished?(webView, didFinish: navigation)
    }
    
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.dxwWebViewFailed?(webView, didFail: navigation, withError: error)
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        H5Helpler.sharedInstance.handleH5Intercept(jsBase: jsBase, webView: webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        self.delegate?.dxwWebViewHasDecidePolicy?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }
    
    open func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let card = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, card)
        } else {
            logPrint(challenge.protectionSpace.authenticationMethod)
        }
    }

    public func loadUrlStr(_ urlStr : String, headers: Dictionary<String, Any> = [:]) {
        H5Helpler.sharedInstance.loadUrlStr(webview: webView, urlStr: urlStr,headers: headers)
    }
    
    public func loadURL(_ url : URL, headers: Dictionary<String, Any> = [:]) {
        H5Helpler.sharedInstance.loadURL(webView: webView, url: url,headers: headers)
    }
    
    public func loadLocalHtml(html: String, baseUrl: URL?) {
        webView.loadHTMLString(html, baseURL: baseUrl)
    }
    
    private var hasLoaded: Bool = false
    open var bridge: WebViewJavascriptBridge!
    open var webView: DxwWKWebView!
}
