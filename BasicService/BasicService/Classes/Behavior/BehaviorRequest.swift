//
//  BehaviorRequest.swift
//  quchaogu
//
//  Created by focus on 16/5/25.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

final class BehaviorPRequest : BaseRequest {
    required init(paraDic : Dictionary<String, Any>) {
        super.init()
        self.addReqParam(paraDic, isSign: false)
    }
    
    override func getRelativeUrl() -> String? {
        return "p.php"
    }
    
    override func getServerType() -> ServerType {
        return .analyse("http://analytics.quchaogu.com/")
    }
    
    override func needRequestToast() -> Bool {
        return false
    }

}

final class BehaviorERequest : BaseRequest {
    required init(paraDic : Dictionary<String, String>) {
        super.init()
        self.addReqParam(paraDic, isSign: false)
    }
    
    override func getRelativeUrl() -> String {
        return "e.php"
    }
    
    override func getServerType() -> ServerType {
        return .analyse("http://analytics.quchaogu.com/")
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
}
