//
//  RotateBtn.swift
//  CaptureImage
//
//  Created by limit on 2022/6/27.
//

import UIKit

fileprivate let size = CGSize(width: 32, height: 32)

class Btn: UIButton {
  private var img: UIImage?
  
  init(icon: IconFont, size: CGSize = size) {
    super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
    img = UIImage(from: icon, size: size)
    setImage(img, for: .normal)
    setImage(img, for: .highlighted)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
