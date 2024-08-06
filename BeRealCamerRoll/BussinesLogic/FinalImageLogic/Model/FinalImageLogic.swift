//
//  FinalImageLogic.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import Foundation
import Injection
import class CoreGraphics.CGImage

final class FinalImageLogic {
  @Injected(\.multiCamManger) private var multiCamManger
}

extension FinalImageLogic: FinalImageLogicProtocol {
  func captureImage(frontImageCompletion: @escaping (Data?) -> Void, backImageCompletion: @escaping (Data?) -> Void) {
    multiCamManger.captureImages { frontImage in
      frontImageCompletion(frontImage)
    } backCameraCompletion: { backImage in
      backImageCompletion(backImage)
    }
  }
}
