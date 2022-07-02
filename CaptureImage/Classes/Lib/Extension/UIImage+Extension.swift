//
//  UIImage+Extension.swift
//  CaptureImage
//
//  Created by limit on 2022/6/30.
//

import UIKit

extension UIImage {
  convenience init(from font: IconFont, textColor: UIColor = .label, backgroundColor: UIColor = .clear, size: CGSize) {
    let drawText = font
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    let fontSize = min(size.width / 1.28, size.height)
    let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.iconfont(ofSize: fontSize)!, .foregroundColor: textColor, .backgroundColor: backgroundColor, .paragraphStyle: style]
    let attributeStr = NSAttributedString(string: drawText.rawValue, attributes: attributes)
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    attributeStr.draw(in: CGRect(x: 0, y: (size.height - fontSize) * 0.5, width: size.width, height: size.height))
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    if let image = image {
      self.init(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
    } else {
      self.init()
    }
  }
  
  func pixelBuffer() -> CVPixelBuffer? {
    var pixelBuffer: CVPixelBuffer?
    if let cgImage = self.cgImage {
      let attributes = [
        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
      ] as CFDictionary
      let width = cgImage.width
      let height = cgImage.height
      let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes, &pixelBuffer)
      if status == kCVReturnSuccess, let pixelBuffer = pixelBuffer {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        if let buffer = CVPixelBufferGetBaseAddress(pixelBuffer) {
          let colorSpace = CGColorSpaceCreateDeviceRGB()
          let context = CGContext(data: buffer, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
          context?.concatenate(CGAffineTransform.identity)
          context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
          CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }
      }
    }
    return pixelBuffer
  }
}

