//
//  BaseTabBar.swift
//  quchaogu
//
//  Created by zhangyr on 16/6/13.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

public let TAB_BOTTOM_HEIGHT: CGFloat = 50 + (IS_IPHONE_X ? 34 : 0)

public class BaseTabBarItemData: NSObject {
    var text: String = ""
    var backImage: UIImage?
    var normalImage: UIImage?
    var selectedImage: UIImage?
}

public protocol BaseTabBarDelegate : NSObjectProtocol {
    ///tabBarItem的个数
    func numberOfTabBarItems(_ tabBar : BaseTabBar) -> Int
    ///每个item的资源
    func resourceForTabBar(_ tabBar : BaseTabBar , atIndex index : Int) -> BaseTabBarItemData
    ///item点击
    func tabBarDidSelected(_ tabBar : BaseTabBar , atIndex index : Int) -> Void
    ///tabbar应该被加到哪个view中
    func tabBarAddToView(_ tabBar : BaseTabBar) -> UIView?
    ///tabbar手动设置了某个item
    func tabBarSelectItemAtIndex(_ tabBar : BaseTabBar) -> Int?
    ///item被双击
    func tabBarDoubleClick(_ tabBar : BaseTabBar , atIndex index : Int) -> Void
}

public class BaseTabBar: BaseView, BaseTabItemDelegate {
    
    public weak var delegate: BaseTabBarDelegate?
    
    ///badge字体大小
    public var badgeFontSize: CGFloat? {
        didSet {
            setAttributes()
        }
    }
    ///badge字体颜色
    public var textColor: UIColor? {
        didSet {
            setAttributes()
        }
    }
    ///badge背景颜色
    public var bgcolor: UIColor? {
        didSet {
            setAttributes()
        }
    }
    ///未选中颜色
    public var normalColor: UIColor = HexColor("#999999") {
        didSet {
            setAttributes()
        }
    }
    ///选中颜色
    public var selectedColor: UIColor = HexColor("#ef5350") {
        didSet {
            setAttributes()
        }
    }
    ///tabbar字体大小
    public var fontSize: CGFloat = 10 {
        didSet {
            setAttributes()
        }
    }
    ///badge风格（.Point 点  .Number 数字  .Image 图片）
    public var style: BaseTabBadgeType = .point {
        didSet {
            setAttributes()
        }
    }
    ///tabBar 分割线颜色
    public var sepColor: UIColor = HexColor("#e0e0e0") {
        didSet {
            sepLine?.backgroundColor = sepColor
        }
    }
    ///是否需要分割线
    var needSep: Bool = true {
        didSet {
            sepLine?.isHidden = !needSep
        }
    }
    fileprivate var sepLine: UIView?
    
    fileprivate func initItems() {
        if delegate == nil {
            return
        }
        for v in self.subviews {
            v.removeFromSuperview()
        }
        let count           = delegate!.numberOfTabBarItems(self)
        let muti : CGFloat  = 1 / CGFloat(count)
        var last : UIView?
        for i in 0 ..< count {
            let item        = BaseTabItem()
            setAttributeForItem(item)
            item.tag        = i + 100
            item.delegate   = self
            item.source     = delegate!.resourceForTabBar(self, atIndex: i)
            let selectedIndex   = delegate!.tabBarSelectItemAtIndex(self) ?? 0
            if i == selectedIndex {
                item.isSelected = true
            }
            self.addSubview(item)
            item.snp.makeConstraints({ (maker) in
                if last == nil {
                    maker.left.equalTo(self)
                }else{
                    maker.left.equalTo(last!.snp.right)
                }
                maker.top.equalTo(self)
                maker.bottom.equalTo(self).offset(IS_IPHONE_X ? -34 : 0)
                maker.width.equalTo(self).multipliedBy(muti)
            })
            last            = item
        }
        
        sepLine                     = UIView()
        sepLine?.backgroundColor    = sepColor
        sepLine?.isHidden             = !needSep
        self.addSubview(sepLine!)
        sepLine?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.height.equalTo(1)
        })
    }
    
    fileprivate func setAttributeForItem(_ item : BaseTabItem) {
        item.style          = style
        item.badgeFontSize  = badgeFontSize
        item.textColor      = textColor
        item.bgcolor        = bgcolor
        item.normalColor    = normalColor
        item.selectedColor  = selectedColor
        item.fontSize       = fontSize
    }
    
    fileprivate func setAttributes() {
        if delegate == nil {
            return
        }
        let count           = delegate!.numberOfTabBarItems(self)
        for i in 0 ..< count {
            if let item = self.viewWithTag(i + 100) as? BaseTabItem {
                setAttributeForItem(item)
            }
        }
    }
    
    func tabItemSelected(_ item: BaseTabItem) {
        delegate?.tabBarDidSelected(self, atIndex: item.tag - 100)
        setOtherItems(item.tag - 100)
    }
    
    func tabItemDoubleClick(_ item: BaseTabItem) {
        delegate?.tabBarDoubleClick(self, atIndex: item.tag - 100)
        setOtherItems(item.tag - 100)
    }
    
    fileprivate func setOtherItems(_ index : Int) {
        if delegate == nil {
            return
        }
        let count           = delegate!.numberOfTabBarItems(self)
        for i in 0 ..< count {
            if let item = self.viewWithTag(i + 100) as? BaseTabItem {
                if i != index {
                    item.isSelected = false
                }
            }
        }
    }
    
    ///设置badge的内容
    func setBadgeAtIndex(_ index : Int , info : AnyObject?) {
        if let item = self.viewWithTag(index + 100) as? BaseTabItem {
            item.badgeInfo  = info
        }
    }
    
    ///重新加载数据
    func reloadData() {
        initItems()
        relayoutUI()
    }
    ///重新布局到新的view中
    func relayoutUI() {
        guard let v = delegate?.tabBarAddToView(self) else {
            return
        }
        v.addSubview(self)
        self.snp.remakeConstraints({ (maker) in
            maker.left.equalTo(v)
            maker.right.equalTo(v)
            maker.bottom.equalTo(v)
            maker.height.equalTo(TAB_BOTTOM_HEIGHT)
        })
    }
}
