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
  
  private let frontCameraPhotoDataOutput = AVCapturePhotoOutput()
  private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
  
  @IBOutlet var frontCameraView: CameraPreview!
  @IBOutlet var backCameraView: CameraPreview!
  
  @IBAction func captureButton(_ sender: UIButton) {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
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
    frontCameraView.videoPreviewLayer.setSessionWithNoConnection(avCapture)
    backCameraView.videoPreviewLayer.setSessionWithNoConnection(avCapture)
    frontPreview = frontCameraView.videoPreviewLayer
    backPreview = backCameraView.videoPreviewLayer
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
    let frontCameraPhotoPorts = inputDevice.ports(for: .video, sourceDeviceType: frontCamera.deviceType, sourceDevicePosition: frontCamera.position).first!
    
    
    guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
    guard let backCamerainput = try? AVCaptureDeviceInput(device: backCamera) else { return }
    guard avCapture.canAddInput(backCamerainput) else { return }
    
    avCapture.addInputWithNoConnections(backCamerainput)
    let backCameraPhotoPorts = backCamerainput.ports(for: .video, sourceDeviceType: backCamera.deviceType, sourceDevicePosition: backCamera.position).first!
    
    
    let backCameraPreviewConnection = AVCaptureConnection(inputPort: backCameraPhotoPorts, videoPreviewLayer: backPreview)
    guard avCapture.canAddConnection(backCameraPreviewConnection) else { return }
    
    avCapture.addConnection(backCameraPreviewConnection)
    
    let frontCameraPreviewConnection = AVCaptureConnection(inputPort: frontCameraPhotoPorts, videoPreviewLayer: frontPreview)
    guard avCapture.canAddConnection(frontCameraPreviewConnection) else { return }
    
    avCapture.addConnection(frontCameraPreviewConnection)
    frontCameraPreviewConnection.automaticallyAdjustsVideoMirroring = false
    frontCameraPreviewConnection.isVideoMirrored = true
    
    avCapture.commitConfiguration()
    avCapture.startRunning()
  }
}

