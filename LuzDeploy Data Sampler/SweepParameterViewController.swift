//
//  DataParameterView.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/9/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import Foundation
import UIKit
import SwiftValidator

class SweepParameterViewController : UIViewController, ValidationDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var majorIdField: UITextField!
    @IBOutlet weak var majorIdError: UILabel!
    @IBOutlet weak var minorIdListField: UITextField!
    @IBOutlet weak var minorIdError: UILabel!
    @IBOutlet weak var edgeIdField: UITextField!
    @IBOutlet weak var edgeError: UILabel!
    @IBOutlet weak var startNodeField: UITextField!
    @IBOutlet weak var startError: UILabel!
    @IBOutlet weak var endNodeField: UITextField!
    @IBOutlet weak var endError: UILabel!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var uuidError: UILabel!

    let validator = Validator()
    static let beaconSweepVCSegue = "toBeaconSweeper"
    private var textFieldDelegate: ActiveTextFieldDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        validator.registerField(majorIdField, errorLabel: majorIdError, rules: [PositiveIntRule()])
        validator.registerField(minorIdListField, errorLabel: minorIdError, rules: [BeaconListRule()])
        validator.registerField(edgeIdField, errorLabel: edgeError, rules: [PositiveIntRule()])
        validator.registerField(startNodeField, errorLabel: startError, rules: [PositiveIntRule()])
        validator.registerField(endNodeField, errorLabel: endError, rules: [PositiveIntRule()])
        validator.registerField(uuidField, errorLabel: uuidError, rules: [UUIDRule()])
        
        majorIdError.isHidden = true
        minorIdError.isHidden = true
        edgeError.isHidden = true
        startError.isHidden = true
        endError.isHidden = true
        uuidError.isHidden = true
        
        textFieldDelegate = ActiveTextFieldDelegate()
        majorIdField.delegate = textFieldDelegate
        minorIdListField.delegate = textFieldDelegate
        uuidField.delegate = textFieldDelegate
        edgeIdField.delegate = textFieldDelegate
        startNodeField.delegate = textFieldDelegate
        endNodeField.delegate = textFieldDelegate
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        performSegue(withIdentifier: SweepParameterViewController.beaconSweepVCSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SweepParameterViewController.beaconSweepVCSegue {
            let destination = segue.destination as? BeaconSweepViewController
            destination?.uuid = UUID(uuidString: uuidField.text ?? "")
            destination?.majorId = Int(majorIdField.text ?? "")
            destination?.beaconMinors = Utility.beaconListToSet(beaconList: minorIdListField.text ?? "")
            destination?.edgeId = Int(edgeIdField.text ?? "")
            destination?.startNode = Int(startNodeField.text ?? "")
            destination?.endNode = Int(endNodeField.text ?? "")
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
