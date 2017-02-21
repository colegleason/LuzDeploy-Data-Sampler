//
//  FingerptintParameterViewController.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/17/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import Foundation
import UIKit
import SwiftValidator

class FingerprintParameterViewController : UIViewController, ValidationDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var majorIdField: UITextField!
    @IBOutlet weak var majorIdError: UILabel!
    @IBOutlet weak var latField: UITextField!
    @IBOutlet weak var latError: UILabel!
    @IBOutlet weak var longField: UITextField!
    @IBOutlet weak var longError: UILabel!
    @IBOutlet weak var floorField: UITextField!
    @IBOutlet weak var floorError: UILabel!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var uuidError: UILabel!
    let validator = Validator()
    private var textFieldDelegate: ActiveTextFieldDelegate?
    static let fingerprintVCSegue = "toFingerprinter"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        validator.registerField(majorIdField, errorLabel: majorIdError, rules: [PositiveIntRule()])
        validator.registerField(latField, errorLabel: latError, rules: [FloatRule()])
        validator.registerField(longField, errorLabel: longError, rules: [FloatRule()])
        validator.registerField(floorField, errorLabel: floorError, rules: [PositiveIntRule()])
        validator.registerField(uuidField, errorLabel: uuidError, rules: [UUIDRule()])
        
        majorIdError.isHidden = true
        latError.isHidden = true
        longError.isHidden = true
        floorError.isHidden = true
        uuidError.isHidden = true
        
        textFieldDelegate = ActiveTextFieldDelegate()
        majorIdField.delegate = textFieldDelegate
        floorField.delegate = textFieldDelegate
        uuidField.delegate = textFieldDelegate
        latField.delegate = textFieldDelegate
        longField.delegate = textFieldDelegate
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //MARK: - Keyboard Management Methods
    
    // Call this method somewhere in your view controller setup code.
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillBeShown),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillBeHidden),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWillBeShown(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        let field = textFieldDelegate?.activeTextField
        if (!aRect.contains((field?.frame.origin)!)) {
            scrollView.scrollRectToVisible(field!.frame, animated:true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func buttonPressed() {
        validator.validate(self)
        dismissKeyboard()
    }
    
    func validationSuccessful() {
        print("Validation Successful")
        performSegue(withIdentifier: FingerprintParameterViewController.fingerprintVCSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == FingerprintParameterViewController.fingerprintVCSegue {
            let destination = segue.destination as? FingerprintViewController
            destination?.fingerprintLocations = [
                FingerprintLocation(
                    floor: Int(floorField.text ?? "") ?? 0,
                    lat: Double(latField.text ?? "") ?? 0,
                    long: Double(longField.text ?? "") ?? 0
                )
            ]
            destination?.uuid = UUID(uuidString: uuidField.text ?? "")
            destination?.majorId = Int(majorIdField.text ?? "")
        }
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        print("Validation Failed")
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.isHidden = false
        }
    }
}
