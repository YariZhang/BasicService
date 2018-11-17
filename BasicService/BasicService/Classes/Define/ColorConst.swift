//
//  ColorConst.swift
//  BasicService
//
//  Created by zhangyr on 2018/11/16.
//  Copyright © 2018 zhangyr. All rights reserved.
//

import UIKit

//十六进制颜色
public func HexColor(_ hex: String) -> UIColor {
    return UtilTools.colorWithHexString(hex)
}
//-----------------------色值颜色--------------------------

public let COLOR_COMMON_WHITE                  = "#ffffff"
public let COLOR_COMMON_WHITE_50               = "#ffffff7f"
public let COLOR_COMMON_WHITE_60               = "#ffffff99"
public let COLOR_COMMON_WHITE_80               = "#ffffffcc"
public let COLOR_COMMON_BLACK_20               = "#00000033"
public let COLOR_COMMON_BLACK_30               = "#0000004c"
public let COLOR_COMMON_BLACK_50               = "#0000007f"
public let COLOR_COMMON_BLUE                   = "#2371e9"
public let COLOR_COMMON_BLACK                  = "#000000"
public let COLOR_COMMON_BLACK_3                = "#333333"
public let COLOR_COMMON_BLACK_6                = "#666666"
public let COLOR_COMMON_BLACK_9                = "#999999"
public let COLOR_COMMON_ORANGE                 = "#ff6f00"
public let COLOR_COMMON_ORANGE_FF98            = "#ff9800"
public let COLOR_COMMON_GRAY_DA                = "#dadee5"
public let COLOR_COMMON_YELLOW                 = "#ffc107"
public let COLOR_COMMON_YELLOW_3B              = "#ffeb3b"
public let COLOR_SELECT_CELL_F9                = "#f9f9f9"
