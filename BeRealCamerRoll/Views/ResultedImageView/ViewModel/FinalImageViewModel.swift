//
//  FinalImageViewModel.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import UIKit
import Injection

class FinalImageViewModel {
  @Published var frontImage: UIImage?
  @Published var backImage: UIImage?
  
  @Injected(\.finalImageLogic) private var finalImageLogic
}

extension FinalImageViewModel {
  func captureImages() {
    finalImageLogic.captureImage { [weak self] frontImageData in
      guard let self, let frontImageData else { return }
      
      DispatchQueue.main.async {
        self.frontImage = UIImage(data: frontImageData)
      }
    } backImageCompletion: { [weak self] backImageData in
      guard let self, let backImageData else { return }
      
      DispatchQueue.main.async {
        self.backImage = UIImage(data: backImageData)
      }
    }
  }
}
