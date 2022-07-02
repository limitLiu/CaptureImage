//
//  UIControl+Extension.swift
//  Munmu
//
//  Created by limit on 2022/5/3.
//

import UIKit

typealias ControlEventsAction = () -> Void

extension UIControl {
  func addHandle(for event: UIControl.Event = .touchUpInside, _ closure: @escaping ControlEventsAction) -> Void {
    addAction(UIAction { action in closure() }, for: event)
  }
}

private var btnHandle = 82_399_923
extension UIButton {
  var click: ControlEventsAction? {
    set {
      objc_setAssociatedObject(self, &btnHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      addHandle(newValue ?? {})
    }
    get {
      return objc_getAssociatedObject(self, &btnHandle) as? ControlEventsAction
    }
  }
}
