//
//  YUVF.swift
//  CaptureImage
//
//  Created by limit on 2022/6/30.
//

import Foundation

class YUVData {
  uint32_t len;
  uint8_t * _Nullable data;
}

class YUVFrame {
  var width: Int;
  var height: Int;
  var luma: YUVData;
  var cb;
  YUVData cr;
}
