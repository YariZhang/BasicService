//
//  UtilDate.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/6/21.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit

public class UtilDate: NSObject {
    //格式化时间 输入时间戳，以自定义的时间格式输出
    public class func formatTime(_ express : String = "yyyy-MM-dd HH:mm",time_interval : Int = 0) -> String {
        var date : Date?
        
        if time_interval == 0 {
            date = Date()
        }else
        {
            date = Date(timeIntervalSince1970: Double(time_interval))
        }
        let format : DateFormatter! = DateFormatter()
        format.dateFormat = express
        let timeStr = format.string(from: date!)
        return timeStr
    }
    //获取当前时间戳
    public class func getTimeInterval() ->Int {
        let d = Date()
        let t = d.timeIntervalSince1970
        return Int(t)
    }
    
    public class func getTimeIntervalByDateString(_ express : String = "yyyyMMdd" , dateStr : String) -> Int {
        let format : DateFormatter = DateFormatter()
        format.dateFormat = express
        let date = format.date(from: dateStr)
        let t = date?.timeIntervalSince1970
        return Int(t!)
    }
    
    //将输入的年月日转化为时间戳再转化为需要的格式  如 "yyyyMMdd"  20150606  "MM-dd" -> 06-06
    public class func convertFormatByDate(_ express : String = "yyyyMMdd" , date_time : String , toFormat : String = "MM-dd") -> String {
        
        let format : DateFormatter = DateFormatter()
        format.dateFormat = express
        if date_time.count < express.count {
            return "日期"
        }
        let date = format.date(from: date_time)
        let formatNew : DateFormatter = DateFormatter()
        formatNew.dateFormat = toFormat
        if date == nil {
            return "日期"
        }
        let newTimeStr = formatNew.string(from: date!)
        return newTimeStr
    }
}
