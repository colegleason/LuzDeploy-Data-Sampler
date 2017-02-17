//
//  ActiveTextFieldDelegate.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/17/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import Foundation
import UIKit

// Keeps track of the active text field which may be used by a view
// conroller for keyboard management.
class ActiveTextFieldDelegate: NSObject, UITextFieldDelegate {
    public var activeTextField: UITextField?
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
