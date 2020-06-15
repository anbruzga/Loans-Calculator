//
//  FirstViewController.swift
//  cwFinCalc
//
//  Created by Antanas Bruzga on 03/03/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit



extension String {
	func toDouble() -> Double? {
		return NumberFormatter().number(from: self)?.doubleValue
	}
}
/*************************************************
* The code for the keyboard has been adapted from:
* Reference: https://stackoverflow.com/questions/47229511/move-keyboard-above-tabviewcontroller-tabbar
* Author: CodingMeSwiftly
* Author page: https://stackoverflow.com/users/2175753/codingmeswiftly
*************************************************/

extension Sequence {
	func last(where predicate: (Element) throws -> Bool) rethrows -> Element? {
		return try reversed().first(where: predicate)
	}
}


//MARK: - Keyboard handling
extension SavingsViewController {
	private var keyboardOffset: CGFloat {
		// Using a fixed value of `49` here, since that's what `UITabBar`s height usually is.
		// You should probably use something like `-tabBarController?.tabBar.frame.height`.
		return -(tabBarController?.tabBar.frame.height)!
		//return -49
	}
	
	private var keyboardWindowPredicate: (UIWindow) -> Bool {
		return { $0.windowLevel > UIWindow.Level.normal }
	}
	
	private var keyboardWindow: UIWindow? {
		return UIApplication.shared.windows.last(where: keyboardWindowPredicate)
	}
	
	
	@objc fileprivate func keyboardWillShow(notification: Notification) {
		if let keyboardWindow = keyboardWindow {
			keyboardWindow.frame.origin.y = keyboardOffset
		}
	}
	
	@objc fileprivate func keyboardWillHide(notification: Notification) {
		if let keyboardWindow = keyboardWindow {
			keyboardWindow.frame.origin.y = 0
		}
	}
}
/*************************************************
 * End of reference
*************************************************/


class SavingsViewController: UIViewController {
	
	@IBOutlet weak var principalAmountTextField: UITextField!
	@IBOutlet weak var calculateButton: UIButton!
	@IBOutlet weak var interestTextField: UITextField!
	@IBOutlet weak var paymentTextField: UITextField!
	@IBOutlet weak var futureValueTextField: UITextField!
	@IBOutlet weak var totalNoOfPaymentsTextField: UITextField!
	
	let colourOK = UIColor.green
	let colourBad = UIColor.yellow
	var colourNormal = UIColor.white
	let colourError = UIColor.red
	// let defaults = UserDefaults.standard
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MAIN
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Makes keyboard auto on
		principalAmountTextField.becomeFirstResponder()
		
		// Listeners for comma/dot check and for changing colours
		principalAmountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		paymentTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		interestTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		futureValueTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		totalNoOfPaymentsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		
		//Keyboard Observers
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

		
		// Change default colour accordingly to dark/white interface
		( self.traitCollection.userInterfaceStyle == .dark ) ?
			(colourNormal = principalAmountTextField.backgroundColor ?? UIColor.white) :
			(colourNormal = UIColor.white)
		
		
		// Receive if any persistently stored data exists
		if let savingsA = defaults.string(forKey: "savingsA")
		{
			futureValueTextField.text = savingsA
		}
		if let savingsP = defaults.string(forKey: "savingsP")
		{
			principalAmountTextField.text = savingsP
		}
		if let savingsR = defaults.string(forKey: "savingsR")
		{
			interestTextField.text = savingsR
		}
		if let savingsPMT = defaults.string(forKey: "savingsPMT")
		{
			paymentTextField.text = savingsPMT
		}
		if let savingsT = defaults.string(forKey: "savingsT")
		{
			totalNoOfPaymentsTextField.text = savingsT
		}
		
		// Setting tabbar colour
		UITabBar.appearance().barTintColor = UIColor(red: 217/255, green: 235/255, blue: 235/255, alpha: 1.00)
		
		
	}
	
	// Changes colour to white (or dark), but if text is with minus,
	// changes to yellow for a warning
	func changeTextFieldColousToNormal(){
		((principalAmountTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
			(principalAmountTextField.backgroundColor = colourBad) :
			(principalAmountTextField.backgroundColor = colourNormal)
		((paymentTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
			(paymentTextField.backgroundColor = colourBad) :
			(paymentTextField.backgroundColor = colourNormal)
		((interestTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
			(interestTextField.backgroundColor = colourBad) :
			(interestTextField.backgroundColor = colourNormal)
		((futureValueTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
			(futureValueTextField.backgroundColor = colourBad) :
			(futureValueTextField.backgroundColor = colourNormal)
		((totalNoOfPaymentsTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
			(totalNoOfPaymentsTextField.backgroundColor = colourBad) :
			(totalNoOfPaymentsTextField.backgroundColor = colourNormal)
	
	}
	
	
	// Listener method for comma checking and storing the values persistently
	@objc func textFieldDidChange() {
		store()
		changeTextFieldColousToNormal()
		textFieldCommaCheck(principalAmountTextField)
		textFieldCommaCheck(futureValueTextField)
		textFieldCommaCheck(interestTextField)
		textFieldCommaCheck(totalNoOfPaymentsTextField)
		textFieldCommaCheck(paymentTextField)
	}
	
	// Storing all the data persistantly
	func store(){
		defaults.set(futureValueTextField.text!, forKey: "savingsA")
		defaults.set(paymentTextField.text!, forKey: "savingsPMT")
		defaults.set(interestTextField.text!, forKey: "savingsR")
		defaults.set(principalAmountTextField.text!, forKey: "savingsP")
		defaults.set(totalNoOfPaymentsTextField.text!, forKey: "savingsT")
	}
	
	
	// Checks for dot sanity
	func textFieldCommaCheck(_ textField: UITextField){
		// if empty textfield text, stop the function
		if textField.text!.isEmpty {
			return
		}
		// gets the dotsCount in textfield text
		let dotsCount = textField.text!.components(separatedBy: ".").count - 1
		// doesn't allow ".0", because it would then allow "."
		// which would crash the program
		if (textField.text!.count == 1 && dotsCount == 1 ){
			textField.text = ""
			return
		}
		// doesn't allow double dot
		var result = ""
		if dotsCount > 1 {
			var firstDotFound = false
			for c in textField.text! {
				if (!firstDotFound) {
					result.append(c)
					if c == "."{
						firstDotFound = true
					}
				}
				else if (c != ".") {
					result.append(c)
				}
			}
			textField.text = result
		}
		// checks that if there is a minus, give a BAD colour
		if (textField.text!.components(separatedBy: "-").count - 1) > 0{
			textField.backgroundColor = colourBad
		}
		
	}
	
	
	@IBAction func textFieldTouchDown(_ sender: Any) {
		changeTextFieldColousToNormal()
		/* seems unnecessary as its done elsewhere
		textFieldCommaCheck(principalAmountTextField)
		textFieldCommaCheck(futureValueTextField)
		textFieldCommaCheck(interestTextField)
		textFieldCommaCheck(totalNoOfPaymentsTextField)
		textFieldCommaCheck(paymentTextField)
		*/
	}
	
	// CALCULATE BUTTON onclick listener
	@IBAction func touchDownEvent(_ sender: Any) {
		
		changeTextFieldColousToNormal()
		
		
		// VARIABLES
		var missingParts = 0
		
		var PSet = false
		var tSet = false
		var rSet = false
		var ASet = false
		
		var pmtExists = false;
		
		var P = 0.0
		var r =  0.0
		var PMT = 0.0
		var A = 0.0
		var t = 0.0
		let n = 12.0
		
		
		// SETTING UP VALUES, SETTING UP BOOLEANS TO SEE WHICH ONES TO COUNT
		if (principalAmountTextField.text!.isEmpty){
			missingParts+=1
		}
		else {
			(P = Double(principalAmountTextField.text!)!)
			PSet = true
		}
		if (totalNoOfPaymentsTextField.text!.isEmpty){
			missingParts+=1
		}
		else{
			t = Double(totalNoOfPaymentsTextField.text!)! / 12
			tSet = true
		}
		
		if (interestTextField.text!.isEmpty){
			missingParts+=1
		}
		else{
			r = Double(interestTextField.text!)!/100
			rSet = true
		}
		
		if (futureValueTextField.text!.isEmpty){
			missingParts+=1
		}
		else{
			A = Double(futureValueTextField.text!)!
			ASet = true
		}
	
		if ( !paymentTextField.text!.isEmpty ) {
			PMT = Double(paymentTextField.text!)!
			pmtExists = true
			// NOT Setting missingParts=+1 because PMT is optional
		}
		
		if (PMT == 0.0){
			pmtExists = false
		}
		
		
		
		// FIGURING OUT WHAT TO CALCULATE
		/* IF there is less than 1 missing part excluding PMT, check if
		* the values which are needed are in set, if so, give the value.
		* That might seem unecessary, but in some test cases it would take
		* default value to calculate. This prevents from calculating with
		* default values
		*/
		if missingParts <= 1{
			if (principalAmountTextField.isFirstResponder){
				if pmtExists && ASet && rSet && tSet {
					P = PresentValuePmtExists(PMT, t, r, A, n)
				}
				else if (!pmtExists && ASet && rSet && tSet) {
					P = principalAmountLumpSum(A, r, t, 12)
				}
				updateTextField(principalAmountTextField, P)
				
			}
			else if (interestTextField.isFirstResponder){
				if  pmtExists {
					return // not needed according to reqs
				}
				else if (!pmtExists && ASet && PSet && tSet){
					r = interestRateLumpSum(A, P, t, n)
				}
				updateTextField(interestTextField, r)
				
			}
			else if (paymentTextField.isFirstResponder && missingParts == 0){
				PMT = PMTMonthsEnd(A, r, t, n, P)
				updateTextField(paymentTextField, PMT)
			}
			else if (futureValueTextField.isFirstResponder){
				if pmtExists && PSet && rSet && tSet {
					A = futureValueMonthsEnd(PMT, P, r, t, n)
				}
				else if (!pmtExists && PSet && rSet && tSet){
					A = compoundInterestLumpSum(P, r, t, n)
				}
				updateTextField(futureValueTextField, A)
			}
				
			else if (totalNoOfPaymentsTextField.isFirstResponder){
				if pmtExists && ASet && rSet {
					t = timeToAchieveACertainFutureValueMonthsEnd(A, r, n, PMT, P)
				}
				else if (!pmtExists && PSet && rSet && ASet){
					t = formulaForTimeLumpSum(A, P, r, n)
					t = t*12
				}
				updateTextField(totalNoOfPaymentsTextField, t)
			}
		}
			
		// IF THERE IS MORE THAN 1 MISSING PART, any formula won't work,
		// Thus, give error message
		else if missingParts > 1 {
			setColourToError()
		}
	}
	
	// Changes background color of textfield to colourError, if textfield is empty
	func setColourToError(){
		if(principalAmountTextField.text!.isEmpty){
			principalAmountTextField.backgroundColor = colourError
		}
		if(futureValueTextField.text!.isEmpty){
			futureValueTextField.backgroundColor = colourError
		}
		if(interestTextField.text!.isEmpty){
			interestTextField.backgroundColor = colourError
		}
		if(totalNoOfPaymentsTextField.text!.isEmpty){
			totalNoOfPaymentsTextField.backgroundColor = colourError
		}
	}
	
	// Updates textField after calculating through formulas
	func updateTextField(_ textField: UITextField, _ meaning: Double){
		var meaning = meaning
		
		// rounding
		meaning = round(100 * meaning) / 100
		
		// fixes a case when value is given as -0
		if (String(meaning) == "-0.0") {
			meaning = 0
		}
		
		textField.text = String(meaning)
		
		// Change colours
		if (meaning >= 0){
			textField.backgroundColor = colourOK
		}
		else {
			textField.backgroundColor = colourBad
		}
	}
}
