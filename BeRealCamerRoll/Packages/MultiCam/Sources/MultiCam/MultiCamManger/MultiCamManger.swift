//
//  MultiCamManger.swift
//
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import AVFoundation

public final class MultiCamManger {
  private let multiCamSession = AVCaptureMultiCamSession()
  private let multiCamSessionQueue = DispatchQueue(label: "session queue")
  
  private var frontPreviewLayer: AVCaptureVideoPreviewLayer?
  private var backPreviewLayer: AVCaptureVideoPreviewLayer?
  
  private var frontPreviewConnection: AVCaptureConnection?
  private var backPreviewConnection: AVCaptureConnection?
  
  private var frontCameraInputPorts: AVCaptureDeviceInput.Port?
  private var backCameraInputPorts: AVCaptureDeviceInput.Port?
  private var frontCameraPreviewPosition: AVCaptureDevice.Position = .front
  
  public init() {}
}

extension MultiCamManger: MultiCamMangerProtocol {
  public func initPreviewLayers(_ frontPreview: AVCaptureVideoPreviewLayer, _ backPreview: AVCaptureVideoPreviewLayer) {
    frontPreviewLayer = frontPreview
    backPreviewLayer = backPreview
    frontPreviewLayer?.setSessionWithNoConnection(multiCamSession)
    backPreviewLayer?.setSessionWithNoConnection(multiCamSession)
  }
  
  public func requestAccess(_ completion: @escaping (Bool) -> Void) {
    guard AVCaptureDevice.authorizationStatus(for: .video) != .authorized else { return }
    AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
  }
  
  public func setUpCamera() {
    multiCamSessionQueue.async { [weak self] in
      guard let self else { return }
      setUpInputPorts()
      setPreviewConnection()
      // private method set output
    }
  }
  
  public func togglePreviewConnection() {
    multiCamSessionQueue.async { [weak self] in
      guard let self else { return }
      multiCamSession.beginConfiguration()
      defer { multiCamSession.commitConfiguration() }
      
      if frontCameraPreviewPosition == .front {
        frontPreviewConnection = setConnectionBetween(frontCameraInputPorts!, backPreviewLayer!)
        backPreviewConnection = setConnectionBetween(backCameraInputPorts!, frontPreviewLayer!)
      } else {
        frontPreviewConnection = setConnectionBetween(frontCameraInputPorts!, frontPreviewLayer!)
        backPreviewConnection = setConnectionBetween(backCameraInputPorts!, backPreviewLayer!)
      }
    }
  }
}

//MARK: -  Private Methods
extension MultiCamManger {
  private func setUpInputPorts() {
    multiCamSession.beginConfiguration()
    defer { multiCamSession.commitConfiguration() }
    frontCameraInputPorts = cameraInputPorts(for: .front)
    backCameraInputPorts = cameraInputPorts(for: .back)
  }
  
  private func setPreviewConnection() {
    guard let frontCameraInputPorts, let frontPreviewLayer else { return }
    guard let backCameraInputPorts, let backPreviewLayer else { return }
    multiCamSession.beginConfiguration()
    defer { multiCamSession.commitConfiguration() }
    
    frontPreviewConnection = setConnectionBetween(frontCameraInputPorts, frontPreviewLayer)
    backPreviewConnection = setConnectionBetween(backCameraInputPorts, backPreviewLayer)
  }
  
  private func setConnectionBetween(_ input:  AVCaptureInput.Port, _ preview: AVCaptureVideoPreviewLayer) -> AVCaptureConnection? {
    let connection = AVCaptureConnection(inputPort: input, videoPreviewLayer: preview)
    guard multiCamSession.canAddConnection(connection) else { return nil }
    multiCamSession.addConnection(connection)
    return connection
  }
  
  private func setConnectionBetween(_ input:  AVCaptureInput.Port, _ output: AVCaptureOutput) {}
  
  private func cameraInputPorts(for position: AVCaptureDevice.Position) ->  AVCaptureInput.Port? {
    guard let camera = AVCaptureDevice.default(
      .builtInWideAngleCamera,
      for: .video,
      position: position
    ) else { return nil }
    
    guard let cameraInputDevice = try? AVCaptureDeviceInput(device: camera) else { return nil }
    guard multiCamSession.canAddInput(cameraInputDevice) else { return nil }
    multiCamSession.addInputWithNoConnections(cameraInputDevice)
    
    return cameraInputDevice.ports(
      for: .video,
      sourceDeviceType: camera.deviceType,
      sourceDevicePosition: camera.position
    ).first
  }
}
