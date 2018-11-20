//
//  UCLoginRequest.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/6/21.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

class UCLoginRequest: BaseRequest {
    
    required init(params: Dictionary<String, Any>) {
        super.init()
        self.isPostMethod = true
        self.addReqParam(params, isSign: false)
        self.addReqParam(key: "app_name", value: "dxw", isSign: false)
    }
    
    override func getServerType() -> ServerType {
        return ServerType.uc
    }
    
    override func getRelativeUrl() -> String? {
        return "sso/dologin"
    }
    
}
