//
//  ViewController.swift
//  BasicServiceDemo
//
//  Created by zhangyr on 2018/11/16.
//  Copyright © 2018 zhangyr. All rights reserved.
//

import UIKit
import BasicService
import RxCocoa

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "首页"
    }
    
    override func initUI() {
        super.initUI()
        let btn = BaseButton()
        btn.backgroundColor = HexColor("#2371e9")
        btn.setTitle("点击", for: .normal)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { (maker) in
            maker.center.equalTo(self.view)
            maker.width.equalTo(100)
            maker.height.equalTo(44)
        }
        
        btn.rx.tap
            .subscribe(onNext: {[weak self] _ in
                let html = BaseWebViewController()
                html.url = "https://baidu.com"
                self?.navigationController?.pushViewController(html, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func canSlideToLast() -> Bool {
        return false
    }
    
    override func needSetBackIcon() -> Bool {
        return false
    }
}

