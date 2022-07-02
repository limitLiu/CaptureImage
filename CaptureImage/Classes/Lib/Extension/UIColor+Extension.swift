//
//  UIColor+Extension.swift
//  CaptureImage
//
//  Created by limit on 2022/6/27.
//

import UIKit

extension UIColor {
  convenience init(hex: Int) {
    self.init(hex: hex, alpha: 1.0)
  }
  
  convenience init(hex: Int, alpha: CGFloat) {
    let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
    let green = CGFloat((hex & 0xff00) >> 8) / 255.0
    let blue = CGFloat((hex & 0xff)) / 255.0
    
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  open class var label: UIColor {
    return UIColor(hex: 0x999999)
  }
}
