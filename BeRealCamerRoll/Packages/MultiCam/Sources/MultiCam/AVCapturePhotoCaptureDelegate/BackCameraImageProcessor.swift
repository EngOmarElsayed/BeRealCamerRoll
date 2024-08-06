//
//  BackCameraImageProcessor.swift
//
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import AVFoundation

final class BackCameraImageProcessor: NSObject {
  var backCameraCompletion: ((Data?) -> Void) = { _ in }
}

extension BackCameraImageProcessor: AVCapturePhotoCaptureDelegate {
  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: (any Error)?
  ) {
    if error == nil {
      backCameraCompletion(photo.fileDataRepresentation())
    }
    #warning("Handle this error after finishing the implementation")
  }
}
