//
//  BaseView.swift
//  GaodiLicai
//
//  Created by focus on 15/12/1.
//  Copyright © 2015年 quchaogu. All rights reserved.
//

import UIKit
import SnapKit

public class BaseView: UIView {
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        if self.needLifeCycle() {
            self.initBaseData()
            self.initUI()
            self.loadBaseData()
        }
    }
    
    public func initUI() {
        self.backgroundColor = UIColor.clear
    }
    
    public func initBaseData() {
    
    }
    
    public func loadBaseData() {
        
    }
    
    public func needLifeCycle() -> Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}
