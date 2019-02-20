//
//  SelectedSegmentedBar.swift
//  quchaogu
//
//  Created by zhangyr on 15/6/23.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit

@objc public protocol SelectedSegmentedBarDelegate : NSObjectProtocol {
    func selectedItemForSegmentedBar(_ segmentedBar : SelectedSegmentedBar , selectedSegmentedIndex : Int)
    @objc optional func selectedItemIndexChanged(_ segmentedBar : SelectedSegmentedBar, current index: Int)
}

public class SelectedSegmentedBar: UIView {
    
    public weak var delegate : SelectedSegmentedBarDelegate?
    public var endBtn : UIButton?
    public var tabCount : Int = 0
    private var lastBtn : UIButton!
    private var selectedLabel : UILabel?
    private var needCall : Bool = true
    
    private var needTag: Bool = false
    private var img: UIImageView?
    
    private var styleView: UIView?
    private var attriArray: Array<Dictionary<String, Any>?> = Array()
    
    public var index : Int {
        set {
            if index != newValue {
                if let btn = self.viewWithTag(newValue + 100) as? BaseButton {
                    needCall         = false
                    selectedItem(btn)
                }
                _index  = newValue
            }else{
                if let btn = self.viewWithTag(newValue + 100) as? BaseButton {
                    selectedItem(btn, needAni: false, needCall: false)
                }
            }
        }
        
        get{
            return _index
        }
    }
    
    public var bgColor: UIColor?
    
    private var _index : Int = 0 {
        didSet {
            if _index != oldValue {
                delegate?.selectedItemIndexChanged?(self, current: _index)
            }
        }
    }
    private var font: UIFont = UIFont.boldFontOfSize(16)
    private var line: UIView?
    public var selectedColor: UIColor = HexColor(COLOR_COMMON_BASE_NAVI)
    public var normalColor: UIColor = HexColor(COLOR_COMMON_BLACK_3)
    
    public func setIndex(index: Int, needCall : Bool, needAni: Bool = true) {
        if index != self.index {
            _index = index
            self.needCall = needCall
            if let btn = self.viewWithTag(_index + 100) as? BaseButton {
                selectedItem(btn, needAni: needAni, needCall: needCall)
            }
        }
    }
    
    public func setTitleAt(index: Int, title: Any) {
        if let btn = self.viewWithTag(index + 100) as? BaseButton {
            if let t = title as? String {
                btn.setTitle(t, for: .normal)
            }else if let at = title as? NSAttributedString {
                btn.setAttributedTitle(at, for: .normal)
            }
        }
    }
    
    public func setTitleAttrAt(index: Int, title: String, attr: [NSAttributedString.Key : Any]) {
        attriArray[index] = ["t_attr": title, "attris": attr]
    }
    
    /*1.2.0 增加item图片在右边显示 */
    public init(frame: CGRect , items : [Any] ,itemImages : [String] = [] ,delegate : SelectedSegmentedBarDelegate?, needFixText: Bool = false, isMain: Bool = false, isMultiStyle: Bool = false, fontNum : CGFloat = 16, needBold : Bool = false, normalColor : UIColor = HexColor(COLOR_COMMON_BLACK_3), selectedColor : UIColor = HexColor(COLOR_COMMON_BASE_NAVI), needSplit: Bool = false, needSelLine: Bool = true) {
        super.init(frame: frame)
        self.delegate = delegate
        self.backgroundColor = HexColor(COLOR_COMMON_TAB)
        self.selectedColor = selectedColor
        self.normalColor = normalColor
        self.tabCount = items.count
        if items.isEmpty {
            return
        }
        
        for _ in items {
            attriArray.append(nil)
        }
        
        if needBold {
            font = UIFont.boldFontOfSize(fontNum)
        }else{
            font = UIFont.normalFontOfSize(fontNum)
        }
        
        let btnH = frame.size.height - 2
        if isMultiStyle && (items.count <= 3 || items.count >= 2) {
            styleView = UIView()
            styleView?.backgroundColor = HexColor("#006cf1")
            styleView?.layer.cornerRadius = 2
            styleView?.layer.masksToBounds = true
            self.addSubview(styleView!)
            styleView?.snp.makeConstraints({ (maker) in
                maker.center.equalTo(self)
                maker.height.equalTo(26)
                maker.width.equalTo(75 * CGFloat(items.count))
            })
            
            var mas = styleView!.snp.left
            for i in 0 ..< items.count {
                let btn = BaseButton()
                btn.tag = i + 100
                btn.setTitle(items[i] as? String, for: UIControl.State())
                btn.titleLabel?.font = font
                btn.setTitleColor(normalColor, for: UIControl.State())
                btn.titleLabel?.textColor = normalColor
                if i == 0 {
                    btn.setTitleColor(selectedColor, for: UIControl.State())
                    btn.backgroundColor = HexColor("#fff")
                    lastBtn = btn
                }
                btn.addTarget(self, action: #selector(SelectedSegmentedBar.selectedItemByClick(_:)), for: UIControl.Event.touchUpInside)
                styleView?.addSubview(btn)
                btn.snp.makeConstraints({ (maker) in
                    maker.left.equalTo(mas)
                    maker.top.equalTo(styleView!)
                    maker.bottom.equalTo(styleView!)
                    maker.width.equalTo(75)
                })
                mas = btn.snp.right
                if i == items.count - 1{
                    endBtn = btn
                }
            }
            
        }else{
            var wArray = [CGFloat]()
            if let its = items as? [String], needFixText {
                wArray = getWidthArray(items: its, baseWidth: frame.size.width)
            }else{
                let btnW = frame.size.width / CGFloat(items.count)
                for _ in items {
                    wArray.append(btnW)
                }
            }
            
            for i in 0 ..< items.count {
                let btn = BaseButton(frame: CGRect(x: getXValue(index: i, values: wArray), y: 0, width: wArray[i], height: btnH))
                btn.tag = i + 100
                btn.setTitle(items[i] as? String, for: UIControl.State())
                btn.titleLabel?.font = font
                btn.setTitleColor(normalColor, for: UIControl.State())
                btn.titleLabel?.textColor = normalColor
                if i == 0 {
                    btn.setTitleColor(selectedColor, for: UIControl.State())
                    lastBtn = btn
                }
                btn.addTarget(self, action: #selector(SelectedSegmentedBar.selectedItemByClick(_:)), for: UIControl.Event.touchUpInside)
                self.addSubview(btn)
                
                if i < itemImages.count {
                    let imageStr = itemImages[i]
                    let itemStr = items[i] as? String
                    let itemStrWidth = itemStr?.sizeWith(attributes: [NSAttributedString.Key.font : font])
                    if imageStr.count > 0 {
                        let itemImage = UIImage(named:imageStr)
                        let itemImageView = UIImageView()
                        itemImageView.image = itemImage
                        btn.addSubview(itemImageView)
                        
                        itemImageView.snp.makeConstraints({ (maker) in
                            maker.centerX.equalTo(btn).offset((itemStrWidth?.width)!/2 + 15)
                            maker.centerY.equalTo(btn)
                            maker.width.equalTo((itemImage?.size.width)!)
                            maker.height.equalTo((itemImage?.size.height)!)
                        })
                    }
                }
                
                if needSplit && i < items.count - 1 {
                    let spLine = UIView()
                    spLine.backgroundColor = HexColor(COLOR_COMMON_SEP)
                    btn.addSubview(spLine)
                    spLine.snp.makeConstraints({ (maker) in
                        maker.right.equalTo(btn)
                        maker.centerY.equalTo(btn)
                        maker.width.equalTo(0.5)
                        maker.height.equalTo(13)
                    })
                }
            }
        }
        
        if !isMain {
            line = UIView(frame: CGRect(x: 0, y: btnH + 1.5, width: frame.size.width, height: 0.5))
            line?.backgroundColor = HexColor(COLOR_COMMON_SEP)
            self.addSubview(line!)
        }
        
        selectedLabel = UILabel(frame: CGRect(x: 0, y: btnH, width: 32, height: 2))
        selectedLabel?.backgroundColor = selectedColor
        self.addSubview(selectedLabel!)
        selectedLabel?.center = CGPoint(x: lastBtn.center.x, y: selectedLabel?.center.y ?? 0)
        
        if needSplit || !needSelLine {
            selectedLabel?.isHidden = true
        }
    }
    
    @objc func selectedItemByClick(_ btn : UIButton) {
        self.selectedItem(btn, needAni: true)
    }
    
    func selectedItem(_ btn : UIButton, needAni : Bool = true, needCall : Bool = false) {
        
        func selecteBtn() {
            let btnStr = btn.attributedTitle(for: .normal)?.string + ""
            if btnStr.contains("精选") {
                btn.setTitleColor(HexColor("#ff9800"), for: UIControl.State())
                btn.titleLabel?.textColor = HexColor("#ff9800")
            }else{
                btn.setTitleColor(self.selectedColor, for: UIControl.State())
                btn.titleLabel?.textColor = selectedColor
            }
            let bIdx = btn.tag - 100
            if bIdx < attriArray.count && attriArray[bIdx] != nil {
                btn.setAttributedTitle(btnStr.addAttributeToSubString(attriArray[bIdx]?["t_attr"] + "", withAttributes: attriArray[bIdx]?["attris"] as? [NSAttributedString.Key : Any] ?? [:]), for: .normal)
            }
            if btn.image(for: .normal) != nil {
                btn.setImage(UIImage(named: "main_event_tab_filter"), for: .normal)
            }
            let oldBtnStr = lastBtn.attributedTitle(for: .normal)?.string + ""
            if oldBtnStr.contains("精选") {
                lastBtn.setTitleColor(HexColor("#ff9800"), for: UIControl.State())
                lastBtn.titleLabel?.textColor = HexColor("#ff9800")
            }else{
                lastBtn.setTitleColor(self.normalColor, for: UIControl.State())
                lastBtn.titleLabel?.textColor = normalColor
            }
            let lIdx = lastBtn.tag - 100
            if lIdx < attriArray.count && attriArray[lIdx] != nil {
                lastBtn.setAttributedTitle(oldBtnStr.addAttributeToSubString(attriArray[lIdx]?["t_attr"] + "", withAttributes: attriArray[lIdx]?["attris"] as? [NSAttributedString.Key : Any] ?? [:]), for: .normal)
            }
            lastBtn = btn
            if self.needCall {
                self.delegate?.selectedItemForSegmentedBar(self, selectedSegmentedIndex: btn.tag - 100)
            }else{
                self.needCall = true
            }
        }
        
        if btn !== lastBtn{
            self._index = btn.tag - 100
            if styleView != nil {
                btn.backgroundColor = HexColor("#fff")
                lastBtn.backgroundColor = UIColor.clear
            }
            if needAni {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.selectedLabel?.center = CGPoint(x: btn.center.x, y: self.selectedLabel?.center.y ?? 0)
                }, completion: { (Bool) -> Void in
                    selecteBtn()
                })
            }else{
                self.selectedLabel?.center = CGPoint(x: btn.center.x, y: self.selectedLabel?.center.y ?? 0)
                selecteBtn()
            }
        }
    }
    
    //MARK: segment bar 获取数组宽度
    private func getWidthArray(items : [String], baseWidth : CGFloat = SCREEN_WIDTH) -> [CGFloat]
    {
        var totalLength     : CGFloat               = 0
        var fontWidthArray  : Array<CGFloat>        = [CGFloat]()
        for item in items
        {
            let width       = item.sizeWith(attributes: [.font : UIFont.normalFontOfSize(16)]).width
            fontWidthArray.append(width)
            totalLength     += width
        }
        
        var lengthArray     = [CGFloat]()
        for value in fontWidthArray
        {
            lengthArray.append((value / totalLength) * baseWidth)
        }
        
        return lengthArray
    }
    
    private func getXValue(index : Int, values : [CGFloat]) -> CGFloat
    {
        if index > values.count
        {
            return 0
        }
        
        var value : CGFloat     = 0
        
        for i in 0 ..< index
        {
            value += values[i]
        }
        
        return value
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
