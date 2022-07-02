//
//  Base+Extension.swift
//  CaptureImage
//
//  Created by limit on 2022/6/29.
//

extension LLVertex {
  public static var sizeof: Int {
    return MemoryLayout<Self>.size
  }
}

extension LLMatrix {
  public static var sizeof: Int {
    return MemoryLayout<Self>.size
  }
}

extension UInt16 {
  public static var sizeof: Int {
    return MemoryLayout<Self>.size
  }
}

struct Rational {
  let numerator : Int
  let denominator: Int
  
  init(numerator: Int, denominator: Int) {
    self.numerator = numerator
    self.denominator = denominator
  }
  
  init(approximating x0: Double, with precision: Double = 1.0E-6) {
    var x = x0
    var a = x.rounded(.down)
    var (h1, k1, h, k) = (1, 0, Int(a), 1)
    
    while x - a > precision * Double(k) * Double(k) {
      x = 1.0/(x - a)
      a = x.rounded(.down)
      (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
    }
    self.init(numerator: h, denominator: k)
  }
}
