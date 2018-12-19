//
//  BaseTabItem.swift
//  quchaogu
//
//  Created by zhangyr on 16/6/13.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

@objc protocol BaseTabItemDelegate : NSObjectProtocol {
    func tabItemSelected(_ item : BaseTabItem) -> Void
    @objc optional func tabItemDoubleClick(_ item : BaseTabItem)
}

class BaseTabItem: BaseView {
    
    weak var delegate       : BaseTabItemDelegate?
    var badgeFontSize       : CGFloat? {
        didSet {
            setBadgeAttribute()
        }
    }
    var textColor           : UIColor? {
        didSet {
            setBadgeAttribute()
        }
    }
    var bgcolor             : UIColor? {
        didSet {
            setBadgeAttribute()
        }
    }
    var normalColor         : UIColor   = HexColor("#999999") {
        didSet {
            if !isSelected {
                textLabel.textColor     = normalColor
            }
        }
    }
    var selectedColor       : UIColor   = HexColor("#ef5350") {
        didSet {
            if isSelected {
                textLabel.textColor     = selectedColor
            }
        }
    }
    var fontSize            : CGFloat   = 10 {
        didSet {
            textLabel.font              = UIFont.normalFontOfSize(fontSize)
        }
    }
    var isSelected          : Bool      = false {
        didSet {
            if isSelected {
                textLabel.textColor     = selectedColor
                imageView.image         = source?.selectedImage
            }else{
                textLabel.textColor     = normalColor
                imageView.image         = source?.normalImage
            }
        }
    }
    var source              : BaseTabBarItemData? {
        didSet {
            if source != nil {
                textLabel.text          = source?.text
                backImage.image         = source?.backImage
                if isSelected {
                    imageView.image     = source?.selectedImage
                }else{
                    imageView.image     = source?.normalImage
                }
            }
        }
    }
    var style               : BaseTabBadgeType = .point {
        didSet {
            if style != oldValue {
                badgeView.removeFromSuperview()
                badgeView               = BaseTabBadge(type: style)
                badgeView.fontSize      = badgeFontSize
                badgeView.textColor     = textColor
                badgeView.bgcolor       = bgcolor
                badgeView.isHidden        = true
                self.addSubview(badgeView)
                switch style {
                case .point:
                    badgeView.snp.remakeConstraints { (maker) in
                        maker.left.equalTo(self.imageView.snp.right).offset(-8)
                        maker.bottom.equalTo(self.imageView.snp.top).offset(8)
                        maker.width.equalTo(8)
                        maker.height.equalTo(8)
                    }
                case .number :
                    badgeView.snp.remakeConstraints { (maker) in
                        maker.left.equalTo(self.imageView.snp.right).offset(-8)
                        maker.bottom.equalTo(self.imageView.snp.top).offset(8)
                        maker.right.equalTo(self)
                        maker.height.equalTo(12)
                    }
                default:
                    badgeView.snp.remakeConstraints { (maker) in
                        maker.left.equalTo(self.imageView.snp.right).offset(-8)
                        maker.bottom.equalTo(self.imageView.snp.top).offset(8)
                        maker.right.equalTo(self)
                        maker.top.equalTo(self)
                    }
                }
            }
        }
    }
    var badgeInfo           : AnyObject? {
        didSet {
            if badgeInfo == nil {
                badgeView.isHidden        = true
            }else{
                badgeView.isHidden        = false
                switch style {
                case .point:
                    break
                case .number :
                    badgeView.number    = Int(badgeInfo + "")
                default:
                    badgeView.image     = UIImage(named: badgeInfo + "")
                }
            }
        }
    }
    
    fileprivate var backImage   : UIImageView!
    fileprivate var imageView   : UIImageView!
    fileprivate var textLabel   : UILabel!
    fileprivate var badgeView   : BaseTabBadge!
    fileprivate var button      : BaseButton!
    
    override func initUI() {
        super.initUI()
        backImage               = UIImageView()
        self.addSubview(backImage)
        backImage.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
        
        imageView               = UIImageView()
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self)
            maker.top.equalTo(self).offset(8)
        }
        
        textLabel               = UILabel()
        textLabel.textColor     = normalColor
        textLabel.font          = UIFont.normalFontOfSize(fontSize)
        textLabel.textAlignment = .center
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self)
            maker.top.equalTo(self.imageView.snp.bottom).offset(3)
        }
        
        badgeView               = BaseTabBadge(type: style)
        badgeView.fontSize      = badgeFontSize
        badgeView.textColor     = textColor
        badgeView.bgcolor       = bgcolor
        badgeView.isHidden        = true
        self.addSubview(badgeView)
        badgeView.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.imageView.snp.right).offset(-8)
            maker.bottom.equalTo(self.imageView.snp.top).offset(8)
            maker.width.equalTo(8)
            maker.height.equalTo(8)
        }
        
        button                  = BaseButton()
        button.addTarget(self, action: #selector(BaseTabItem.selectedAction), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(BaseTabItem.doubleClick), for: UIControl.Event.touchDownRepeat)
        self.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
    }
    
    @objc fileprivate func selectedAction() {
        if !isSelected {
            delegate?.tabItemSelected(self)
            isSelected          = !isSelected
        }else{
            delegate?.tabItemDoubleClick?(self)
        }
    }
    
    fileprivate func setBadgeAttribute() {
        if badgeView != nil {
            badgeView.fontSize      = badgeFontSize
            badgeView.textColor     = textColor
            badgeView.bgcolor       = bgcolor
        }
    }
    
    @objc fileprivate func doubleClick() {
        delegate?.tabItemDoubleClick?(self)
    }

}
