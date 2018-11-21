//
//  BaseView.swift
//  GaodiLicai
//
//  Created by zhangyr on 18/11/17.
//  Copyright © 2015年 quchaogu. All rights reserved.
//

import UIKit
import SnapKit

open class BaseView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        if self.needLifeCycle() {
            self.initBaseData()
            self.initUI()
            self.loadBaseData()
        }
    }
    
    open func initUI() {
        self.backgroundColor = UIColor.clear
    }
    
    open func initBaseData() {
    
    }
    
    open func loadBaseData() {
        
    }
    
    open func needLifeCycle() -> Bool {
        return true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}
