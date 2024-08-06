//
//  MultiCamMangerProtocol.swift
//
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import AVFoundation

protocol MultiCamMangerProtocol {
  func initPreviewLayers(_ frontPreview: AVCaptureVideoPreviewLayer, _ backPreview: AVCaptureVideoPreviewLayer)
  func requestAccess(_ completion: @escaping (Bool) -> Void)
  func setUpCamera()
  func togglePreviewConnection()
}
