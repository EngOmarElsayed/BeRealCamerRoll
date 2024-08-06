//
//  Dependencie.swift
//  BeRealCamerRoll
//
//  Created by Eng.Omar Elsayed on 06/08/2024.
//

import Injection
import MultiCam

@InjecteValues extension InjectedValues {
  var multiCamManger: MultiCamMangerProtocol = MultiCamManger()
}
