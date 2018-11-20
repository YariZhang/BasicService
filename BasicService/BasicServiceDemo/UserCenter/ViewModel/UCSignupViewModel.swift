//
//  UCSignupViewModel.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/8/7.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

class UCSignupViewModel: BaseViewModel {
    
    var phoneNumber: Variable<String> = Variable("")
    var codeNumber: Variable<String> = Variable("")
    var pwdNumber: Variable<String> = Variable("")
    var codeString: Variable<String> = Variable("获取验证码")
    var codeEnable: Variable<Bool> = Variable(true)
    
    private let timeInterval: TimeInterval = 60
    private var disposeBag: DisposeBag = DisposeBag()
    
    func getMobileCode() {
        print(phoneNumber.value)
        getMbCode()
        mobileCodeTimer()
    }
    
    func singupAction() {
        print("手机号：" + phoneNumber.value)
        print("验证码：" + codeNumber.value)
        print("密码：" + pwdNumber.value)
    }
    
    private func mobileCodeTimer() {
        Observable<TimeInterval>.timerRun(duration: timeInterval, interval: 1, ascending: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (remain) in
                self?.codeString.value = "\(Int(remain))秒"
                self?.codeEnable.value = false
            }, onCompleted: { [weak self] in
                self?.codeString.value = "重新获取"
                self?.codeEnable.value = true
            })
            .disposed(by: disposeBag)
    }
    
    private func getMbCode() {
        
    }
    
}


