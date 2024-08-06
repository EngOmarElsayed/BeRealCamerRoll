//
//  CameraLogic.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import Foundation
import Injection

final class CameraLogic {
  @Injected(\.multiCamManger) private var multiCamManger
}

extension CameraLogic: CameraLogicProtocol {
  func requestAccessForCamera(_ completion: @escaping (Bool) -> Void) {
    multiCamManger.requestAccess(completion)
  }
  
  func setUpCamera(for preview: PreviewLayerAdaptor) {
    multiCamManger.initPreviewLayers(preview.front, preview.back)
    multiCamManger.setUpCamera()
  }
}
