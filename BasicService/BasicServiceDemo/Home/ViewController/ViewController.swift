//
//  ViewController.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/3/8.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit
import RxSwift

fileprivate let usernameValidNum = 5
fileprivate let passwordValidNum = 6

class ViewController: BaseViewController {
    
    @IBOutlet weak var textView1: UITextField!
    @IBOutlet weak var textView2: UITextField!
    @IBOutlet weak var textView3: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var pwdLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observerAddNumber()
        observerLogin()
    }
    
    override func needSetBackIcon() -> Bool {
        return false
    }
    
    override func canSlideToLast() -> Bool {
        return false
    }
    
    private func observerAddNumber() {
        Observable.combineLatest(textView1.rx.text.orEmpty, textView2.rx.text.orEmpty
        ,textView3.rx.text.orEmpty) { (value1, value2, value3) -> Int in
            return (Int(value1) ?? 0) + (Int(value2) ?? 0) + (Int(value3) ?? 0)
            }
            .map { $0.description }
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func observerLogin() {
        
        let usernameResult = username.rx.text.orEmpty
            .map { $0.count >= usernameValidNum }
            .share(replay: 1)
        
        let pwdResult = password.rx.text.orEmpty
            .map { $0.count >= passwordValidNum && $0.isMatch("^[a-zA-Z]{1,}[0-9]+") }
            .share(replay: 1)
        
        let allResult = Observable.combineLatest(usernameResult, pwdResult) { $0 && $1 }
        
        usernameResult.bind(to: nameLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        usernameResult.bind(to: password.rx.isEnabled)
            .disposed(by: disposeBag)
        
        pwdResult.bind(to: pwdLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        allResult.bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .subscribe(onNext: {[weak self] _ in self?.showTips()})
            .disposed(by: disposeBag)
        
    }
    
    private func showTips() {
        let story = UIStoryboard.init(name: "UserCenter", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "usercenterStoryboard")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

