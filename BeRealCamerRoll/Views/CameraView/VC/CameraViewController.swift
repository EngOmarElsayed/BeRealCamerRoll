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


import UIKit
import Combine

class CameraViewController: UIViewController {
  private let viewModel = CameraViewModel()
  private var cancellable = Set<AnyCancellable>()
  
  @IBOutlet var frontCameraView: CameraPreview!
  @IBOutlet var backCameraView: CameraPreview!
  
  @IBAction func captureButton(_ sender: UIButton) {
    performSegue(withIdentifier: "FinalImageSegue", sender: nil)
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

