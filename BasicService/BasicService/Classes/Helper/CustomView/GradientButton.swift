//
//  GradientButton.swift
//  Lhb
//
//  Created by zhangyr on 2017/7/7.
//  Copyright © 2017年 quchaogu. All rights reserved.
//

import UIKit

public class GradientButton: BaseButton {
    
    override open var frame: CGRect {
        didSet {
            gradientLayer?.frame = frame
        }
    }
    
    public var labelFont: UIFont? {
        didSet {
            label?.font = labelFont
        }
    }
    public var labelColor: UIColor? {
        didSet {
            label?.textColor = labelColor
        }
    }
    public var text: String? {
        didSet {
            label?.text = text
        }
    }
    
    public var needGradient: Bool = true {
        didSet {
            gradientLayer?.isHidden = !needGradient
        }
    }

    public init(lColor: CGColor = HexColor("#f2233b").cgColor, rColor: CGColor = HexColor("#ff6622").cgColor, needLabel: Bool = false) {
        self.lColor = lColor
        self.rColor = rColor
        super.init(frame: .zero)
        gradientLayer = CAGradientLayer()
        gradientLayer?.zPosition = -1
        gradientLayer?.colors = [lColor, rColor]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 0)
        self.layer.addSublayer(gradientLayer!)
        
        if needLabel {
            label = UILabel()
            label?.textAlignment = .center
            self.addSubview(label!)
            label?.snp.makeConstraints({ (maker) in
                maker.center.equalTo(self)
                maker.width.equalTo(self)
                maker.height.equalTo(self)
            })
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setColor(lColor: CGColor, rColor: CGColor) {
        self.lColor = lColor
        self.rColor = rColor
        gradientLayer?.colors = [lColor, rColor]
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer?.frame = rect
    }
    
    private var lColor: CGColor
    private var rColor: CGColor
    private var gradientLayer: CAGradientLayer?
    private var label: UILabel?
}
