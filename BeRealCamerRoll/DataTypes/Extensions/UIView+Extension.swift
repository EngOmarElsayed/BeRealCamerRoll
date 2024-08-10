//
//  UIView+Extension.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 08/08/2024.
//

import UIKit

extension UIView {
  func convertViewToImage() -> UIImage {
    let render = UIGraphicsImageRenderer(size: self.bounds.size)
    return render.image { _ in
      self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
    }
  }
}
