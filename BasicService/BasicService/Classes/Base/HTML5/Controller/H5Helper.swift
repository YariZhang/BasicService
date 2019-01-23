//
//  H5Helper.swift
//  Dxw
//
//  Created by zhangyr on 2018/11/16.
//  Copyright © 2018年 quchaogu. All rights reserved.
//

import UIKit
import WebKit
import WebViewJavascriptBridge
import QCGURLRouter

fileprivate let APPLE_ITUNES_URL = "https://itunes.apple.com"

class H5Helpler {
    var loginForOAuth2: ((String) -> Void)?
    var wx_p_a_y:((String) -> Void)?
    class var sharedInstance: H5Helpler {
        _ = H5Helpler.__once
        return Inner.instance!
    }
    
    struct Inner {
        static var instance: H5Helpler?
        static var token: Int = 0
    }
    
    fileprivate static var __once: () = { () -> Void in
        Inner.instance = H5Helpler()
    }()
    
    func loadURL(webView : WKWebView, url : URL, headers : Dictionary<String, Any>) {
        webView.stopLoading()
        var urlStr                              = url.absoluteString
        if isQcgURL(urlStr: urlStr) {
            if !urlStr.contains("ua") {
                let uaStr = getUAStr().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                if urlStr.contains("?") || urlStr.contains("#") {
                    urlStr = urlStr + "&ua=" + uaStr
                }else{
                    urlStr = urlStr + "?ua=" + uaStr
                }
            }
        }
        
        if let url1 = URL(string: urlStr) {
            let request = NSMutableURLRequest(url: url1)
            if urlStr.contains("quchaogu.com") {
                let bundleInfo = Bundle.main.infoDictionary
                let appVersion = bundleInfo!["CFBundleVersion"] + ""
                let appName = bundleInfo!["CFBundleName"] + "App"
                request.setValue(appVersion, forHTTPHeaderField: "AppVersion")
                request.setValue(appName, forHTTPHeaderField: "AppName")
                request.setValue(getUAStr(), forHTTPHeaderField: "UA")
                request.setValue(UtilTools.getUniqueDeviceId(), forHTTPHeaderField: "DeviceId")
                request.setValue(getCookies(), forHTTPHeaderField: "Cookie")
                for (k, v) in headers {
                    request.setValue(v + "", forHTTPHeaderField: k)
                }
            }
            webView.load(request as URLRequest)
        }
    }
    
    private func isQcgURL(urlStr : String) -> Bool {
        return urlStr.contains("quchaogu.com")
    }
    
    func loadUrlStr(webview : WKWebView, urlStr : String, headers : Dictionary<String, Any> = [:]) {
        if let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            let urlStr = urlString.replacingOccurrences(of: "%23", with: "#")
            if let url = URL(string: urlStr), urlStr != "about:blank" {
                self.loadURL(webView: webview, url: url, headers: headers)
            }
        }
    }
    
    private func getCookies() -> String {
        var cookieStr: String = ""
        if let cookies = HTTPCookieStorage.shared.cookies {
            for c in cookies {
                cookieStr += c.name + "=" + c.value + (cookies.last == c ? "" : ";")
            }
        }
        cookieStr += ";HttpOnly=false;"
        return cookieStr
    }
    
    func handleH5Intercept(jsBase : WebViewJavascriptBridgeBase,  webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let abStr = url.absoluteString
            if abStr.contains(QQ_OAUTH2_URL) {
                loginForOAuth2?(abStr)
                decisionHandler(WKNavigationActionPolicy.cancel)
            }else if let scheme = url.scheme, (!scheme.contains("http") && !jsBase.isWebViewJavascriptBridgeURL(url)) || abStr.contains(APPLE_ITUNES_URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                }else{
                    UIApplication.shared.openURL(url)
                }
                decisionHandler(WKNavigationActionPolicy.cancel)
            }else if abStr.contains("/app/native/page") { //跳转原生页面
                let query = url.query
                if let params = query?.components(separatedBy: "&") {
                    for p in params {
                        let arr = p.components(separatedBy: "=")
                        if arr.count == 2 && arr[0] == "param" {
                            let jsonStr = NSString(string: arr[1]).removingPercentEncoding
                            guard let jsonData = jsonStr?.data(using: String.Encoding.utf8) else {
                                decisionHandler(WKNavigationActionPolicy.cancel)
                                return
                            }
                            do {
                                let tmpDic = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
                                if let dic = tmpDic as? Dictionary<String,Any> {
                                    if let url1 = dic["url"] as? String, let uri = URL(string: url1) {
                                        QCGURLRouter.shareInstance.route(withUrl: uri, param: dic["param"] as? DxwDic)
                                    }
                                }
                            }catch{
                                decisionHandler(WKNavigationActionPolicy.cancel)
                                return
                            }
                            break
                        }
                    }
                }
                decisionHandler(WKNavigationActionPolicy.cancel)
            }else{
                guard !QCGURLRouter.shareInstance.route(withUrl: url) else {
                    decisionHandler(WKNavigationActionPolicy.cancel)
                    return
                }
                if !jsBase.isWebViewJavascriptBridgeURL(url) {
                    if url.absoluteString.contains("quchaogu.com") && url.absoluteString.lowercased().contains("newpage") {
                        var u = url.absoluteString.replacingOccurrences(of: "newpage", with: "dxwrep")
                        u = u.replacingOccurrences(of: "newPage", with: "dxwrep")
                        jumpPageNative(param: ["url": u])
                        decisionHandler(WKNavigationActionPolicy.cancel)
                    }else{
                        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        webView.isMultipleTouchEnabled = true
                        webView.isUserInteractionEnabled = true
                        decisionHandler(WKNavigationActionPolicy.allow)
                    }
                }
            }
        }
    }
}
