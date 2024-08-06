//
//  CameraLogicProtocol.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import Foundation

protocol CameraLogicProtocol {
  func requestAccessForCamera(_ completion: @escaping (Bool) -> Void)
  func setUpCamera(for preview: PreviewLayerAdaptor)
  func toggleCameraPreview()
}
