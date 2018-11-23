//
//  BaseNavigationController.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/9.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit
import SnapKit

open class BaseNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    public static var referNavi: BaseNavigationController?
    
    public var titleAttributes: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
         NSAttributedString.Key.foregroundColor: UIColor.white] {
        didSet {
            navigationBar.titleTextAttributes = titleAttributes
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.view.backgroundColor = HexColor("#fff")
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.clear
        self.navigationBar.barTintColor = UIColor.clear
        self.navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = titleAttributes
        navigationBar.isTranslucent = true
        self.view.bringSubviewToFront(self.navigationBar)
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let back = UIBarButtonItem(title: " ", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = back
        navigationBar.titleTextAttributes = titleAttributes
        navigationBar.isTranslucent = true
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: TOP_AREA_HEIGHT)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        if navigationController.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    public var barBackView: UIView!

}
