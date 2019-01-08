//
//  DxwStockScrollHeadView.swift
//  quchaogu
//
//  Created by zhangyr on 2018/12/25.
//  Copyright © 2018年 quchaogu. All rights reserved.
//

import UIKit

@objc public protocol DxwStockScrollHeadViewDelegate: NSObjectProtocol {
    func dxwStockScrollHeadViewSorted(section: Int, index: Int, ad: String)
    func dxwStockScrollHeadViewFiltered(section: Int, index: Int, filter: Array<Dictionary<String, Any>>)
    @objc optional func dxwStockScrollHeadViewFrontExtraView(headView: DxwStockScrollHeadView) -> UIView?
    @objc optional func dxwStockScrollHeadViewRightView(headView: DxwStockScrollHeadView) -> UIView?
}

open class DxwStockScrollHeadView: BaseView, DxwStockSortViewDelegate {
    
    open var widthMulti: Array<CGFloat> = Array()
    open var section: Int = 0
    open weak var delegate: DxwStockScrollHeadViewDelegate?
    open var offSetX: CGFloat = 0 {
        didSet {
            scrollView?.contentOffset.x = offSetX
            if scrollView != nil && (scrollView!.contentSize.width - scrollView!.bounds.width - 5) >= offSetX {
                slideImage?.isHidden = false
            }else{
                slideImage?.isHidden = true
            }
        }
    }
    open var needBg: Bool = true {
        didSet {
            if let v = self.viewWithTag(1020) {
                v.isHidden = !needBg
            }
            self.backgroundColor = needBg ? HexColor(COLOR_COMMON_TAB) : UIColor.clear
        }
    }

    open func setHead(info: Array<Dictionary<String,Any>>) {
        self.backgroundColor = needBg ? HexColor(COLOR_COMMON_TAB) : UIColor.clear
        self.viewWithTag(1010)?.backgroundColor = HexColor(COLOR_COMMON_SEP)
        self.viewWithTag(1020)?.backgroundColor = HexColor(COLOR_COMMON_SEP)
        for item in items {
            item.removeFromSuperview()
        }
        items.removeAll()
        
        if info.isEmpty {
            return
        }
        
        for v in rightView?.subviews ?? [] {
            v.removeFromSuperview()
        }
        
        if let tmpV = delegate?.dxwStockScrollHeadViewRightView?(headView: self) {
            rightView?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(tmpV.frame.width)
            })
            
            rightView?.addSubview(tmpV)
            tmpV.snp.makeConstraints({ (maker) in
                maker.edges.equalTo(rightView!)
            })
        }
        var needMulti = false
        if widthMulti.count == info.count && !widthMulti.isEmpty {
            needMulti = true
        }
        
        if needMulti {
            frontView?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(widthMulti[0] * STOCK_CELL_WIDTH)
            })
        }else{
            frontView?.snp.updateConstraints({ (maker) in
                maker.width.equalTo(STOCK_SCROLL_FRONT_WIDTH)
            })
        }
        
        nameLabel?.text = info.first?["text"] + ""
        let fi = info.first?["filter"] as? Array<Dictionary<String, Any>> ?? []
        if fi.isEmpty {
            firstFilterImg?.isHidden = true
            firstFilterBtn?.isHidden = true
        }else{
            firstFilterImg?.isHidden = false
            firstFilterBtn?.isHidden = false
            firstFilterBtn?.storage = fi
            
            for dic in fi
            {
                if (dic["act"] + "") == "1"
                {
                    nameLabel?.text     = dic["name"] + ""
                    break
                }
            }
        }
        
        var mas = scrollView!.snp.left
        
        for i in 1 ..< info.count {
            var title = info[i]["text"] + ""
            let filter = info[i]["filter"] as? Array<Dictionary<String, Any>> ?? []
            for dic in filter {
                if (dic["act"] + "") == "1"
                {
                    title = dic["name"] + ""
                    break
                }
            }
            
            let item = DxwStockSortView(title: title, sortStr: info[i]["sort"] + "", filter: filter, delegate: self)
            if let config = info[i]["config"] as? DxwDic {
                if let color = config["bg_color"] as? String {
                    item.backgroundColor = HexColor(color)
                    item.hasBgColor = true
                }
            }
            let sortVal = info[i].getNumberForKey("sort_val")
            item.sortType = sortVal == 0 ? .normal : (sortVal == 1 ? .desc : .asc)
            item.index = i
            scrollView?.addSubview(item)
            item.snp.makeConstraints({ (maker) in
                maker.left.equalTo(mas)
                maker.top.equalTo(scrollView!)
                maker.height.equalTo(scrollView!)
                if needMulti {
                    maker.width.equalTo(widthMulti[i] * STOCK_CELL_WIDTH)
                }else{
                    maker.width.equalTo(STOCK_CELL_WIDTH)
                }
            })
            
            mas = item.snp.right
            
            items.append(item)
        
        }
        
        var sWidth: CGFloat = 0
        if needMulti {
            sWidth = (widthMulti.reduce(0, {$0 + $1}) - widthMulti[0]) * STOCK_CELL_WIDTH
        }else{
            sWidth = CGFloat(info.count - 1) * STOCK_CELL_WIDTH
        }
        scrollView?.contentSize = CGSize(width: sWidth, height: 30)
        
        //外部链接view
        frontExtraView?.removeFromSuperview()
        if !(info.first?["page_id"] + "").isEmpty  {
//            let setV = BaseButton()//(frame: CGRect(x: 7, y: 0.5, width: headW - 7, height: headH - 1))
//            setV.storage = info.first?["page_id"] + ""
//            setV.backgroundColor = self.backgroundColor
//            setV.tag = 1030
//            setV.contentHorizontalAlignment = .left
//            setV.titleLabel?.font = UIFont.normalFontOfSize(16)
//            setV.setTitleColor(HexColor(COLOR_COMMON_BLUE), for: .normal)
//            setV.setHorizontalImage(UIImage(named: "seting_plate")!, title: "设置", space: 6)
//            setV.addTarget(self, action: #selector(setting(btn:)), for: .touchUpInside)
//            self.addSubview(setV)
//            setV.snp.makeConstraints({ (maker) in
//                maker.left.equalTo(self).offset(7)
//                maker.centerY.equalTo(self)
//                maker.width.equalTo(self.frontView!).offset(-7)
//                maker.height.equalTo(self).offset(-1)
//            })
//            frontExtraView = setV
        }else if let extraView = delegate?.dxwStockScrollHeadViewFrontExtraView?(headView: self) {
            self.addSubview(extraView)
            frontExtraView = extraView
        }
    }
    
//    @objc private func setting(btn: BaseButton) {
//        if let pi = btn.storage as? String {
//            var pv = (delegate as? BaseViewController)?.getVcId() + ""
//            if pv.isEmpty {
//                pv = ((delegate as? BaseViewModel)?.mController as? BaseViewController)?.getVCId().rawValue + ""
//            }
//            VCMediator.sharedInstance.go2VC(.StockEditVC, para: ["page_id": pi as AnyObject, "pv": pv as AnyObject])
//        }
//    }
    
    override open func initUI() {
        super.initUI()
        
        self.backgroundColor = needBg ? HexColor(COLOR_COMMON_TAB) : UIColor.clear
        
        editingView = UIView()
        self.addSubview(editingView!)
        editingView?.snp.makeConstraints({ (maker) in
            maker.left.top.bottom.equalTo(self)
            maker.width.equalTo(0)
        })
        
        frontView = UIView()
        self.addSubview(frontView!)
        frontView?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(editingView!.snp.right)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
            maker.width.equalTo(STOCK_SCROLL_FRONT_WIDTH)
        })
        
        rightView = UIView()
        self.addSubview(rightView!)
        rightView?.snp.makeConstraints({ (maker) in
            maker.right.top.bottom.equalTo(self)
            maker.width.equalTo(0)
        })
        
        scrollView = UIScrollView()
        scrollView?.isScrollEnabled = false
        scrollView?.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView!)
        scrollView?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(frontView!.snp.right)
            maker.right.equalTo(rightView!.snp.left)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        })
        
        nameLabel = UILabel()
        nameLabel?.textColor = HexColor(COLOR_COMMON_BLACK_9)
        nameLabel?.font = UIFont.normalFontOfSize(12)
        frontView?.addSubview(nameLabel!)
        nameLabel?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(frontView!).offset(7)
            maker.centerY.equalTo(frontView!)
        })
        
        firstFilterImg = UIImageView()
        firstFilterImg?.isHidden = true
        firstFilterImg?.image = UIImage(named: "lhb_icon_filter")
        frontView?.addSubview(firstFilterImg!)
        firstFilterImg?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(nameLabel!.snp.right).offset(2)
            maker.bottom.equalTo(nameLabel!)
        })
        
        firstFilterBtn = BaseButton()
        firstFilterBtn?.isHidden = true
        frontView?.addSubview(firstFilterBtn!)
        firstFilterBtn?.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        firstFilterBtn?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(frontView!)
            maker.right.equalTo(frontView!)
            maker.top.equalTo(frontView!)
            maker.bottom.equalTo(frontView!)
        })
        
        slideImage = UIImageView()
        slideImage?.image = UIImage(named: "sliding_list_arrow")
        self.addSubview(slideImage!)
        slideImage?.snp.makeConstraints({ (maker) in
            maker.right.equalTo(self)
            maker.centerY.equalTo(self)
            maker.width.equalTo(11.5)
            maker.height.equalTo(30)
        })
        
        let line = UIView()
        line.tag = 1010
        self.addSubview(line)
        line.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.bottom.equalTo(self)
            maker.height.equalTo(0.5)
        }
        
        let line1 = UIView()
        line1.tag = 1020
        self.addSubview(line1)
        line1.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.height.equalTo(0.5)
        }
        
    }
    
    open func setEditing(_ editing: Bool, animated: Bool) {
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
    }
    
    @objc private func buttonClick(btn: BaseButton) {
        delegate?.dxwStockScrollHeadViewFiltered(section: section, index: 0, filter: btn.storage as? Array<Dictionary<String, Any>> ?? [])
    }
    
    func dxwStockSortViewSorted(view: DxwStockSortView, index: Int, ad: String) {
        for item in items {
            if item !== view {
                item.sortType = .normal
            }
        }
        delegate?.dxwStockScrollHeadViewSorted(section: section, index: index, ad: ad)
    }
    
    func dxwStockSortViewFiltered(view: DxwStockSortView, index: Int, filter: Array<Dictionary<String, Any>>) {
        delegate?.dxwStockScrollHeadViewFiltered(section: section, index: index, filter: filter)
    }
    
    private var editingView: UIView?
    var frontView: UIView?
    private var rightView: UIView?
    private var nameLabel: UILabel?
    private var firstFilterImg: UIImageView?
    private var firstFilterBtn: BaseButton?
    
    private var scrollView: UIScrollView?
    
    private var items: Array<DxwStockSortView> = Array()
    private var slideImage: UIImageView?
    
    private weak var frontExtraView: UIView?
    
}

enum DxwStockSortType: String {
    case asc = "lhb_icon_sort_asc"
    case normal = "lhb_icon_sort_default"
    case desc = "lhb_icon_sort_desc"
}

protocol DxwStockSortViewDelegate: NSObjectProtocol {
    func dxwStockSortViewSorted(view: DxwStockSortView, index: Int, ad: String)
    func dxwStockSortViewFiltered(view: DxwStockSortView, index: Int, filter: Array<Dictionary<String, Any>>)
}

class DxwStockSortView: BaseView {

    var sortType: DxwStockSortType = .normal {
        didSet {
            if !sortStr.isEmpty {
                imageView?.image = UIImage(named: sortType.rawValue)
            }
        }
    }
    
    var hasBgColor: Bool = false
    
    var index: Int = -1
    
    init(title: String, sortStr: String,filter: Array<Dictionary<String, Any>>, delegate: DxwStockSortViewDelegate?) {
        self.sortStr = sortStr
        self.title = title
        self.filter = filter
        super.init(frame: CGRect.zero)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initUI() {
        super.initUI()
        
        titleLabel = UILabel()
        titleLabel?.font = UIFont.normalFontOfSize(12)
        titleLabel?.text = title
        titleLabel?.textColor = HexColor(COLOR_COMMON_BLACK_9)
        self.addSubview(titleLabel!)
        titleLabel?.snp.makeConstraints({ (maker) in
            maker.centerX.equalTo(self)
            maker.centerY.equalTo(self)
        })
        
        if sortStr == "1" || !filter.isEmpty {
            imageView = UIImageView()
            imageView?.image = sortStr == "1" ? UIImage(named: sortType.rawValue) : UIImage(named: "lhb_icon_filter")
            
            self.addSubview(imageView!)
            
            titleLabel?.snp.updateConstraints({ (maker) in
                maker.centerX.equalTo(self).offset(-4)
            })
            
            imageView?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(titleLabel!.snp.right).offset(3)
                maker.centerY.equalTo(titleLabel!).offset(sortStr == "1" ? 0 : 3)
            })
            
            button = BaseButton()
            button?.addTarget(self, action: #selector(DxwStockSortView.sortAction), for: UIControl.Event.touchUpInside)
            self.addSubview(button!)
            button?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(self)
                maker.right.equalTo(self)
                maker.top.equalTo(self)
                maker.bottom.equalTo(self)
            })
        }
        
    }
    
    @objc private func sortAction() {
        if sortStr == "1" {
            var ad = "desc"
            switch sortType {
            case .desc:
                ad = "asc"
                sortType = .asc
            default:
                ad = "desc"
                sortType = .desc
            }
            if index != -1 {
                delegate?.dxwStockSortViewSorted(view: self, index: index, ad: ad)
            }
        }else if !filter.isEmpty {
            delegate?.dxwStockSortViewFiltered(view: self, index: index, filter: filter)
        }
    }

    private var titleLabel: UILabel?
    private var imageView: UIImageView?
    private var button: BaseButton?
    
    private weak var delegate: DxwStockSortViewDelegate?
    private var title: String
    private var sortStr: String
    private var filter: Array<Dictionary<String, Any>>
    
}
