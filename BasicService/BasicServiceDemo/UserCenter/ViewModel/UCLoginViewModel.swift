//
//  UCLoginViewModel.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/6/21.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

class UCLoginViewModel: BaseViewModel {
    
    var mobile: Variable<String> = Variable("")
    var password: Variable<String> = Variable("")
    
    func doLogin() {
        guard !mobile.value.isEmpty && !password.value.isEmpty else {
            self.view?.makeToast("登录信息有误")
            return
        }
        let logintime = UtilDate.getTimeInterval()
        let md5pwd = "\(password.value.md5())\(logintime)".md5()
        let paramers = ["uname" : mobile.value, "md5pwd" : md5pwd, "login_time" : "\(logintime)"]
        let request = UCLoginRequest(params: paramers)
        self.doRequest(request, completion: { (res) in
            if res?.resultCode == 10000 {
                self.view?.makeToast("登录成功")
            }else{
                self.view?.makeToast(res?.errorMsg + "")
            }
        }) { (error) in
            self.view?.makeToast(error?.msg + "")
        }
    }
    
}
