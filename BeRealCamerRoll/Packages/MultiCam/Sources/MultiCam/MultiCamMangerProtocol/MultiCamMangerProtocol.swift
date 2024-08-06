//
//  MultiCamMangerProtocol.swift
//
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import AVFoundation

public protocol MultiCamMangerProtocol {
  func initPreviewLayers(_ frontPreview: AVCaptureVideoPreviewLayer, _ backPreview: AVCaptureVideoPreviewLayer)
  func requestAccess(_ completion: @escaping (Bool) -> Void)
  func setUpCamera()
  func captureImages(_ frontCameraCompletion: @escaping (Data?) -> Void, _ backCameraCompletion: @escaping (Data?) -> Void)
  func togglePreviewConnection()
}
