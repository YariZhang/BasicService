//
//  MultiTouchEnableButton.swift
//  GaodiLicai
//
//  Created by zhangyr on 16/1/6.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

open class BaseButton: UIButton {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isExclusiveTouch         = enableMultiTouch
    }
    
    open var enableMultiTouch = true {
        didSet {
            self.isExclusiveTouch     = enableMultiTouch
        }
    }
    
    open var highlightColor: String? {
        didSet {
            if highlightColor != oldValue && highlightColor != nil {
                let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
                UIGraphicsBeginImageContext(rect.size);
                let context = UIGraphicsGetCurrentContext()
                context?.setFillColor(HexColor(highlightColor!).cgColor)
                context?.fill(rect)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                self.setImage(image, for: UIControl.State.highlighted)
            }else{
                self.setImage(nil, for: UIControl.State.highlighted)
            }
        }
    }
    
    open weak var tmpData: AnyObject?
    open var storage: Any?
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
