//
//  ViewController.swift
//  CaptureImage
//
//  Created by limit on 2022/6/26.
//

import UIKit
import SnapKit
import AVFoundation
import PhotosUI

class ViewController: UIViewController {
  private let contentView = ContentView()
  private let tracker = TrackerWrapper(path: Bundle.main.resourcePath!)
  private let session = AVCaptureSession()
  private var picker: PHPickerViewController?
  private let sessionQueue = DispatchQueue(label: "wiki.mdzz.CaptureImage.session")
  private let queue = DispatchQueue(label: "wiki.mdzz.CaptureImage")
}

extension ViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  private func setup() {
    setupImageSelctor()
    view.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
    }
    contentView.setCameraClick(action: capture)
    
    contentView.setImageClick(action: { [weak self] in
      self?.stopPrevCapture(true)
      if let p = self?.picker {
        self?.present(p, animated: true)
      }
    });
  }
  private func setupImageSelctor() {
    var configuration = PHPickerConfiguration()
    configuration.filter = PHPickerFilter.images
    configuration.selectionLimit = 1
    picker = PHPickerViewController(configuration: configuration)
    picker?.delegate = self
    picker?.view.backgroundColor = UIColor.white
  }
  
  private func stopPrevCapture(_ draw: Bool = false) {
    sessionQueue.async { [weak self] in
      if let this = self {
        if this.session.isRunning {
          this.session.stopRunning()
          if let firstInput = this.session.inputs.first {
            this.session.removeInput(firstInput)
          }
          if let firstOutput = this.session.outputs.first {
            this.session.removeOutput(firstOutput)
          }
        }
      }
    }
    tracker.isDraw = draw
    contentView.displayLabel(isHidden: true)
  }
  
  private func capture(currentDevice: AVCaptureDevice) {
    contentView.cancelPreviewFit()
    stopPrevCapture()
    sessionQueue.async { [weak self] in
      if let this = self {
        if let input = try? AVCaptureDeviceInput(device: currentDevice) {
          this.session.addInput(input)
        } else {
          fatalError("Failed to use input.")
        }
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(this, queue: this.queue)
        this.session.addOutput(output)
        this.tracker.isDraw = true
        this.session.commitConfiguration()
        this.session.startRunning()
      }
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return false
  }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    if let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
      tracker.track(buffer, contentView.leftToRight, { [self] yuv in
        contentView.yuv = yuv
      })
    }
  }
}

extension ViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    let itemProvider = results.first?.itemProvider
    if let provider = itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
      provider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
        if image is UIImage, let image = image as? UIImage {
          DispatchQueue.main.async { [weak self] in
            let rational = Rational(approximating: image.size.width / image.size.height)
            self?.contentView.setRatio(rational.denominator, rational.numerator)
            self?.tracker.trackImage(image) { [weak self] yuv in
              self?.contentView.yuv = yuv
            }
          }
        }
      }
    }
  }
}
