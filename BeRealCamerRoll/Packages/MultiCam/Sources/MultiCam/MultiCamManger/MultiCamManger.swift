//MIT License
//
//Copyright (c) 2024 Omar Elsayed
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.


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
  private var frontCameraImageProcessor: FrontCameraImageProcessor = FrontCameraImageProcessor()
  private var backCameraImageProcessor: BackCameraImageProcessor = BackCameraImageProcessor()
  
  private lazy var captureSettings: AVCapturePhotoSettings = {
    let settings = AVCapturePhotoSettings()
    settings.flashMode = .off
    
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
      setupOutputConnections()
      multiCamSession.startRunning()
    }
  }
  
  public func captureImages(frontCameraCompletion: @escaping (Data?) -> Void, backCameraCompletion: @escaping (Data?) -> Void) {
    frontCameraImageProcessor.frontCameraCompletion = frontCameraCompletion
    backCameraImageProcessor.backCameraCompletion = backCameraCompletion
    
    frontCameraOutput.capturePhoto(with: AVCapturePhotoSettings(from: captureSettings), delegate: frontCameraImageProcessor)
    backCameraOutput.capturePhoto(with: AVCapturePhotoSettings(from: captureSettings), delegate: backCameraImageProcessor)
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
  
  private func setupOutputConnections() {
    setConnectionBetween(frontCameraInputPorts!, frontCameraOutput, isVideoMirrored: true)
    setConnectionBetween(backCameraInputPorts!, backCameraOutput)
  }
  
  private func setConnectionBetween(_ input:  AVCaptureInput.Port, _ output: AVCapturePhotoOutput, isVideoMirrored: Bool = false) {
    guard multiCamSession.canAddOutput(output) else { return }
    multiCamSession.addOutputWithNoConnections(output)
    
    let connection = AVCaptureConnection(inputPorts: [input], output: output)
    guard multiCamSession.canAddConnection(connection) else { return }
    multiCamSession.addConnection(connection)
    connection.isVideoMirrored = isVideoMirrored
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
