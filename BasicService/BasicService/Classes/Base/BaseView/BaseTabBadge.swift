//
//  BaseTabBadge.swift
//  quchaogu
//
//  Created by zhangyr on 16/6/13.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

public enum BaseTabBadgeType : Int {
    case number = 0
    case image
    case point
}

public class BaseTabBadge: BaseView {
    
    ///image for badgeView (only BaseTabBadgeType.Image)
    public var image: UIImage? {
        didSet {
            if let v = self.viewWithTag(999) as? UIImageView {
                v.image = image
            }
        }
    }
    ///count of badge for badgeView (only BaseTabBadgeType.Number)
    public var number: Int? {
        didSet {
            if let v = self.viewWithTag(999) as? TabShowLabel , number != nil {
                v.isHidden = number! == 0
                if number! > 0 {
                    if number! > 99 {
                        v.text = "99+"
                    }else{
                        v.text = "\(number!)"
                    }
                }
                v.sizeToFit()
                let tmpW = v.frame.size.width + 6
                v.snp.remakeConstraints({ (maker) in
                    maker.left.equalTo(self)
                    maker.centerY.equalTo(self)
                    maker.height.equalTo(12)
                    maker.width.equalTo(tmpW)
                })
            }
        }
    }
    ///font size of the badgeView'text (only BaseTabBadgeType.Number)
    public var fontSize: CGFloat? {
        didSet {
            if let v = self.viewWithTag(999) as? TabShowLabel , fontSize != nil {
                v.font = UIFont.normalFontOfSize(fontSize!)
                let size = fontSize! + 4
                v.layer.cornerRadius = size / 2
                v.snp.remakeConstraints({ (maker) in
                    maker.left.equalTo(self)
                    maker.centerY.equalTo(self)
                    maker.height.equalTo(size)
                })
            }
        }
    }
    ///color of the badgeView'text (only BaseTabBadgeType.Number)
    public var textColor: UIColor? {
        didSet {
            if let v = self.viewWithTag(999) as? TabShowLabel , textColor != nil {
                v.tColor = textColor!
            }
        }
    }
    ///background color for badgeView (any)
    public var bgcolor: UIColor? {
        didSet {
            if let v = self.viewWithTag(999) , bgcolor != nil {
                v.backgroundColor = bgcolor
            }
        }
    }
    
    required init(type : BaseTabBadgeType) {
        super.init(frame: CGRect.zero)
        
        switch type {
        case .number:
            let badge = TabShowLabel()
            badge.insets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
            badge.isHidden = true
            badge.tColor = HexColor("#fff")
            badge.sColor = UIColor.clear
            badge.backgroundColor = HexColor("#ef5350")
            badge.layer.cornerRadius = 6
            badge.tag = 999
            badge.font = UIFont.normalFontOfSize(8)
            self.addSubview(badge)
            badge.snp.makeConstraints({ (maker) in
                maker.left.equalTo(self)
                maker.centerY.equalTo(self)
                maker.height.equalTo(12)
            })
            break
        case .image:
            let imageView               = UIImageView()
            imageView.tag               = 999
            self.addSubview(imageView)
            imageView.snp.makeConstraints({ (maker) in
                maker.left.equalTo(self)
                maker.bottom.equalTo(self)
            })
            break
        default:
            let point                   = UIView()
            point.backgroundColor       = HexColor("#ef5350")
            point.layer.cornerRadius    = 4
            point.tag                   = 999
            self.addSubview(point)
            point.snp.makeConstraints({ (maker) in
                maker.left.equalTo(self)
                maker.centerY.equalTo(self)
                maker.width.equalTo(8)
                maker.height.equalTo(8)
            })
            break
        
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
