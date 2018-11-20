//
//  UCExtension.swift
//  MVVMFramework
//
//  Created by zhangyr on 2018/6/21.
//  Copyright © 2018年 zhangyr. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UITextField {
    
    var isEditing: ControlProperty<Bool> {
        return editing
    }
    
    var editing: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: [.allEditingEvents, .valueChanged],
                                       getter: { (textField) -> Bool in
                                                    return textField.isEditing
                                                },
                                       setter: { (textField, editing) in
                                        })
    }
}

extension Reactive where Base: UIButton {
    
    var isValid: Binder<Bool> {
        return Binder(self.base) { (button, valid) in
            button.alpha = valid ? 1 : 0.5
            button.isUserInteractionEnabled = valid
        }
    }
    
    var selected: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: [.allEvents, .valueChanged],
                                       getter: { (button) -> Bool in
                                                    return button.isSelected
                                                },
                                       setter: { (button, selected) in
                                            if button.isSelected != selected {
                                                button.isSelected = selected
                                            }
                                        })
    }
    
}

extension Observable where Element: FloatingPoint {
    public static func timerRun(duration: TimeInterval = .infinity, interval: TimeInterval = 1, ascending: Bool = false, scheduler: SchedulerType = MainScheduler.instance) -> Observable<TimeInterval> {
        let repeatTimes = duration == .infinity ? Int.max : (Int(duration / interval) + 1)
        return Observable<Int>.timer(0, period: interval, scheduler: scheduler)
            .map {TimeInterval($0) * interval}
            .map {ascending ? $0 : (duration - $0)}
            .take(repeatTimes)
    }
}
