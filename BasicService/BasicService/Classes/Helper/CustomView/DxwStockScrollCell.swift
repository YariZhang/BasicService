//
//  DxwStockScrollCell.swift
//  quchaogu
//
//  Created by zhangyr on 2018/12/25.
//  Copyright © 2018年 quchaogu. All rights reserved.
//

import UIKit

open class DxwStockScrollListData: NSObject {
    @objc open var text: String = ""
    @objc open var rank: String = ""
    @objc open var is_zx: NSNumber = false
    @objc open var color: NSNumber = 0
    @objc open var text_bg: String = ""
    @objc open var bold: NSNumber = false
    @objc open var is_yd: NSNumber = false
    @objc open var type: String = ""
    @objc open var param: DxwDic?
    @objc open var remark: String = ""
    @objc open var fixed_ext: String = ""
    @objc open var icons: NSArray?
    @objc open var next_tags: NSArray? //第二行tag
    @objc open var attr_tag: String = "" //额外tag
    @objc open var avatar: String = "" //头像
    @objc open var remark_param: DxwDic?
    
    open var config: DxwDic?
    open var isChecked: Bool = false
    public var iconTags: Array<String> {
        return icons as? Array<String> ?? Array()
    }
    public var nextTags: Array<String> {
        return next_tags as? Array<String> ?? Array()
    }
    
    public var extHeight: CGFloat {
        var height: CGFloat = 0
        if !fixed_ext.isEmpty {
            height += fixed_ext.sizeWith(attributes: [NSAttributedString.Key.font: UIFont.normalFontOfSize(13)],
                                         size: CGSize(width: SCREEN_WIDTH - 14, height: 999)).height + 10
        }
        return height
    }
    
    public var nextHeight: CGFloat {
        if !nextTags.isEmpty {
            return 15
        }else{
            return 0
        }
    }
    
    override open class func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["icons": NSString.classForCoder(), "next_tags": NSString.classForCoder()]
    }
    
    override open class func mj_ignoredPropertyNames() -> [Any]! {
        return ["config", "isChecked", "iconTags", "nextTags", "extHeight", "nextHeight"]
    }
}

@objc public protocol DxwStockScrollCellDelegate: NSObjectProtocol {
    func dxwStockScrollCellDidScroll(offsetX: CGFloat, section: Int)
    func dxwStockScrollCellDidSelectedLabel(data: DxwStockScrollListData, idxPath : NSIndexPath?)
    @objc optional func dxwStockScrollCellExtSelected(param: DxwDic)
    @objc optional func dxwStockScrollCellEditingSelected(data: DxwStockScrollListData)
    @objc optional func dxwStockScrollCellRightView(index: Int) -> UIView?
    @objc optional func dxwStockScrollCellRightViewClick(index: Int, param: DxwDic?)
    @objc optional func dxwStockScrollCellLongPress(index: Int, frame: CGRect)
}

public var STOCK_SCROLL_FRONT_WIDTH: CGFloat = 100
public var STOCK_CELL_WIDTH: CGFloat = 100

open class DxwStockScrollCell: UITableViewCell, UIScrollViewDelegate {
    
    public weak var delegate: DxwStockScrollCellDelegate?
    open var widthMulti: Array<CGFloat> = Array()
    open var offSetX: CGFloat = 0 {
        didSet {
            scrollView?.contentOffset.x = offSetX
        }
    }
    
    open var extIsHidden : Bool = false {
        didSet{
            extLabel?.isHidden = extIsHidden
        
        }
    }
    
    open var isPage: Bool = true
    
    open var needLongPress: Bool = false {
        didSet {
            if needLongPress {
                if longGr == nil {
                    longGr = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(gr:)))
                    self.addGestureRecognizer(longGr!)
                }
            }
        }
    }

    open var section: Int = 0
    
    open var index: Int = 0
    
    open var indexPath : NSIndexPath?
    
    open var values: Array<DxwStockScrollListData> = Array() {
        didSet {
            if !values.isEmpty && !isDelete {
                firstItemData = values.first
                showData()
            }
        }
    }
    
    open var fixedHeight: CGFloat = 0 {
        didSet {
            if oldValue != fixedHeight {
                relayoutViews()
            }
        }
    }
    
    open var showFixed: Bool = false {
        didSet {
            fixedExtLabel?.isHidden = !showFixed
        }
    }
    
    override open var backgroundColor: UIColor? {
        didSet {
            super.backgroundColor = backgroundColor
            frontView?.backgroundColor = backgroundColor
            rightView?.backgroundColor = backgroundColor
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        
        editingView = BaseButton()
        editingView?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 3)
        editingView?.contentHorizontalAlignment = .right
        editingView?.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        
        frontView = BaseButton()
        frontView?.highlightColor = COLOR_COMMON_SEP
        frontView?.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        
        rightView = BaseButton()
        rightView?.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        
        scrollView = UIScrollView()
        scrollView?.clipsToBounds = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.delegate = self
        self.addSubview(scrollView!)
        self.addSubview(frontView!)
        self.addSubview(editingView!)
        self.addSubview(rightView!)
        
        containView = UIView()
        scrollView?.addSubview(containView!)
        containView?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(scrollView!)
            maker.top.equalTo(scrollView!)
            maker.width.equalTo(0)
            maker.height.equalTo(scrollView!)
        })
        
        editingView?.snp.makeConstraints({ (maker) in
            maker.left.top.bottom.equalTo(self)
            maker.width.equalTo(0)
        })
        
        frontView?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(editingView!.snp.right)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
            maker.width.equalTo(STOCK_SCROLL_FRONT_WIDTH)
        })
        
        rightView?.snp.makeConstraints({ (maker) in
            maker.right.top.bottom.equalTo(self)
            maker.width.equalTo(0)
        })
        
        scrollView?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(frontView!.snp.right)
            maker.right.equalTo(rightView!.snp.left)
            maker.top.equalTo(self)
            maker.height.equalTo(self)
        })
        
        extLabel = UILabel()
        extLabel?.font = UIFont.normalFontOfSize(13)
        extLabel?.textColor = HexColor(COLOR_COMMON_BLUE)
        scrollView?.addSubview(extLabel!)
        extLabel?.snp.makeConstraints({ (maker) in
            maker.top.equalTo(self.scrollView!.snp.centerY).offset(2)
            maker.left.equalTo(scrollView!).offset(17)
            maker.height.equalTo(14)
            maker.width.equalTo(0)
        })
        
        flagIcon = UIImageView()
        flagIcon?.isHidden = true
        flagIcon?.image = UIImage(named: "main_move_tag")
        frontView?.addSubview(flagIcon!)
        flagIcon?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(frontView!)
            maker.top.equalTo(frontView!)
        })
        
        nameLabel = UILabel()
        nameLabel?.font = UIFont.normalFontOfSize(17)
        frontView?.addSubview(nameLabel!)
        nameLabel?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(frontView!).offset(7)
            maker.top.equalTo(frontView!).offset(15)
            maker.height.equalTo(17)
        })
        
        codeLabel = UILabel()
        codeLabel?.font = UIFont.normalFontOfSize(10)
        frontView?.addSubview(codeLabel!)
        codeLabel?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(frontView!).offset(7)
            maker.top.equalTo(nameLabel!.snp.bottom).offset(4)
            maker.height.equalTo(10)
        })
        
        tagImg = UIImageView()
        frontView?.addSubview(tagImg!)
        tagImg?.snp.makeConstraints { (maker) in
            maker.left.equalTo(codeLabel!.snp.right).offset(2)
            maker.centerY.equalTo(codeLabel!)
            maker.width.equalTo(0)
            maker.height.equalTo(0)
        }
        
        nextTag = UIImageView()
        frontView?.addSubview(nextTag!)
        nextTag?.snp.makeConstraints { (maker) in
            maker.left.equalTo(codeLabel!.snp.right).offset(2)
            maker.top.equalTo(codeLabel!.snp.bottom).offset(3)
            maker.width.equalTo(0)
            maker.height.equalTo(0)
        }
        
        lineBot = UIView()
        self.addSubview(lineBot!)
        lineBot?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.bottom.equalTo(self)
            maker.height.equalTo(0.5)
        })
        
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(labelSelected(gr:)))
        scrollView?.addGestureRecognizer(tapGr)
    }
    
    @objc private func longPressHandle(gr: UILongPressGestureRecognizer) {
        if gr.state == .began {
            delegate?.dxwStockScrollCellLongPress?(index: index, frame: self.frame)
        }
    }
    
    @objc private func labelSelected(gr: UITapGestureRecognizer) {
        let location = gr.location(in: scrollView!)
        if extLabel!.frame.contains(location) && extPara != nil {
            delegate?.dxwStockScrollCellExtSelected?(param: extPara!)
            return
        }
        if containView!.frame.contains(location) {
            let loc = gr.location(in: containView!)
            for v in containView!.subviews {
                if v.frame.contains(loc) && v is DxwStockScrollCellItemView {
                    if v.tag < values.count && (values[v.tag].type == "page" || checkTextHighlight(data: values[v.tag], width: v.bounds.width * 2)) {
                        delegate?.dxwStockScrollCellDidSelectedLabel(data: values[v.tag], idxPath: indexPath)
                    }else{
                        if let d = frontView?.tmpData as? DxwStockScrollListData, !d.type.isEmpty {
                            delegate?.dxwStockScrollCellDidSelectedLabel(data: d, idxPath: indexPath)
                        }
                    }
                    break
                }
            }
        }
    }
    
    private func relayoutViews() {
        self.backgroundColor = HexColor(COLOR_COMMON_WHITE)
        frontView?.snp.remakeConstraints({ (maker) in
            maker.left.equalTo(self)
            maker.top.equalTo(self)
            maker.height.equalTo(fixedHeight)
            maker.width.equalTo(STOCK_SCROLL_FRONT_WIDTH)
        })
        
        scrollView?.snp.remakeConstraints({ (maker) in
            maker.left.equalTo(frontView!.snp.right)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.height.equalTo(fixedHeight)
        })
        
        nameLabel?.snp.remakeConstraints({ (maker) in
            maker.left.equalTo(frontView!).offset(7)
            maker.top.equalTo(frontView!).offset(12)
            maker.height.equalTo(16)
        })
        
        codeLabel?.snp.remakeConstraints({ (maker) in
            maker.left.equalTo(frontView!).offset(7)
            maker.top.equalTo(nameLabel!.snp.bottom).offset(4)
            maker.height.equalTo(10)
        })
        
        shadowView?.isHidden = true
        
        if lineBot == nil {
            lineBot = UIView()
            lineBot?.backgroundColor = HexColor(COLOR_COMMON_SEP)
            self.addSubview(lineBot!)
            lineBot?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(self)
                maker.right.equalTo(self)
                maker.bottom.equalTo(self)
                maker.height.equalTo(0.5)
            })
        }
        
        if fixedExtLabel == nil {
            fixedExtLabel = UILabel()
            fixedExtLabel?.font = UIFont.normalFontOfSize(13)
            fixedExtLabel?.textColor = HexColor("#757575")
            fixedExtLabel?.numberOfLines = 0
            self.addSubview(fixedExtLabel!)
            fixedExtLabel?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(self).offset(7)
                maker.right.equalTo(self).offset(-7)
                maker.bottom.equalTo(self).offset(-10)
            })
        }
    }
    
    private func showData() {
        guard !values.isEmpty else {
            return
        }
        
        for v in rightView?.subviews ?? [] {
            v.removeFromSuperview()
        }
        
        if let tmpV = delegate?.dxwStockScrollCellRightView?(index: index) {
            rightView?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(tmpV.frame.width)
            })
            
            rightView?.addSubview(tmpV)
            tmpV.snp.makeConstraints({ (maker) in
                maker.edges.equalTo(rightView!)
            })
        }
        
        var needMulti = false
        var tmpWidth: CGFloat = 0
        if widthMulti.count == values.count && !widthMulti.isEmpty {
            needMulti = true
            tmpWidth = widthMulti.removeFirst()
        }
        if needMulti {
            frontView?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(tmpWidth * STOCK_CELL_WIDTH)
            })
        }else{
            frontView?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(STOCK_SCROLL_FRONT_WIDTH)
            })
        }
        isDelete = true
        let firstItem = values.removeFirst()
        isDelete = false
        extPara = firstItem.remark_param
        frontView?.tmpData = firstItem
        flagIcon?.isHidden = !firstItem.is_yd.boolValue
        let nameArr = firstItem.text.components(separatedBy: "#")
        if nameArr.count >= 2 {
            nameLabel?.text = nameArr[0]
            switch firstItem.color {
            case 0:
                nameLabel?.textColor = HexColor(COLOR_COMMON_BLACK_3)
                break
            case 1:
                nameLabel?.textColor = HexColor(COLOR_COMMON_RED)
                break
            case 2:
                nameLabel?.textColor = HexColor(COLOR_COMMON_GREEN)
                break
            case 3:
                nameLabel?.textColor = HexColor(COLOR_COMMON_BLACK_9)
                break
            default:
                nameLabel?.textColor = HexColor(COLOR_COMMON_ORANGE_FF98)
                break
            }
            codeLabel?.text = nameArr[1]
        }else{
            nameLabel?.snp.remakeConstraints({ (maker) in
                maker.centerY.equalTo(frontView!)
                maker.left.equalTo(frontView!).offset(7)
            })
            
            nameLabel?.text = firstItem.text
        }
        
        if firstItem.iconTags.isEmpty {
            tagImg?.image = nil
        }else{
            tagImg?.sd_setImage(with: URL(string: firstItem.iconTags.first + ""), completed: { (image, error, type, url) in
                if image != nil {
                    self.tagImg?.image = image
                    self.tagImg?.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(image!.size.width / 3)
                        maker.height.equalTo(image!.size.height / 3)
                    })
                }else{
                    self.tagImg?.image = nil
                }
            })
        }
        
        if firstItem.nextTags.isEmpty {
            nextTag?.image = nil
        }else{
            nextTag?.sd_setImage(with: URL(string: firstItem.nextTags.first + ""), completed: { (image, error, type, url) in
                if image != nil {
                    self.nextTag?.image = image
                    self.nextTag?.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(image!.size.width / 3)
                        maker.height.equalTo(image!.size.height / 3)
                    })
                }else{
                    self.nextTag?.image = nil
                }
            })
        }
        
        
        if values.count <= items.count {
            for i in 0 ..< values.count {
                let label = items[i]
                let md = values[i]
                if let color = md.config?["bg_color"] as? String {
                    label.backgroundColor = HexColor(color)
                }else{
                    label.backgroundColor = UIColor.clear
                }
                let value = md.text
                label.tag = i
                label.isBold = md.bold.boolValue
                
                var tc: UIColor = HexColor(COLOR_COMMON_BLACK_3)
                if !md.text_bg.isEmpty {
                    tc = HexColor("#fff")
                    var bgView: UIView!
                    if let bgV = containView?.viewWithTag(10000 + i) {
                        bgView = bgV
                    }else{
                        bgView = UIView()
                        bgView.tag = 10000 + i
                        containView?.addSubview(bgView)
                        bgView.snp.makeConstraints({ (maker) in
                            maker.center.equalTo(label)
                            maker.width.equalTo(0)
                            maker.height.equalTo(0)
                        })
                        containView?.bringSubviewToFront(label)
                    }
                    bgView.backgroundColor = HexColor(md.text_bg)
                    let size = md.text.sizeWith(attributes: [NSAttributedString.Key.font : label.font])
                    bgView.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(size.width + 10)
                        maker.height.equalTo(size.height + 6)
                    })
                }else{
                    if let bgV = containView?.viewWithTag(10000 + i) {
                        bgV.backgroundColor = UIColor.clear
                    }
                    switch md.color {
                    case 0:
                        tc = HexColor(COLOR_COMMON_BLACK_3)
                        break
                    case 1:
                        tc = HexColor(COLOR_COMMON_RED)
                        break
                    case 2:
                        tc = HexColor(COLOR_COMMON_GREEN)
                        break
                    case 3:
                        tc = HexColor(COLOR_COMMON_BLACK_9)
                        break
                    default:
                        tc = value.hasSuffix("%") ? (value.hasPrefix("+") ? HexColor(COLOR_COMMON_RED) : (value.hasPrefix("-") ? HexColor(COLOR_COMMON_GREEN) : HexColor(COLOR_COMMON_BLACK_3))) : HexColor(COLOR_COMMON_BLACK_9)
                        break
                    }
                }
                label.textColor = tc
                
                if needMulti {
                    label.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(widthMulti[i] * STOCK_CELL_WIDTH)
                    })
                }else{
                    label.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(STOCK_CELL_WIDTH)
                    })
                }
                
                if checkTextHighlight(data: md, width: (needMulti ? widthMulti[i] * STOCK_CELL_WIDTH : STOCK_CELL_WIDTH) * 2) {
                    label.textColor = HexColor(COLOR_COMMON_BLUE)
                }
                
                label.showData(text: value, avatar: md.avatar, attrTag: md.attr_tag)
                if value.contains("\n") {
                    label.textColor = HexColor(COLOR_COMMON_BLACK_3)
                    let sub = value.components(separatedBy: "\n").last + ""
                    label.attributedText = value.addAttributeToSubString(sub, withAttributes: [NSAttributedString.Key.foregroundColor: tc])
                }
            }
            
            for i in values.count ..< items.count {
                let label = items[i]
                label.showData(text: "", avatar: "", attrTag: "")
            }
            
        }else{
            for i in 0 ..< items.count {
                let label = items[i]
                let md = values[i]
                if let color = md.config?["bg_color"] as? String {
                    label.backgroundColor = HexColor(color)
                }else{
                    label.backgroundColor = UIColor.clear
                }
                let value = md.text
                label.tag = i
                label.isBold = md.bold.boolValue
                var tc: UIColor = HexColor(COLOR_COMMON_BLACK_3)
                if !md.text_bg.isEmpty {
                    tc = HexColor("#fff")
                    var bgView: UIView!
                    if let bgV = containView?.viewWithTag(10000 + i) {
                        bgView = bgV
                    }else{
                        bgView = UIView()
                        bgView.tag = 10000 + i
                        containView?.addSubview(bgView)
                        bgView.snp.makeConstraints({ (maker) in
                            maker.center.equalTo(label)
                            maker.width.equalTo(0)
                            maker.height.equalTo(0)
                        })
                        containView?.bringSubviewToFront(label)
                    }
                    bgView.backgroundColor = HexColor(md.text_bg)
                    let size = md.text.sizeWith(attributes: [NSAttributedString.Key.font : label.font])
                    bgView.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(size.width + 10)
                        maker.height.equalTo(size.height + 6)
                    })
                }else{
                    if let bgV = containView?.viewWithTag(10000 + i) {
                        bgV.backgroundColor = UIColor.clear
                    }
                    switch md.color {
                    case 0:
                        tc = HexColor(COLOR_COMMON_BLACK_3)
                        break
                    case 1:
                        tc = HexColor(COLOR_COMMON_RED)
                        break
                    case 2:
                        tc = HexColor(COLOR_COMMON_GREEN)
                        break
                    case 3:
                        tc = HexColor(COLOR_COMMON_BLACK_9)
                        break
                    default:
                        tc = value.hasSuffix("%") ? (value.hasPrefix("+") ? HexColor(COLOR_COMMON_RED) : (value.hasPrefix("-") ? HexColor(COLOR_COMMON_GREEN) : HexColor(COLOR_COMMON_BLACK_3))) : HexColor(COLOR_COMMON_BLACK_9)
                        break
                    }
                }
                label.textColor = tc
                
                if needMulti {
                    label.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(widthMulti[i] * STOCK_CELL_WIDTH)
                    })
                }else{
                    label.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(STOCK_CELL_WIDTH)
                    })
                }
                
                if checkTextHighlight(data: md, width: (needMulti ? widthMulti[i] * STOCK_CELL_WIDTH : STOCK_CELL_WIDTH) * 2) {
                    label.textColor = HexColor(COLOR_COMMON_BLUE)
                }
                label.showData(text: value, avatar: md.avatar, attrTag: md.attr_tag)
                if value.contains("\n") {
                    label.textColor = HexColor(COLOR_COMMON_BLACK_3)
                    let sub = value.components(separatedBy: "\n").last + ""
                    label.attributedText = value.addAttributeToSubString(sub, withAttributes: [NSAttributedString.Key.foregroundColor: tc])
                }
            }
            
            
            var mas = containView!.snp.left
            if !items.isEmpty {
                mas = items.last!.snp.right
            }
            
            for i in items.count ..< values.count {
                let md = values[i]
                let value = md.text
                let label = DxwStockScrollCellItemView()
                label.tag = i
                containView?.addSubview(label)
                
                if let color = md.config?["bg_color"] as? String {
                    label.backgroundColor = HexColor(color)
                }else{
                    label.backgroundColor = UIColor.clear
                }
                
                label.isBold = md.bold.boolValue
    
                var tc: UIColor = HexColor(COLOR_COMMON_BLACK_3)
                if !md.text_bg.isEmpty {
                    tc = HexColor("#fff")
                    var bgView: UIView!
                    if let bgV = containView?.viewWithTag(10000 + i) {
                        bgView = bgV
                    }else{
                        bgView = UIView()
                        bgView.tag = 10000 + i
                        containView?.addSubview(bgView)
                        bgView.snp.makeConstraints({ (maker) in
                            maker.center.equalTo(label)
                            maker.width.equalTo(0)
                            maker.height.equalTo(0)
                        })
                        containView?.bringSubviewToFront(label)
                    }
                    bgView.backgroundColor = HexColor(md.text_bg)
                    let size = md.text.sizeWith(attributes: [NSAttributedString.Key.font : label.font])
                    bgView.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(size.width + 10)
                        maker.height.equalTo(size.height + 6)
                    })
                }else{
                    if let bgV = containView?.viewWithTag(10000 + i) {
                        bgV.backgroundColor = UIColor.clear
                    }
                    switch md.color {
                    case 0:
                        tc = HexColor(COLOR_COMMON_BLACK_3)
                        break
                    case 1:
                        tc = HexColor(COLOR_COMMON_RED)
                        break
                    case 2:
                        tc = HexColor(COLOR_COMMON_GREEN)
                        break
                    case 3:
                        tc = HexColor(COLOR_COMMON_BLACK_9)
                        break
                    default:
                        tc = value.hasSuffix("%") ? (value.hasPrefix("+") ? HexColor(COLOR_COMMON_RED) : (value.hasPrefix("-") ? HexColor(COLOR_COMMON_GREEN) : HexColor(COLOR_COMMON_BLACK_3))) : HexColor(COLOR_COMMON_BLACK_9)
                        break
                    }
                }
                label.textColor = tc
                
                if checkTextHighlight(data: md, width: (needMulti ? widthMulti[i] * STOCK_CELL_WIDTH : STOCK_CELL_WIDTH) * 2) {
                    label.textColor = HexColor("#2371e9")
                }
                
                label.snp.makeConstraints({ (maker) in
                    maker.left.equalTo(mas)
                    maker.top.equalTo(containView!)
                    maker.height.equalTo(containView!)
                    if needMulti {
                        maker.width.equalTo(widthMulti[i] * STOCK_CELL_WIDTH)
                    }else{
                        maker.width.equalTo(STOCK_CELL_WIDTH)
                    }
                })
                
                items.append(label)
                mas = label.snp.right
                
                label.showData(text: value, avatar: md.avatar, attrTag: md.attr_tag)
                
                if value.contains("\n") {
                    label.textColor = HexColor(COLOR_COMMON_BLACK_3)
                    let sub = value.components(separatedBy: "\n").last + ""
                    label.attributedText = value.addAttributeToSubString(sub, withAttributes: [NSAttributedString.Key.foregroundColor: tc])
                }
            }
        }
        
        var sWidth: CGFloat = 0
        if needMulti {
            sWidth = widthMulti.reduce(0, {$0 + $1}) * STOCK_CELL_WIDTH
        }else{
            sWidth = CGFloat(values.count) * STOCK_CELL_WIDTH
        }
        scrollView?.contentSize = CGSize(width: sWidth , height: 0)
        containView?.snp.updateConstraints({ (maker) in
            maker.width.equalTo(sWidth)
        })
        if firstItem.remark.isEmpty {
            if !(extLabel?.text + "").isEmpty {
                containView?.snp.updateConstraints({ (maker) in
                    maker.height.equalTo(scrollView!)
                })
            }
        }else{
            extLabel?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(sWidth - 12)
            })
            if (extLabel?.text + "").isEmpty {
                containView?.snp.updateConstraints({ (maker) in
                    maker.height.equalTo(scrollView!).offset(-18)
                })
            }
        }
        if firstItem.remark.isMatch("<[^>]+>", options: NSRegularExpression.Options.caseInsensitive) {
            if let d = firstItem.remark.data(using: String.Encoding.unicode) {
                do {
                    extLabel?.attributedText = try NSAttributedString(data: d, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                }catch{
                    extLabel?.text = firstItem.remark
                }
            }else{
                extLabel?.text = firstItem.remark
            }
        }else{
            extLabel?.text = firstItem.remark
        }
        
        fixedExtLabel?.text = firstItem.fixed_ext
        
    }
    
    private func checkTextHighlight(data: DxwStockScrollListData?, width: CGFloat = STOCK_CELL_WIDTH * 2) -> Bool {
        if data == nil {
            return false
        }
        
        if !data!.type.isEmpty {
            if data!.type == "ext" {
                let size = NSString(string: data!.text).boundingRect(with: CGSize(width: 999, height: 999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.normalFontOfSize(16)], context: nil)
                return size.width > width
            }else if data!.type == "page" && !isPage {
                return false
            }else{
                return isPage
            }
        }
        return false
    }
    
    @objc private func buttonClick(btn: BaseButton) {
        if btn == editingView {
            guard firstItemData != nil else {
                return
            }
            firstItemData.isChecked = !firstItemData.isChecked
            if firstItemData.isChecked {
                editingView?.setImage(UIImage(named: "zixuan_edit_radio_sel"), for: .normal)
            }else{
                editingView?.setImage(UIImage(named: "zixuan_edit_radio_normal"), for: .normal)
            }
            delegate?.dxwStockScrollCellEditingSelected?(data: firstItemData)
        }else if btn == rightView {
            delegate?.dxwStockScrollCellRightViewClick?(index: index, param: firstItemData.param)
        }else{
            if let d = btn.tmpData as? DxwStockScrollListData, !d.type.isEmpty {
                delegate?.dxwStockScrollCellDidSelectedLabel(data: d, idxPath: indexPath)
            }
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.dxwStockScrollCellDidScroll(offsetX: scrollView.contentOffset.x, section: section)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollBeginX = scrollView.contentOffset.x
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentX = scrollView.contentOffset.x
        if currentX > scrollBeginX {
            Behavior.eventReport("huadong", isPage: false, from: (delegate as? BaseViewController)?.getFrom() + "", to: (delegate as? BaseViewController)?.getVcId() + "")
        }
        scrollBeginX = currentX
    }
    
    override open func setEditing(_ editing: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.editingView?.snp.updateConstraints({ (maker) in
                    maker.width.equalTo(editing ? 45 : 0)
                })
                self.layoutIfNeeded()
            })
        }else{
            editingView?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(editing ? 45 : 0)
            })
        }
        scrollView?.isScrollEnabled = !editing
    }
    
    private var editingView: BaseButton?
    private var frontView: BaseButton?
    private var rightView: BaseButton?
    private var flagIcon: UIImageView?
    private var nameLabel: UILabel?
    private var codeLabel: UILabel?
    private var tagImg: UIImageView?
    private var nextTag: UIImageView?
    private var shadowView: UIImageView?
    private var scrollView: UIScrollView?
    private var containView: UIView?
    private var extLabel: UILabel?
    private var fixedExtLabel: UILabel?
    private var lineBot: UIView?
    private var isDelete: Bool = false
    private var firstItemData: DxwStockScrollListData! {
        didSet {
            if firstItemData.is_zx.boolValue {
                editingView?.setImage(UIImage(named: "zixuan_edit_radio_disable"), for: .normal)
                editingView?.isUserInteractionEnabled = false
            }else{
                if firstItemData.isChecked {
                    editingView?.setImage(UIImage(named: "zixuan_edit_radio_sel"), for: .normal)
                }else{
                    editingView?.setImage(UIImage(named: "zixuan_edit_radio_normal"), for: .normal)
                }
                editingView?.isUserInteractionEnabled = true
            }
        }
    }
    private var items: Array<DxwStockScrollCellItemView> = Array()
    private var extPara: DxwDic?
    private var scrollBeginX: CGFloat = -100
    private var longGr: UILongPressGestureRecognizer?
}

class DxwStockScrollCellItemView: BaseView {
    var font: UIFont { return label.font}
    var textColor: UIColor? {
        didSet {
            label.textColor = textColor
        }
    }
    var attributedText: NSAttributedString? {
        didSet {
            label.attributedText = attributedText
        }
    }
    var isBold: Bool = false {
        didSet {
            if isBold {
                label.font = UIFont.boldFontOfSize(label.font.pointSize)
            }else{
                label.font = UIFont.normalFontOfSize(label.font.pointSize)
            }
        }
    }
    override func initUI() {
        super.initUI()
        avatarImg = UIImageView()
        avatarImg.layer.cornerRadius = 13
        avatarImg.layer.masksToBounds = true
        self.addSubview(avatarImg)
        avatarImg.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.centerY.equalTo(self)
            maker.width.equalTo(0)
            maker.height.equalTo(0)
        }
        
        label = UILabel()
        label.font = UIFont.normalFontOfSize(16)
        label.textAlignment = .center
        label.numberOfLines = 2
        self.addSubview(label)
        label.snp.makeConstraints { (maker) in
            maker.left.equalTo(avatarImg.snp.right)
            maker.right.equalTo(self)
            maker.centerY.equalTo(self)
        }
    }
    
    func showData(text: String, avatar: String, attrTag: String) {
        label.text = text
        if avatar.isEmpty {
            avatarImg.image = nil
            avatarImg.snp.updateConstraints { (maker) in
                maker.width.height.equalTo(0)
            }
            label.textAlignment = .center
        }else{
            avatarImg.sd_setImage(with: URL(string: avatar)) { (image, error, type, url) in
                if image != nil {
                    self.avatarImg.image = image
                    self.avatarImg.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(26)
                        maker.height.equalTo(26)
                    })
                    self.label.snp.updateConstraints({ (maker) in
                        maker.left.equalTo(self.avatarImg.snp.right).offset(5)
                    })
                    self.label.textAlignment = .left
                }else{
                    self.avatarImg.image = nil
                    self.avatarImg.snp.updateConstraints { (maker) in
                        maker.width.height.equalTo(0)
                    }
                    self.label.snp.updateConstraints({ (maker) in
                        maker.left.equalTo(self.avatarImg.snp.right)
                    })
                    self.label.textAlignment = .center
                }
            }
        }
        
        if attrTag.isEmpty {
            self.attriImg?.image = nil
            self.attriImg?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(0)
                maker.height.equalTo(0)
            })
            
            self.label.snp.updateConstraints({ (maker) in
                maker.centerY.equalTo(self)
            })
        }else{
            if attriImg == nil {
                attriImg = UIImageView()
                self.addSubview(attriImg!)
                attriImg?.snp.makeConstraints({ (maker) in
                    maker.centerX.equalTo(label)
                    maker.top.equalTo(label.snp.centerY).offset(12)
                    maker.width.equalTo(0)
                    maker.height.equalTo(0)
                })
            }
            
            attriImg?.sd_setImage(with: URL(string: attrTag), completed: { (image, error, type, url) in
                if image != nil {
                    self.attriImg?.image = image
                    self.attriImg?.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(image!.size.width / 3)
                        maker.height.equalTo(image!.size.height / 3)
                    })
                    
                    self.label.snp.updateConstraints({ (maker) in
                        maker.centerY.equalTo(self).offset(-8)
                    })
                }else{
                    self.attriImg?.image = nil
                    self.attriImg?.snp.updateConstraints({ (maker) in
                        maker.width.equalTo(0)
                        maker.height.equalTo(0)
                    })
                    
                    self.label.snp.updateConstraints({ (maker) in
                        maker.centerY.equalTo(self)
                    })
                }
            })
        }
    }
    
    private var avatarImg: UIImageView!
    private var label: UILabel!
    private var attriImg: UIImageView?
}
