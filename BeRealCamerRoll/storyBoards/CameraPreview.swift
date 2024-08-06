//
//  CameraPreview.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 04/08/2024.
//

import UIKit
import AVFoundation

class CameraPreview: UIView {
  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    guard let layer = layer as? AVCaptureVideoPreviewLayer else {
      fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
    }
    
    return layer
  }
  
  override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
}
