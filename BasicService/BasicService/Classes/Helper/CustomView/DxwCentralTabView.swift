//
//  DxwCentralTabView.swift
//  Lhb
//
//  Created by zhangyr on 2016/12/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

open class DxwCentralTabData: NSObject {
    @objc open var title: String = ""
    @objc open var img_url: String = ""
    @objc open var url: String = ""
    @objc open var param: DxwDic?
    @objc open var tag: String = ""
}

public protocol DxwCentralTabViewDelegate: NSObjectProtocol {
    func dxwCentralTabViewItemSelected(withData data: DxwCentralTabData)
}

open class DxwCentralTabView: BaseView, DxwCentralTabItemDelegate, UIScrollViewDelegate {
    
    open var height : CGFloat {
        return 75 * CGFloat(currentLine)
    }
    open var lines = 2
    open var columns : Int {
        return 4
    }
    
    open weak var delegate: DxwCentralTabViewDelegate?
    open var max: Int {
        return columns * lines
    }
    open var tabsData: Array<DxwCentralTabData>! {
        didSet {
            if tabsData != nil && !tabsData.isEmpty {
                showData()
            }
        }
    }
    
    private var currentLine: Int = 2
    
    override open func initUI() {
        super.initUI()
        self.backgroundColor = HexColor(COLOR_COMMON_TAB)
        
        scrollView = UIScrollView()
        scrollView?.bounces = false
        scrollView?.delegate = self
        scrollView?.isPagingEnabled = true
        scrollView?.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView!)
        scrollView?.snp.makeConstraints({ (maker) in
            maker.edges.equalTo(self)
        })
        
        pageControl = UIPageControl()
        pageControl?.currentPage = 0
        pageControl?.currentPageIndicatorTintColor = HexColor(COLOR_COMMON_BLACK_6)
        pageControl?.pageIndicatorTintColor = HexColor(COLOR_COMMON_BLACK_9)
        pageControl?.isHidden = true
        pageControl?.numberOfPages = 2
        self.addSubview(pageControl!)
        pageControl?.snp.makeConstraints({ (maker) in
            maker.centerX.equalTo(self)
            maker.bottom.equalTo(self).offset(-4)
            maker.height.equalTo(8)
            maker.width.equalTo(self)
        })
    }
    
    private func showData() {
        
        for v in items {
            v.removeFromSuperview()
        }
        items.removeAll()
        let multi: CGFloat = 1 / CGFloat(columns)
        var pageCount = 0
        let tmpLine = (tabsData.count - 1) / columns + 1
        if tmpLine < lines {
            currentLine = tmpLine
        }else{
            currentLine = lines
        }
        
        if !tabsData.isEmpty && tabsData.count > max {
            pageCount = (tabsData.count - 1) / max + 1
            scrollView?.contentSize = CGSize(width: CGFloat(pageCount) * SCREEN_WIDTH, height: scrollView?.bounds.height ?? 0)
        }else{
            pageCount = 0
            scrollView?.contentSize = CGSize(width: SCREEN_WIDTH, height: scrollView?.bounds.height ?? 0)
        }
        pageControl?.isHidden = pageCount <= 0
        pageControl?.numberOfPages  = pageCount
        let wUnit = SCREEN_WIDTH / CGFloat(columns)
        let hUnit = height / CGFloat(currentLine)
        for i in 0 ..< tabsData.count {
            let page = i / max
            let line = (i / columns) % currentLine
            let column = page * columns + i % columns
            let d = tabsData[i]
            let item = DxwCentralTabItem()
            item.itemData   = d
            item.delegate   = self
            scrollView?.addSubview(item)
            item.snp.makeConstraints({ (maker) in
                maker.left.equalTo(scrollView!).offset(wUnit * CGFloat(column))
                maker.top.equalTo(scrollView!).offset(hUnit * CGFloat(line))
                maker.height.equalTo(hUnit)
                maker.width.equalTo(scrollView!).multipliedBy(multi)
            })
            items.append(item)
            //                lastV           = item
        }
        self.setNeedsDisplay()
        if scrollView!.frame.size.width != 0 {
            let page = Int(scrollView!.contentOffset.x / scrollView!.frame.size.width + 0.5)
            pageControl?.currentPage = page
        }
    }
    
    func dxwCentralTabItemSelected(withData data: DxwCentralTabData) {
        delegate?.dxwCentralTabViewItemSelected(withData: data)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setLineWidth(1)
        context?.setStrokeColor(HexColor(COLOR_COMMON_SEP).cgColor)
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: rect.width, y: 0))
        context?.move(to: CGPoint(x: 0, y: rect.height))
        context?.addLine(to: CGPoint(x: rect.width, y: rect.height))
        if items.count == 2 {
            context?.move(to: CGPoint(x: rect.width / 2, y: 15))
            context?.addLine(to: CGPoint(x: rect.width / 2, y: rect.height - 15))
        }
        context?.strokePath()
        context?.restoreGState()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5)
        pageControl?.currentPage = page
    }
    
    private var scrollView: UIScrollView?
    private var pageControl: UIPageControl?
    private lazy var items: Array<DxwCentralTabItem> = Array()
}

protocol DxwCentralTabItemDelegate: NSObjectProtocol {
    func dxwCentralTabItemSelected(withData data: DxwCentralTabData)
}

class DxwCentralTabItem: BaseView {
    
    weak var delegate: DxwCentralTabItemDelegate?
    var itemData: DxwCentralTabData! {
        didSet{
            if itemData != nil {
                showData()
            }
        }
    }
    
    override func initUI() {
        super.initUI()
        button = BaseButton()
        button.addTarget(self, action: #selector(itemSelected), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(touchBtn(btn:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(touchBtn(btn:)), for: UIControl.Event.touchCancel)
        button.addTarget(self, action: #selector(touchBtn(btn:)), for: UIControl.Event.touchDragOutside)
        self.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
        
        imageView = UIImageView()
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self)
            maker.top.equalTo(self).offset(10)
            maker.width.equalTo(0)
            maker.height.equalTo(0)
        }
        
        tagView = UIImageView()
        self.addSubview(tagView)
        tagView.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(imageView.snp.right)
            maker.centerY.equalTo(imageView.snp.top)
            maker.width.equalTo(0)
            maker.height.equalTo(0)
        }
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.normalFontOfSize(12)
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self)
            maker.top.equalTo(imageView.snp.bottom)
            maker.height.equalTo(20)
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let btn = object as? BaseButton, btn === button {
            
        }
    }
    
    private func showData() {
        imageView.sd_setImage(with: URL(string: itemData.img_url), completed: {(image, error, type, url) in
            if image != nil {
                let width = (image!.size.width) / 3
                let height = (image!.size.height) / 3
                self.imageView.image = image
                self.imageView.snp.updateConstraints({ (maker) in
                    maker.width.equalTo(width)
                    maker.height.equalTo(height)
                })
            }
        })
        tagView.sd_setImage(with: URL(string: itemData.tag), completed: {(image, error, type, url) in
            if image != nil {
                let width = (image!.size.width) / 3
                let height = (image!.size.height) / 3
                self.tagView.image = image
                self.tagView.snp.updateConstraints({ (maker) in
                    maker.width.equalTo(width)
                    maker.height.equalTo(height)
                })
            }
        })
        titleLabel.text = itemData.title
    }
    
    @objc private func touchBtn(btn: UIButton) {
        if btn.state == .highlighted {
            btn.backgroundColor = HexColor(COLOR_COMMON_SEP)
        }else{
            btn.backgroundColor = UIColor.clear
        }
    }
    
    @objc private func itemSelected() {
        button.backgroundColor = UIColor.clear
        if itemData != nil {
            delegate?.dxwCentralTabItemSelected(withData: itemData)
        }
    }
    
    private var imageView   : UIImageView!
    private var tagView     : UIImageView!
    private var titleLabel  : UILabel!
    private var button      : BaseButton!
}
