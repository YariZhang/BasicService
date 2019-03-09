//
//  ButtonForTab.swift
//  quchaogu
//
//  Created by zhangyr on 15/5/25.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//
//  自定义tabBar中的按钮组合
//

import UIKit
import SDWebImage

public protocol ButtonForTabDelegate : NSObjectProtocol
{
    func buttonForTabClicked(_ sender : BaseButton)
}

public class ButtonForTab: BaseButton
{
    public weak var delegate   : ButtonForTabDelegate?
    {
        didSet
        {
            self.addTarget(self, action: #selector(ButtonForTab.clickButton(_:)), for: UIControl.Event.touchUpInside)
        }
    }
    
    public var titleFont : CGFloat   = 10
    {
        didSet
        {
            if titleFont != oldValue
            {
                self.updateConstraints()
            }
        }
    }
    
    public var marginHeight : CGFloat  = 4
    {
        didSet
        {
            if oldValue != marginHeight
            {
                self.updateConstraints()
            }
        }
    }
    
    public var marginTop : CGFloat     = 10
    {
        didSet
        {
            if oldValue != marginTop
            {
                self.updateConstraints()
            }
        }
    }

    public init(frame: CGRect ,image : String , title : String ,toView : UIView, isRevearse : Bool = false)
    {
        super.init(frame: frame)
        self.isImageFromNet     = false
        self.mImage             = UIImage(named: image)
        self.setImage(self.mImage, for: UIControl.State())
        self.setTitle(title, for: UIControl.State())
        self.titleLabel?.font   = UIFont.normalFontOfSize(self.titleFont)
        //let tapGesture = UITapGestureRecognizer(target: controller, action: "doubleClick:")
        //tapGesture.numberOfTapsRequired = 2
        //self.addGestureRecognizer(tapGesture)
        self.mIsRevearse         = isRevearse
        self.adjustsImageWhenHighlighted = false
        toView.addSubview(self)
    }
    
    public init(frame: CGRect ,imageUrlStr : String , title : String ,toView : UIView, isRevearse : Bool = false)
    {
        super.init(frame: frame)
        self.isImageFromNet     = true
        self.sd_setImage(with: URL(string: imageUrlStr), for: UIControl.State()) { (img, error, SDImageCacheTypeDisk, url) in
                self.mImage      = img
                self.needsUpdateConstraints()
        }
        self.contentMode        = UIView.ContentMode.scaleAspectFit
        self.setTitle(title, for: UIControl.State())
        self.titleLabel?.font   = UIFont.normalFontOfSize(self.titleFont)
        self.mIsRevearse         = isRevearse
        self.adjustsImageWhenHighlighted = false
        toView.addSubview(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        self.titleLabel?.font   = UIFont.normalFontOfSize(titleFont)
        
        if mIsRevearse
        {
            //Center text
            var newFrame : CGRect   = self.titleLabel!.frame
            newFrame.origin.x       = 0;
            newFrame.origin.y       = self.marginTop;
            newFrame.size.width     = self.frame.size.width;
            newFrame.size.height    = titleFont
            
            self.titleLabel!.frame  = newFrame;
            self.titleLabel!.textAlignment = NSTextAlignment.center;
            
            //set image bounds
            if self.isImageFromNet
            {
                if let img  = self.mImage
                {
                    let width           = img.size.width / 3
                    let height          = img.size.height / 3
                    
                    self.imageView?.bounds      = CGRect(x: 0, y: 0, width: width, height: height)
                }
                
            }
            
            // Center image
            var center : CGPoint    = self.imageView!.center;
            center.x                = self.frame.size.width / 2;
            center.y                = self.marginTop + self.titleLabel!.frame.height + self.marginHeight + self.imageView!.frame.size.height / 2;
            self.imageView!.center  = center;
            
            
        }else
        {
            
            if self.imageView != nil && self.titleLabel != nil
            {
                //set image bounds
                if self.isImageFromNet
                {
                    if let img  = self.mImage
                    {
                        let width           = img.size.width / 3
                        let height          = img.size.height / 3
                        
                        self.imageView?.bounds      = CGRect(x: 0, y: 0, width: width, height: height)
                    }
                    
                }
                
                // Center image
                var center : CGPoint    = self.imageView!.center;
                center.x                = self.frame.size.width / 2;
                center.y                = self.imageView!.frame.size.height / 2 + self.marginTop;
                self.imageView!.center  = center;
                
                //Center text
                var newFrame : CGRect   = self.titleLabel!.frame
                newFrame.origin.x       = 0;
                newFrame.origin.y       = self.imageView!.frame.size.height + self.marginTop + self.marginHeight;
                newFrame.size.width     = self.frame.size.width;
                newFrame.size.height    = titleFont
                self.titleLabel!.frame  = newFrame;
                self.titleLabel!.textAlignment = NSTextAlignment.center;
            }
        }
    }
    
    @objc func clickButton(_ sender : BaseButton)
    {
        self.delegate?.buttonForTabClicked(sender)
    }
    
    fileprivate var mImage          : UIImage?
    fileprivate var isImageFromNet  : Bool      = false
    fileprivate var mIsRevearse     : Bool      = false
    
}
