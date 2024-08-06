//
//  FinalImageLogicProtocol.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import Foundation
import class CoreGraphics.CGImage

protocol FinalImageLogicProtocol {
  func captureImage(frontImageCompletion: @escaping (Data?) -> Void, backImageCompletion: @escaping (Data?) -> Void)
}
