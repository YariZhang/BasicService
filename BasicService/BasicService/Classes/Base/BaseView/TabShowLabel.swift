//
//  TabShowLabel.swift
//  Lhb
//
//  Created by zhangyr on 18/11/17.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

public class TabShowLabel : UILabel {
    
    public var insets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    public var tColor : UIColor = HexColor("#333") {
        didSet {
            self.textColor = tColor
        }
    }
    public var sColor : UIColor = HexColor("#e0e0e0") {
        didSet {
            self.layer.borderColor = sColor.cgColor
        }
    }
    public var bColor : UIColor = UIColor.clear {
        didSet {
            self.backgroundColor = bColor
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor        = bColor
        self.layer.cornerRadius     = 2
        self.layer.masksToBounds    = true
        self.layer.borderColor      = sColor.cgColor
        self.layer.borderWidth      = 0.5
        self.textAlignment          = .center
        self.font                   = UIFont.normalFontOfSize(11)
        self.textColor              = tColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
}
