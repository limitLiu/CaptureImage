//
//  ContentView.swift
//  CaptureImage
//
//  Created by limit on 2022/6/27.
//

import UIKit
import AVFoundation
import MetalKit

class ContentView: UIView {
  private var glView = GLView(frame: .zero)
  private let label = UILabel()
  private let camera = Btn(icon: .camera)
  private let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
  private let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
  
  public let photo = Btn(icon: .photo, size: CGSize(width: 32, height: 36))
  public var leftToRight: Bool = false
  public var yuv: LLYUVFrame? {
    didSet {
      glView.render(yuv!)
    }
  }
  
  init() {
    super.init(frame: .zero)
    setup()
    self.leftToRight = !self.leftToRight
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ContentView {
  private func setup() {
    label.text = "Select picture or use camera"
    addSubview(glView)
    addSubview(photo)
    addSubview(camera)
    addSubview(label)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    glView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    camera.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.right.equalToSuperview().offset(-10)
    }
    photo.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.right.equalTo(camera).offset(-45)
    }
  }
}

extension ContentView {
  func flip(_ action: @escaping (_ d: AVCaptureDevice) -> Void) {
    UIView
      .transition(with: glView, duration: 0.3, options: leftToRight ? .transitionFlipFromLeft : .transitionFlipFromRight) {
//        self.leftToRight = !self.leftToRight
      } completion: { [weak self] _ in
        if let this = self {
//          let device = this.leftToRight ? this.frontDevice : this.backDevice
//          action(device)
          action(this.frontDevice)
        }
      }
  }
}

extension ContentView {
  public func displayLabel(isHidden: Bool) {
    label.isHidden = isHidden
  }
  
  public func setCameraClick(action: @escaping (_ device: AVCaptureDevice) -> Void) {
    camera.click = { [weak self] in
      self?.flip(action)
    }
  }
  
  public func setImageClick(action: @escaping () -> Void) {
    photo.click = action
  }
  
  public func previewFit() {
    glView.contentMode = .scaleAspectFit
  }
  
  public func cancelPreviewFit() {
    glView.contentMode = .scaleToFill
  }
  
  public func setRatio(_ width: Int, _ height: Int) {
    glView.videoWidth = height
    glView.videoHeight = width
    previewFit()
  }
}
