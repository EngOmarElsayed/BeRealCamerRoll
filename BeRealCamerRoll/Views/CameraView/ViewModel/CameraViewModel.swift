//
//  CameraViewModel.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import Foundation
import Injection
import Combine

class CameraViewModel {
  @Published var isAccessForCameraAllowed: Bool = true
  var previewLayers: PreviewLayerAdaptor?
  
  @Injected(\.cameraLogic) private var cameraLogic
}

extension CameraViewModel {
  func requestAccessForCamera() {
    cameraLogic.requestAccessForCamera { [weak self] isAccessForCameraAllowed in
      guard let self else { return }
      DispatchQueue.main.async {
        self.isAccessForCameraAllowed = isAccessForCameraAllowed
      }
      setupCamera()
    }
  }
  
  func setupCamera() {
    guard let previewLayers else { fatalError("previewLayers are equal nil") }
    guard isAccessForCameraAllowed else { return }
    cameraLogic.setUpCamera(for: previewLayers)
  }
}
