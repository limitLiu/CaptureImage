//
//  UIFont+Extension.swift
//  CaptureImage
//
//  Created by limit on 2022/6/27.
//

import UIKit

enum FontSize: CGFloat {
  case ExtraSmall = 11.0
  case Small = 13.0
  case Medium = 15.0
  case Large = 17.0
  case ExtraLarge = 21.0
}

extension UIFont {
  class func iconfont(ofSize: CGFloat) -> UIFont? {
    return UIFont(name: "iconfont", size: ofSize)
  }
  
  class func fontSize(with size: FontSize) -> UIFont? {
    return UIFont.systemFont(ofSize: size.rawValue)
  }
  
  class func fontSize(with size: FontSize, weight: UIFont.Weight) -> UIFont? {
    return UIFont.systemFont(ofSize: size.rawValue, weight: weight)
  }
}

enum IconFont: String {
  case photo = "\u{e655}"
  case camera = "\u{e61b}"
}
