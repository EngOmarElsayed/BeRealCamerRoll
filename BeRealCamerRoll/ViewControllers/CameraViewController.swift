//
//  ViewController.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 04/08/2024.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
  let avCapture: AVCaptureMultiCamSession = AVCaptureMultiCamSession()
  var frontPreview: AVCaptureVideoPreviewLayer!
  var backPreview: AVCaptureVideoPreviewLayer!
  var backCameraPreviewConnection: AVCaptureConnection!
  var frontCameraPreviewConnection: AVCaptureConnection!
  var backCameraPhotoPorts: AVCaptureInput.Port!
  var frontCameraPhotoPorts: AVCaptureInput.Port!
  
  
  private let frontCameraPhotoDataOutput = AVCapturePhotoOutput()
  private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
  private var pipDevicePosition: AVCaptureDevice.Position = .front
  
  @IBOutlet private var frontCameraPiPConstraints: [NSLayoutConstraint]!
  @IBOutlet private var backCameraPiPConstraints: [NSLayoutConstraint]!
  
  @IBOutlet var frontCameraView: CameraPreview!
  @IBOutlet var backCameraView: CameraPreview!
  
  @IBAction func captureButton(_ sender: UIButton) {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    
    let togglePiPDoubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(togglePiP))
    view.addGestureRecognizer(togglePiPDoubleTapGestureRecognizer)
  }
  
  private func setupView() {
    setupViewAppearance()
    setupPreviewLayers()
    
    sessionQueue.async { [weak self] in
      guard let self else { return }
      requestAccessForCamera()
    }
  }
  
  private func setupPreviewLayers() {
    frontPreview = frontCameraView.videoPreviewLayer
    backPreview = backCameraView.videoPreviewLayer
    frontPreview.setSessionWithNoConnection(avCapture)
    backPreview.setSessionWithNoConnection(avCapture)
  }
  
  private func setupViewAppearance() {
    frontCameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
    backCameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
    
    frontCameraView.videoPreviewLayer.borderWidth = 1.0
    frontCameraView.videoPreviewLayer.borderColor = UIColor.white.cgColor
    backCameraView.videoPreviewLayer.borderWidth = 1.0
    backCameraView.videoPreviewLayer.borderColor = UIColor.white.cgColor
    
    frontCameraView.videoPreviewLayer.cornerRadius = 20
    backCameraView.videoPreviewLayer.cornerRadius = 25
    
    backCameraView.clipsToBounds = true
    frontCameraView.clipsToBounds = true
  }
}


//MARK: -  AVMultiCamSetup
extension CameraViewController {
  private func requestAccessForCamera() {
    avCapture.beginConfiguration()
    defer { avCapture.commitConfiguration() }
    
    AVCaptureDevice.requestAccess(for: .video) { _ in }
    guard AVCaptureMultiCamSession.isMultiCamSupported else { return }
    
    guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
    guard let inputDevice = try? AVCaptureDeviceInput(device: frontCamera) else { return }
    guard avCapture.canAddInput(inputDevice) else { return }
    
    avCapture.addInputWithNoConnections(inputDevice)
    frontCameraPhotoPorts = inputDevice.ports(for: .video, sourceDeviceType: frontCamera.deviceType, sourceDevicePosition: frontCamera.position).first!
    
    
    guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
    guard let backCamerainput = try? AVCaptureDeviceInput(device: backCamera) else { return }
    guard avCapture.canAddInput(backCamerainput) else { return }
    
    avCapture.addInputWithNoConnections(backCamerainput)
    backCameraPhotoPorts = backCamerainput.ports(for: .video, sourceDeviceType: backCamera.deviceType, sourceDevicePosition: backCamera.position).first!
    
    
    backCameraPreviewConnection = AVCaptureConnection(inputPort: backCameraPhotoPorts, videoPreviewLayer: backPreview)
    guard avCapture.canAddConnection(backCameraPreviewConnection) else { return }
    
    avCapture.addConnection(backCameraPreviewConnection)
    
    frontCameraPreviewConnection = AVCaptureConnection(inputPort: frontCameraPhotoPorts, videoPreviewLayer: frontPreview)
    guard avCapture.canAddConnection(frontCameraPreviewConnection) else { return }
    
    avCapture.addConnection(frontCameraPreviewConnection)

    
    avCapture.commitConfiguration()
    avCapture.startRunning()
  }
  
  @objc
  private func togglePiP() {
    avCapture.stopRunning()
    avCapture.beginConfiguration()
    
    avCapture.removeConnection(backCameraPreviewConnection)
    avCapture.removeConnection(frontCameraPreviewConnection)
    
    backCameraPreviewConnection = AVCaptureConnection(inputPort: backCameraPhotoPorts, videoPreviewLayer: pipDevicePosition == .front ? frontPreview: backPreview)
    
    
    guard avCapture.canAddConnection(backCameraPreviewConnection) else { return }
    
    avCapture.addConnection(backCameraPreviewConnection)
    
    frontCameraPreviewConnection = AVCaptureConnection(inputPort: frontCameraPhotoPorts, videoPreviewLayer: pipDevicePosition == .front ? backPreview: frontPreview)
    
    
    guard avCapture.canAddConnection(frontCameraPreviewConnection) else { return }
    
    avCapture.addConnection(frontCameraPreviewConnection)
    
    avCapture.commitConfiguration()
    avCapture.startRunning()
    pipDevicePosition = pipDevicePosition == .front ? .back: .front
  }
}

