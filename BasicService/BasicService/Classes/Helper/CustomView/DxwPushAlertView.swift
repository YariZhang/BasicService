//
//  DxwPushAlertView.swift
//  Dxw
//
//  Created by zhangyr on 2018/1/9.
//  Copyright © 2018年 quchaogu. All rights reserved.
//

import UIKit
import TYAttributedLabel

@objc public protocol DxwPushAlertViewDelegate: NSObjectProtocol {
    func dxwPushAlertViewAllMsg()
    func dxwPushAlertViewDetail(type: String, url: String, param: Dictionary<String, Any>?)
    func dxwPushAlertViewOpenNoti()
    @objc optional func dxwPushAlertViewMsgCountLeft(num: Int)
}

public class DxwPushAlertView: BaseView, TYAttributedLabelDelegate {
    
    public weak var delegate: DxwPushAlertViewDelegate?
    
    public var data: PushMsgData = PushMsgData() {
        didSet {
            showData()
        }
    }
    
    public func show() {
        if let tv = UtilTools.getAppDelegate()?.keyWindow?.viewWithTag(2018124) {
            tv.removeFromSuperview()
        }
        self.tag = 2018124
        UtilTools.getAppDelegate()?.keyWindow?.addSubview(self)
        self.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalTo(self.superview!)
        }
    }
    
    override public func initUI() {
        super.initUI()
        self.backgroundColor = HexColor(COLOR_COMMON_BLACK_30)
        
        contentView = UIView()
        contentView.backgroundColor = HexColor(COLOR_COMMON_WHITE)
        contentView.layer.cornerRadius = 2
        contentView.layer.shadowColor = HexColor("#000").cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowRadius = 1
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (maker) in
            maker.center.equalTo(self)
            maker.width.equalTo(260)
            maker.height.equalTo(94)
        }
        
        topBar = UIImageView()
        topBar.image = UIImage(named: "pushAlertTopBar")
        contentView.addSubview(topBar)
        topBar.snp.makeConstraints { (maker) in
            maker.left.right.top.equalTo(contentView)
            maker.height.equalTo(50)
        }
        
        detailLabel = TYAttributedLabel()
        detailLabel.backgroundColor = UIColor.clear
        detailLabel.delegate = self
        detailLabel.font = UIFont.normalFontOfSize(14)
        detailLabel.textColor = HexColor(COLOR_COMMON_BLACK_3)
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(contentView).offset(20)
            maker.right.equalTo(contentView).offset(-20)
            maker.top.equalTo(topBar.snp.bottom).offset(15)
            maker.height.equalTo(0)
        }
        
        leftBtn = BaseButton()
        leftBtn.titleLabel?.font = UIFont.boldFontOfSize(16)
        leftBtn.setTitleColor(HexColor(COLOR_COMMON_BLACK_3), for: .normal)
        leftBtn.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        leftBtn.setTitle("全部", for: .normal)
        leftBtn.tag = ALL_BTN_TAG
        contentView.addSubview(leftBtn)
        leftBtn.snp.makeConstraints { (maker) in
            maker.left.bottom.equalTo(contentView)
            maker.width.equalTo(contentView).dividedBy(2)
            maker.height.equalTo(44)
        }
        
        rightBtn = BaseButton()
        rightBtn.backgroundColor = HexColor(COLOR_COMMON_WHITE)
        rightBtn.titleLabel?.font = UIFont.boldFontOfSize(16)
        rightBtn.setTitleColor(HexColor(COLOR_COMMON_BLACK_3), for: .normal)
        rightBtn.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        contentView.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { (maker) in
            maker.right.bottom.equalTo(contentView)
            maker.width.equalTo(contentView).multipliedBy(0.5)
            maker.height.equalTo(44)
        }
        
        let lineHor = UIView()
        lineHor.backgroundColor = HexColor("#e0e0e0")
        contentView.addSubview(lineHor)
        lineHor.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(contentView)
            maker.bottom.equalTo(leftBtn.snp.top)
            maker.height.equalTo(0.5)
        }
        
        lineVer = UIView()
        lineVer.backgroundColor = HexColor("#e0e0e0")
        contentView.addSubview(lineVer)
        lineVer.snp.makeConstraints { (maker) in
            maker.top.bottom.equalTo(leftBtn)
            maker.centerX.equalTo(contentView)
            maker.width.equalTo(0.5)
        }
        
        closeBtn = BaseButton()
        closeBtn.setImage(UIImage(named: "pushAlertClose"), for: .normal)
        closeBtn.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        self.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(contentView.snp.right)
            maker.centerY.equalTo(contentView.snp.top).offset(5)
            maker.width.equalTo(28)
            maker.height.equalTo(29)
        }
        
    }
    
    private func showData() {
        
        if APNsSetter.isOpenNotification {
            detailLabel.text = data.content
            rightBtn.setTitle("查看内容", for: .normal)
            rightBtn.setTitleColor(HexColor(COLOR_COMMON_BLACK_3), for: .normal)
            rightBtn.tag = DETAIL_BTN_TAG
            rightBtn.snp.remakeConstraints { (maker) in
                maker.right.bottom.equalTo(contentView)
                maker.width.equalTo(contentView).multipliedBy(0.5)
                maker.height.equalTo(44)
            }
            lineVer.isHidden = false
        }else{
            detailLabel.text = data.content
            let storage = TYLinkTextStorage()
            storage.textColor = HexColor(COLOR_COMMON_BLACK_3)
            storage.font = UIFont.normalFontOfSize(14)
            storage.text = "查看详情"
            detailLabel.appendTextStorage(storage)
            rightBtn.setTitle("打开推送，实时收消息", for: .normal)
            rightBtn.setTitleColor(HexColor(COLOR_COMMON_BLACK_3), for: .normal)
            rightBtn.tag = OPEN_NOTI_TAG
            rightBtn.snp.remakeConstraints { (maker) in
                maker.right.bottom.equalTo(contentView)
                maker.width.equalTo(contentView)
                maker.height.equalTo(44)
            }
            lineVer.isHidden = true
        }
        
        let height = CGFloat(detailLabel.getHeightWithWidth(220))
        
        detailLabel.snp.updateConstraints { (maker) in
            maker.height.equalTo(height)
        }
        
        contentView.snp.updateConstraints { (maker) in
            maker.height.equalTo(128 + height)
        }
    }
    
    private func dismiss() {
        self.removeFromSuperview()
    }
    
    @objc private func buttonClick(btn: BaseButton) {
        if btn.tag == ALL_BTN_TAG {
            dismiss()
            delegate?.dxwPushAlertViewAllMsg()
            Behavior.eventReport("tuisong_chakan_quanbu",isPage: false, from: "tuisong", to: data.url)
        }else if btn.tag == DETAIL_BTN_TAG {
            dismiss()
            delegate?.dxwPushAlertViewDetail(type: data.type, url: data.url, param: data.para)
            Behavior.eventReport("tuisong_chakan_neirong",isPage: false, from: "tuisong", to: data.url)
        }else if btn.tag == OPEN_NOTI_TAG {
            delegate?.dxwPushAlertViewOpenNoti()
            Behavior.eventReport("tuisong_dakai_tuisong",isPage: false, from: "tuisong", to: data.url)
        }else{
            dismiss()
            Behavior.eventReport("tuisong_guanbi_tanchuang",isPage: false, from: "tuisong", to: data.url)
        }
    }
    
    private func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageClicked textStorage: TYTextStorageProtocol!, at point: CGPoint) {
        delegate?.dxwPushAlertViewDetail(type: data.type, url: data.url, param: data.para)
        dismiss()
        Behavior.eventReport("tuisong_chakan_neirong",isPage: false, from: "tuisong", to: data.url)
    }

    private var contentView: UIView!
    private var topBar: UIImageView!
    private var detailLabel: TYAttributedLabel!
    private var leftBtn: BaseButton!
    private var rightBtn: BaseButton!
    private var lineVer: UIView!
    private var closeBtn: BaseButton!
    private let ALL_BTN_TAG = 1000
    private let DETAIL_BTN_TAG = 2000
    private let OPEN_NOTI_TAG = 3000

}
