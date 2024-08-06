//
//  MultiCamManger.swift
//
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import AVFoundation

final class MultiCamManger {
  private let multiCamSession = AVCaptureMultiCamSession()
  
  private var frontPreviewLayer: AVCaptureVideoPreviewLayer?
  private var backPreviewLayer: AVCaptureVideoPreviewLayer?
  
  private var frontPreviewConnection: AVCaptureConnection?
  private var backPreviewConnection: AVCaptureConnection?
  
  private var frontCameraInputPorts: AVCaptureDeviceInput.Port?
  private var backCameraInputPorts: AVCaptureDeviceInput.Port?
}
