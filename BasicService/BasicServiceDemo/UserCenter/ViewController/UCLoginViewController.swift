//
//  UCLoginViewController.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/6/20.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

class UCLoginViewController: BaseViewController {

    @IBOutlet weak var topBgView: UIView!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var phoneLine: UIView!
    @IBOutlet weak var passwordTf: UITextField!
    private var loginBtn: GradientButton!
    private lazy var viewModel: UCLoginViewModel! = UCLoginViewModel(delegate: self)
    
    deinit {
        print("释放")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func initUI() {
        super.initUI()
        
        loginBtn = GradientButton()
        loginBtn.layer.cornerRadius = 3
        loginBtn.layer.masksToBounds = true
        loginBtn.setTitleColor(UIColor.white, for: .normal)
        loginBtn.setTitle("登录", for: .normal)
        loginBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginBtn.alpha = 0.5
        loginBtn.isUserInteractionEnabled = false
        self.view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.view).offset(15)
            maker.right.equalTo(self.view).offset(-15)
            maker.top.equalTo(topBgView.snp.bottom).offset(10)
            maker.height.equalTo(45)
        }
        phoneLine.backgroundColor = HexColor("#ddd")
        observables()
    }
    
    private func observables() {
        phoneTf.rx.text.orEmpty.bind(to: viewModel.mobile).disposed(by: disposeBag)
        passwordTf.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        
        let phoneEditResults = phoneTf.rx.isEditing
            .share(replay: 1)
        
        let phoneResults = phoneTf.rx.text.orEmpty
            .map { $0.isMatch("^1\\d{10}$") }
            .share(replay: 1)
        
        let passResults = passwordTf.rx.text.orEmpty
            .map { $0.count >= 6 }
            .share(replay: 1)
        
        let loginResults = Observable.combineLatest(phoneResults, passResults) { $0 && $1 }
        
        phoneEditResults.bind { [weak self] editng in
            self?.phoneLine.backgroundColor = editng ? HexColor("#333") : HexColor("#ddd")
        }.disposed(by: disposeBag)
        
        phoneResults.bind { [weak self] (valid) -> Void in
            if !valid && self!.phoneTf.text!.count > 11 {
                self?.phoneTf.text = self!.phoneTf.text![0..<11]
            }
        }.disposed(by: disposeBag)
        
        loginResults.bind(to: loginBtn.rx.isValid)
            .disposed(by: disposeBag)
        
        loginBtn.rx.tap
            .subscribe(onNext: { [weak self] in self?.loginAction() })
            .disposed(by: disposeBag)
        
    }
    
    private func loginAction() {
        viewModel.doLogin()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier + "")
        print(segue.destination is UCSignupViewController)
    }
}
