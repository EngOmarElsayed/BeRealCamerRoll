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
  
  func togglePreviewPlaces() {
    cameraLogic.toggleCameraPreview()
  }
  
  func setupCamera() {
    guard let previewLayers else { fatalError("previewLayers are equal nil") }
    guard isAccessForCameraAllowed else { return }
    cameraLogic.setUpCamera(for: previewLayers)
  }
}
