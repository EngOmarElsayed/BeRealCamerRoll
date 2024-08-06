//
//  FrontCameraImageProcessor.swift
//
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import AVFoundation

final class FrontCameraImageProcessor: NSObject, AVCapturePhotoCaptureDelegate {
  var frontCameraCompletion: ((Data?) -> Void) = { _ in }
}

extension FrontCameraImageProcessor {
  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: (any Error)?
  ) {
    
    if error == nil {
      frontCameraCompletion(photo.fileDataRepresentation())
    }
    #warning("Handle this error after finishing the implemtation")
  }
}
