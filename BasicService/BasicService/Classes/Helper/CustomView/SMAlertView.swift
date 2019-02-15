//
//  GDRichContentAlertView.swift
//  GaodiLicai
//
//  Created by zhangyr on 2017/1/18.
//  Copyright © 2017年 quchaogu. All rights reserved.
//  260

import UIKit

private let BUTTON_TAG_OFFSET = 100
private let ALERTVIEW_WIDTH :CGFloat = 260 * UIScreen.main.bounds.width / 375

@objc public protocol SMAlertViewDelegate: NSObjectProtocol {
    @objc optional func smAlert(_ alert : SMAlertView , clickButtonAtIndex buttonIndex : Int)
}

public class SMAlertView: UIView {
    
    public lazy var attributesTitle: [NSAttributedString.Key: Any]     = [NSAttributedString.Key.foregroundColor: HexColor(COLOR_COMMON_BLACK),
                                                                          NSAttributedString.Key.font: UIFont.boldFontOfSize(18)]
    public lazy var attributesMessage: [NSAttributedString.Key: Any]   = [NSAttributedString.Key.foregroundColor: HexColor(COLOR_COMMON_BLACK_3),
                                                                          NSAttributedString.Key.font: UIFont.normalFontOfSize(14)]
    public lazy var attributesTips: [NSAttributedString.Key: Any]      = [NSAttributedString.Key.foregroundColor: HexColor(COLOR_COMMON_BLACK_9),
                                                                          NSAttributedString.Key.font: UIFont.normalFontOfSize(12)]
    public lazy var attributesButton: [NSAttributedString.Key: Any]    = [NSAttributedString.Key.foregroundColor: HexColor(COLOR_COMMON_BLACK_3),
                                                                          NSAttributedString.Key.font: UIFont.boldFontOfSize(16)]
    
    public var canDismissOutside: Bool = false
    public var messageAlignment: NSTextAlignment = .center
    public var cornerRadius: CGFloat = 0
    public var titleSpace: CGFloat = 12
    public var messageSpace: CGFloat = 15
    public var tipsSpace: CGFloat = 18
    public var buttonSpace: CGFloat = 26
    public var buttonHeight: CGFloat = 45
    public var topSpace: CGFloat = 24
    public var bottomSpace: CGFloat = 44
    public var animationDuration: TimeInterval = 0.3
    public var delayDuration: TimeInterval = 0
    public var needTimer: Bool = false
    public var duration: TimeInterval = 0
    public var tips: String?
    public var timeoutBlock: (() -> Void)?
    
    public var cancelButtonIndex: Int {return 0}
    public var closeButtonIndex: Int {return 999}
    public var needClose: Bool = false
    public var closeImage: UIImage? = UIImage(named: "main_event_close_hover")
    
    public var userInfo: Any?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor    = UIColor.black.withAlphaComponent(0.3)
    }
    
    convenience public init(image: UIImage? = nil,
                            title: String?,
                            message: Any?,
                            delegate: SMAlertViewDelegate?,
                            cancelButtonTitle: String?) {
        
        self.init(frame: CGRect(x: 0,
                                y: 0,
                                width: UIScreen.main.bounds.width,
                                height: UIScreen.main.bounds.height))
        
        self.image      = image
        self.title      = title
        self.message    = message
        self.delegate   = delegate
        self.hasCancel  = false
        if cancelButtonTitle != nil {
            self.hasCancel    = true
            self.buttonTitles = []
            self.buttonTitles?.append(cancelButtonTitle!)
        }
    }
    
    convenience public init(image: UIImage? = nil,
                            title: String?,
                            message: Any?,
                            delegate: SMAlertViewDelegate?,
                            cancelButtonTitle: String?,
                            otherButtonTitles: String,
                            _ moreButtonTitles: String...) {
        
        self.init(image: image,
                  title: title,
                  message: message,
                  delegate: delegate,
                  cancelButtonTitle: cancelButtonTitle)
        if self.buttonTitles == nil {
            self.buttonTitles = []
        }
        self.buttonTitles?.append(otherButtonTitles)
        for bStr in moreButtonTitles {
            self.buttonTitles?.append(bStr)
        }
    }
    
    public func setButtonAtrributes(_ attributes: [NSAttributedString.Key: Any], atIndex index: Int) {
        if buttonsAttributes == nil {
            buttonsAttributes = [:]
        }
        _ = buttonsAttributes?.updateValue(attributes, forKey: index)
    }
    
    public func setAttributesToMessage(_ attributes: [NSAttributedString.Key: Any], subString: String) {
        if let attributeStr = self.msgLabel?.attributedText {
            let attr = NSMutableAttributedString(attributedString: attributeStr)
            attr.addAttributes(attributes, range: NSString(string: attributeStr.string).range(of: subString))
            msgLabel?.attributedText = attr
        }
    }
    
    public func show(inView view: UIView? = UtilTools.getAppDelegate()?.window ?? nil) {
        guard view != nil else {
            return
        }
        layoutViews()
        view?.addSubview(self)
        self.alpha = 0
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 1
        }, completion: {(bool) in
            if self.delayDuration > 0.0001 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.delayDuration , execute: {
                    self.dismiss()
                })
            }
        })
    }
    
    private func layoutViews() {
        contentView                     = UIView(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: ALERTVIEW_WIDTH,
                                                               height: 0))
        contentView.backgroundColor     = HexColor(COLOR_COMMON_WHITE)
        contentView.layer.cornerRadius  = cornerRadius
        contentView.layer.shadowColor   = UIColor.black.cgColor
        contentView.layer.shadowRadius  = 2
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset  = CGSize(width: 2, height: 2)
        self.addSubview(contentView)
        
        var tmpY: CGFloat = topSpace
        if needClose {
            let closeBtn = BaseButton(frame: CGRect(x: ALERTVIEW_WIDTH - 12 - 30,
                                                    y: 6,
                                                    width: 30,
                                                    height: 30))
            closeBtn.contentHorizontalAlignment = .right
            closeBtn.setImage(closeImage, for: UIControl.State.normal)
            closeBtn.tag = 999 + BUTTON_TAG_OFFSET
            closeBtn.addTarget(self, action: #selector(SMAlertView.buttonClick(btn:)), for: UIControl.Event.touchUpInside)
            contentView.addSubview(closeBtn)
        }
        
        if image != nil {
            let imageV      = UIImageView(frame: CGRect(x: (ALERTVIEW_WIDTH - imageWidth) / 2,
                                                        y: tmpY,
                                                        width: imageWidth,
                                                        height: imageHeight))
            imageV.image    = image
            contentView.addSubview(imageV)
            tmpY           += imageHeight
        }
        
        if title != nil {
            tmpY                           += tmpY <= topSpace ? 0 : titleSpace
            let titleLabel                  = UILabel(frame: CGRect(x: 16,
                                                                    y: tmpY,
                                                                    width: ALERTVIEW_WIDTH - 32,
                                                                    height: 0))
            titleLabel.numberOfLines        = 0
            titleLabel.textAlignment        = .center
            titleLabel.attributedText       = NSAttributedString(string: title!, attributes: attributesTitle)
            contentView.addSubview(titleLabel)
            let size                        = titleLabel.sizeThatFits(CGSize(width: ALERTVIEW_WIDTH - 32, height: 999))
            titleLabel.frame.size.height    = size.height
            tmpY                           += size.height
        }
        
        if message != nil {
            tmpY                           += tmpY <= topSpace ? 0 : messageSpace
            let msgLabel                    = UILabel(frame: CGRect(x: 16,
                                                                    y: tmpY,
                                                                    width: ALERTVIEW_WIDTH - 32,
                                                                    height: 0))
            msgLabel.numberOfLines          = 0
            msgLabel.textAlignment          = messageAlignment
            if let attriMsg = message as? NSAttributedString {
                msgLabel.attributedText     = attriMsg
            }else if let msg = message as? String {
                msgLabel.attributedText     = NSAttributedString(string: msg, attributes: attributesMessage)
            }else{
                msgLabel.text               = ""
            }
            contentView.addSubview(msgLabel)
            let size                        = msgLabel.sizeThatFits(CGSize(width: ALERTVIEW_WIDTH - 32, height: 999))
            msgLabel.frame.size.height      = size.height
            tmpY                           += size.height
            if size.height > 24 {
                msgLabel.textAlignment      = .left
            }
            self.msgLabel                   = msgLabel
        }
        
        if tips != nil {
            tmpY                           += tmpY <= topSpace ? 0 : tipsSpace
            let tipLabel                    = UILabel(frame: CGRect(x: 16,
                                                                    y: tmpY,
                                                                    width: ALERTVIEW_WIDTH - 32,
                                                                    height: 0))
            tipLabel.numberOfLines          = 0
            tipLabel.textAlignment          = .center
            tipLabel.attributedText         = NSAttributedString(string: tips!, attributes: attributesTips)
            contentView.addSubview(tipLabel)
            let size                        = tipLabel.sizeThatFits(CGSize(width: ALERTVIEW_WIDTH - 32, height: 999))
            tipLabel.frame.size.height      = size.height
            tmpY                           += size.height
            
            if needTimer && duration > 1 {
                timer                       = Timer(timeInterval: 1,
                                                    target: self,
                                                    selector: #selector(SMAlertView.timerRun(timer:)),
                                                    userInfo: tipLabel,
                                                    repeats: true)
                tipLabel.attributedText     = NSAttributedString(string: "\(Int(duration))秒后，\(tips!)", attributes: attributesTips)
                RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
            }
        }
        
        if buttonTitles != nil && buttonTitles!.count > 0 {
            tmpY                           += tmpY <= topSpace ? 0 : buttonSpace
            let isDouble                    = buttonTitles!.count == 2
            let buttonW                     = isDouble ? ALERTVIEW_WIDTH / 2 : ALERTVIEW_WIDTH
            for i in 0 ..< buttonTitles!.count {
                let tmpX                    = (isDouble && i != 0) ? buttonW : 0
                let button                  = BaseButton(frame: CGRect(x: tmpX,
                                                                       y: tmpY,
                                                                       width: buttonW,
                                                                       height: buttonHeight))
                button.layer.cornerRadius   = cornerRadius
                if hasCancel {
                    button.tag              = BUTTON_TAG_OFFSET + i
                }else{
                    button.tag              = BUTTON_TAG_OFFSET + i + 1
                }
                button.addTarget(self, action: #selector(SMAlertView.buttonClick(btn:)), for: UIControl.Event.touchUpInside)
                var attr: [NSAttributedString.Key: Any]?    = attributesButton
                if let attri = buttonsAttributes?[i] {
                    attr                    = attri
                }
                let aStr                    = NSAttributedString(string: buttonTitles![i], attributes: attr)
                button.setAttributedTitle(aStr, for: UIControl.State.normal)
                contentView.addSubview(button)
                if !isDouble || i == 1 {
                    tmpY                   += buttonHeight
                    let topLine             = UIView(frame: CGRect(x: 0,
                                                                   y: button.frame.minY,
                                                                   width: ALERTVIEW_WIDTH,
                                                                   height: 0.5))
                    topLine.backgroundColor = HexColor("#e0e0e0")
                    contentView.addSubview(topLine)
                }
                if isDouble && i == 1 {
                    let midLine             = UIView(frame: CGRect(x: button.frame.minX,
                                                                   y: button.frame.minY,
                                                                   width: 0.5,
                                                                   height: button.frame.height))
                    midLine.backgroundColor = HexColor("#e0e0e0")
                    contentView.addSubview(midLine)
                }
            }
        }else{
            tmpY                           += bottomSpace
        }
        
        contentView.frame.size.height       = tmpY
        contentView.center                  = self.center
        
    }
    
    @objc private func buttonClick(btn: UIButton) {
        timer?.invalidate()
        dismiss()
        delegate?.smAlert?(self, clickButtonAtIndex: btn.tag - BUTTON_TAG_OFFSET)
    }
    
    private func dismiss() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 0
        }, completion: {(bool) in
            self.timeoutBlock?()
            self.removeFromSuperview()
        })
    }
    
    private func getRectForString(_ string: String, withAttribute attri: [NSAttributedString.Key: Any]) -> CGRect {
        return NSString(string: string).boundingRect(with: CGSize(width: ALERTVIEW_WIDTH - 32, height: 999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attri, context: nil)
    }
    
    @objc private func timerRun(timer: Timer) {
        duration    -= 1
        if Int(duration) <= 0 {
            timer.invalidate()
            dismiss()
        }else{
            if let label = timer.userInfo as? UILabel {
                label.attributedText = NSAttributedString(string: "\(Int(duration))秒后，\(tips!)", attributes: attributesTips)
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            if !contentView.frame.contains(location) && canDismissOutside {
                dismiss()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var hasCancel: Bool = false
    private weak var delegate: SMAlertViewDelegate?
    private var image: UIImage?
    private var title: String?
    private var message: Any?
    private var buttonTitles: [String]?
    private var buttonsAttributes: [Int: [NSAttributedString.Key: Any]]?
    
    private var contentView: UIView!
    private weak var msgLabel: UILabel?
    private var timer: Timer?
    
    private var imageWidth: CGFloat {
        if image == nil {
            return 0
        }else{
            return image!.size.width
        }
    }
    private var imageHeight: CGFloat {
        if image == nil {
            return 0
        }else{
            return image!.size.height
        }
    }
    
}
