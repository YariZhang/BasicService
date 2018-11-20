//
//  UCSignupViewController.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/6/21.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

fileprivate let passwordValidMinNum = 6
fileprivate let passwordValidMaxNum = 16

class UCSignupViewController: BaseViewController {

    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var phoneLine: UIView!
    @IBOutlet weak var mobileCodeTf: UITextField!
    @IBOutlet weak var codeLine: UIView!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    private var signupBtn: GradientButton!
    private lazy var viewModel: UCSignupViewModel! = UCSignupViewModel(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observables()
    }
    
    override func initUI() {
        super.initUI()
        
        signupBtn = GradientButton()
        signupBtn.layer.cornerRadius = 3
        signupBtn.layer.masksToBounds = true
        signupBtn.setTitleColor(UIColor.white, for: .normal)
        signupBtn.setTitle("注册", for: .normal)
        signupBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        signupBtn.alpha = 0.5
        signupBtn.isUserInteractionEnabled = false
        self.view.addSubview(signupBtn)
        signupBtn.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.view).offset(15)
            maker.right.equalTo(self.view).offset(-15)
            maker.top.equalTo(checkBtn.snp.bottom).offset(10)
            maker.height.equalTo(45)
        }
        
        checkBtn.isSelected = true
        checkBtn.setImage(UIImage(named: "uc_register_uncheck"), for: .normal)
        checkBtn.setImage(UIImage(named: "uc_register_check"), for: .selected)
        
        passwordTf.placeholder = "\(passwordValidMinNum)-\(passwordValidMaxNum)位的首位为字母的字母数字组合"
    }
    
    private func observables() {
        
        phoneTf.rx.text.orEmpty.bind(to: viewModel.phoneNumber).disposed(by: disposeBag)
        mobileCodeTf.rx.text.orEmpty.bind(to: viewModel.codeNumber).disposed(by: disposeBag)
        passwordTf.rx.text.orEmpty.bind(to: viewModel.pwdNumber).disposed(by: disposeBag)
        
        let phoneEditResults = phoneTf.rx.isEditing
            .share(replay: 1)
    
        let codeEditResults = mobileCodeTf.rx.isEditing
            .share(replay: 1)
        
        let phoneResults = viewModel.phoneNumber.asObservable()
            .map { $0.isMatch("^1\\d{10}$") }
            .share(replay: 1)
        
        let codeResults = viewModel.codeNumber.asObservable()
            .map {$0.isMatch("^[0-9]{6}$")}
            .share(replay: 1)
        
        let passResults = viewModel.pwdNumber.asObservable()
            .map { $0.count >= passwordValidMinNum &&
                   $0.count <= passwordValidMaxNum &&
                   $0.isMatch("^[a-zA-Z]{1,}[0-9]+") }
            .share(replay: 1)
        
        let checkSelResults = checkBtn.rx.selected
            .share(replay: 1)
        
        let signupResults = Observable.combineLatest(phoneResults, codeResults, passResults, checkSelResults) { $0 && $1 && $2 && $3 }
        
        phoneEditResults.bind { [weak self] editing in
            self?.phoneLine.backgroundColor = editing ? HexColor("#333") : HexColor("#ddd")
        }.disposed(by: disposeBag)
        
        codeEditResults.bind { [weak self] editing in
            self?.codeLine.backgroundColor = editing ? HexColor("#333") : HexColor("#ddd")
        }.disposed(by: disposeBag)
        
        phoneResults.bind { [weak self] (valid) -> Void in
            if !valid && self!.phoneTf.text!.count > 11 {
                self?.phoneTf.text = self!.phoneTf.text![0..<11]
                self?.phoneTf.resignFirstResponder()
                self?.phoneTf.becomeFirstResponder()
            }
            }.disposed(by: disposeBag)
        
        codeResults.bind { [weak self] (valid) -> Void in
            if !valid && self!.mobileCodeTf.text!.count > 6 {
                self?.mobileCodeTf.text = self!.mobileCodeTf.text![0..<6]
            }
            }.disposed(by: disposeBag)
        
        passResults.bind { [weak self] (valid) -> Void in
            if !valid && self!.passwordTf.text!.count > passwordValidMaxNum {
                self?.passwordTf.text = self!.passwordTf.text![0..<passwordValidMaxNum]
            }
            }.disposed(by: disposeBag)
        
        signupResults.bind(to: signupBtn.rx.isValid)
            .disposed(by: disposeBag)
        
        signupBtn.rx.tap
            .subscribe(onNext: { [weak self] in self?.viewModel.singupAction()})
            .disposed(by: disposeBag)
        
        viewModel.codeString.asObservable().bind(to: codeBtn.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.codeEnable.asObservable().bind(to: codeBtn.rx.isUserInteractionEnabled).disposed(by: disposeBag)
        
        codeBtn.rx.tap
            .subscribe(onNext: {[weak self] in self?.viewModel.getMobileCode()})
            .disposed(by: disposeBag)
    }

    @IBAction func buttonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
