//
//  ViewController.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 04/08/2024.
//

import UIKit
import Combine

class CameraViewController: UIViewController {
  private let viewModel = CameraViewModel()
  private var cancellable = Set<AnyCancellable>()
  
  @IBOutlet var frontCameraView: CameraPreview!
  @IBOutlet var backCameraView: CameraPreview!
  
  @IBAction func captureButton(_ sender: UIButton) {
    
  }
  
  @IBAction func switchPreviewPlaces(_ sender: UIButton) {
    viewModel.togglePreviewPlaces()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewController()
  }
}

extension CameraViewController {
  private func setupViewController() {
    subscribeForPublishers()
    setupViewAppearance()
    setupPreviewLayers()
    viewModel.requestAccessForCamera()
  }
  
  private func setupPreviewLayers() {
    viewModel.previewLayers = (frontCameraView.videoPreviewLayer, backCameraView.videoPreviewLayer)
  }
  
  private func setupViewAppearance() {
    frontCameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
    backCameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
    
    frontCameraView.videoPreviewLayer.borderWidth = 2.0
    frontCameraView.videoPreviewLayer.borderColor = UIColor.black.cgColor
    
    frontCameraView.videoPreviewLayer.cornerRadius = 20
    backCameraView.videoPreviewLayer.cornerRadius = 25
    
    backCameraView.clipsToBounds = true
    frontCameraView.clipsToBounds = true
  }
  
  private func subscribeForPublishers() {
    viewModel.$isAccessForCameraAllowed.sink { [weak self] isAccessForCameraAllowed in
      guard let self else { return }
      if !isAccessForCameraAllowed { self.createAlertView() }
    }.store(in: &cancellable)
  }
  
  private func createAlertView() {
    let alert = UIAlertController(title: "Alert ‼️", message: "You must allow access to the camera to be able to take photos from the app", preferredStyle: .alert)
    let action = UIAlertAction(title: "Go to app Settings", style: .default) { _ in
      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    alert.addAction(action)
    self.present(alert, animated: true)
  }
}

