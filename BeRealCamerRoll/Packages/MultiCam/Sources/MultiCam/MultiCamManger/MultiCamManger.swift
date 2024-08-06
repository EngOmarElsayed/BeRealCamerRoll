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
  
  private var frontCameraOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
  private var backCameraOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
  
  private lazy var captureSettings: AVCapturePhotoSettings = {
    let settings = AVCapturePhotoSettings()
    settings.flashMode = .auto
    
    return settings
  }()
  
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
    guard AVCaptureDevice.authorizationStatus(for: .video) != .authorized else {
      completion(true)
      return
    }
    AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
  }
  
  public func setUpCamera() {
    multiCamSessionQueue.async { [weak self] in
      guard let self else { return }
      setUpInputPorts()
      setPreviewConnection()
      setupOutput()
      multiCamSession.startRunning()
    }
  }
  
  public func captureImages(_ frontCameraCompletion: @escaping (Data?) -> Void, _ backCameraCompletion: @escaping (Data?) -> Void) {
    let frontCameraDelegate = FrontCameraImageProcessor(frontCameraCompletion: frontCameraCompletion)
    let backCameraDelegate = BackCameraImageProcessor(backCameraCompletion: backCameraCompletion)
    frontCameraOutput.capturePhoto(with: AVCapturePhotoSettings(from: captureSettings), delegate: frontCameraDelegate)
    backCameraOutput.capturePhoto(with: AVCapturePhotoSettings(from: captureSettings), delegate: backCameraDelegate)
  }
  
  public func togglePreviewConnection() {
    multiCamSessionQueue.async { [weak self] in
      guard let self else { return }
      multiCamSession.beginConfiguration()
      defer { multiCamSession.commitConfiguration() }
      multiCamSession.removeConnection(frontPreviewConnection!)
      multiCamSession.removeConnection(backPreviewConnection!)
      
      if frontCameraPreviewPosition == .front {
        frontPreviewConnection = setConnectionBetween(frontCameraInputPorts!, backPreviewLayer!)
        backPreviewConnection = setConnectionBetween(backCameraInputPorts!, frontPreviewLayer!)
        frontCameraPreviewPosition = .back
      } else {
        frontPreviewConnection = setConnectionBetween(frontCameraInputPorts!, frontPreviewLayer!)
        backPreviewConnection = setConnectionBetween(backCameraInputPorts!, backPreviewLayer!)
        frontCameraPreviewPosition = .front
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
  
  private func setupOutput() {
    setConnectionBetween(frontCameraInputPorts!, frontCameraOutput)
    setConnectionBetween(backCameraInputPorts!, backCameraOutput)
  }
  
  private func setConnectionBetween(_ input:  AVCaptureInput.Port, _ output: AVCaptureOutput) {
    let connection = AVCaptureConnection(inputPorts: [input], output: output)
    guard multiCamSession.canAddConnection(connection) else { return }
    multiCamSession.addConnection(connection)
  }
  
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
