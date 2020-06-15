	//
	//  CompoundViewController.swift
	//  cwFinCalc
	//
	//  Created by Antanas Bruzga on 03/03/2020.
	//  Copyright © 2020 Antanas Bruzga. All rights reserved.
	//
	
	import UIKit
	
	
	
	/*************************************************
	* The code for the keyboard has been adapted from:
	* Reference: https://stackoverflow.com/questions/47229511/move-keyboard-above-tabviewcontroller-tabbar
	* Author: CodingMeSwiftly
	* Author page: https://stackoverflow.com/users/2175753/codingmeswiftly
	*************************************************/
	
	//MARK: - Keyboard handling
	extension LoanViewController {
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
	
	
	
	
	class LoanViewController: UIViewController {
		
		// Instance Variables
		@IBOutlet weak var tabBar: UITabBarItem!
		@IBOutlet weak var loanAmountTextField: UITextField!
		@IBOutlet weak var interestTextField: UITextField!
		@IBOutlet weak var paymentTextField: UITextField!
		@IBOutlet weak var noOfPaymentsTextField: UITextField!
		
		let colourOK = UIColor.green
		let colourBad = UIColor.yellow
		var colourNormal = UIColor.white
		let colourError = UIColor.red
		
		deinit {
			NotificationCenter.default.removeObserver(self)
		}
		
		// MAIN
		override func viewDidLoad() {
			super.viewDidLoad()
			
			//Keyboard Observers
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
			
			// Makes keyboard auto on
			loanAmountTextField.becomeFirstResponder()
			
			
			// Listeners for comma/dot check and for changing colours
			paymentTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
			interestTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
			loanAmountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
			noOfPaymentsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
			
			
			// Change default colour accordingly to dark/white interface
			( self.traitCollection.userInterfaceStyle == .dark ) ?
				(colourNormal = paymentTextField.backgroundColor ?? UIColor.white) :
				(colourNormal = UIColor.white)
			
			
			// Receive if any persistently stored data exists
			receiveData()
			
		}
		
		func receiveData(){
			if let loansR = defaults.string(forKey: "loansR")
			{
				interestTextField.text = loansR
			}
			if let loansPMT = defaults.string(forKey: "loansPMT")
			{
				paymentTextField.text = loansPMT
			}
			if let loansT = defaults.string(forKey: "loansT")
			{
				noOfPaymentsTextField.text = loansT
			}
			if let loansP = defaults.string(forKey: "loansP")
			{
				loanAmountTextField.text = loansP
			}
		}
		
		@IBAction func textFieldTouchDown(_ sender: Any) {
			changeTextFieldColoursToNormal()
		}
		
		// Changes colour to white (or dark), but if text is with minus,
		// changes to yellow for a warning
		func changeTextFieldColoursToNormal(){
			((loanAmountTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
				(loanAmountTextField.backgroundColor = colourBad) :
				(loanAmountTextField.backgroundColor = colourNormal)
			
			((paymentTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
				(paymentTextField.backgroundColor = colourBad) :
				(paymentTextField.backgroundColor = colourNormal)
			
			((interestTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
				(interestTextField.backgroundColor = colourBad) :
				(interestTextField.backgroundColor = colourNormal)
			
			((noOfPaymentsTextField.text!.components(separatedBy: "-").count - 1) > 0) ?
				(noOfPaymentsTextField.backgroundColor = colourBad) :
				(noOfPaymentsTextField.backgroundColor = colourNormal)
		}
		
		// Listener method for comma checking and storing the values persistently
		@objc func textFieldDidChange() {
			store()
			changeTextFieldColoursToNormal()
			textFieldCommaCheck(loanAmountTextField)
			textFieldCommaCheck(paymentTextField)
			textFieldCommaCheck(interestTextField)
			textFieldCommaCheck(noOfPaymentsTextField)
			
		}
		
		// Storing all the data method
		func store(){
			defaults.set(loanAmountTextField.text!, forKey: "loansP")
			defaults.set(paymentTextField.text!, forKey: "loansPMT")
			defaults.set(interestTextField.text!, forKey: "loansR")
			defaults.set(noOfPaymentsTextField.text!, forKey: "loansT")
			
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
		
		// CALCULATE BUTTON onclick listener
		@IBAction func touchDownCalculate(_ sender: Any) {
			// VARIABLES
			var findPMT = false
			var findYears = false
			var findPresentValue = false
			var lackingInformation = false;
			
			
			var P = 0.0
			var r =  0.0
			var PMT = 0.0
			var t = 0.0
			let n = 12.0
			var years = 0.0
			
			var givenInfoAmount = 0
			
			// SETTING UP VALUES, SETTING UP BOOLEANS TO SEE WHICH ONES TO COUNT
			if (loanAmountTextField.text!.isEmpty ){
				//lackingInformation = true
				findPresentValue = true;
			}
			else {
				P = Double(loanAmountTextField.text!)!
				givenInfoAmount+=1
			}
			
			
			if ( interestTextField.text!.isEmpty )  {
				lackingInformation = true
			}
			else{
				r = Double(interestTextField.text!)!
				r = r / 100.0
				givenInfoAmount+=1
			}
			
			if ( paymentTextField.text!.isEmpty )  {
				findPMT = true
			}
			else{
				PMT = Double(paymentTextField.text!)!
				givenInfoAmount+=1
			}
			
			if (noOfPaymentsTextField.text!.isEmpty){
				findYears = true;
			}
			else{
				t = Double(noOfPaymentsTextField.text!)!
				givenInfoAmount+=1
			}
			
			
			// Checking for contradictions
			if ((findPMT && findYears) || (findPMT && findPresentValue) || (findPresentValue && findYears)){
				lackingInformation = true
			}
			
			
			// If all info is given, count the one that is first responder
			if ( givenInfoAmount == 4){
				if (paymentTextField.isFirstResponder){
					t = t/12
					PMT = mortgagePayments(P, r, n, t)
					updateTextField(paymentTextField, PMT)
				}
				else if (noOfPaymentsTextField.isFirstResponder){
					years = mortgageLengthOfTimeInYears(PMT, P, t, r)
					updateTextField(noOfPaymentsTextField, years*12)
				}
					
				else if (loanAmountTextField.isFirstResponder){
					P = PresentValueMortgage(PMT, t, r, n)
					updateTextField(loanAmountTextField, P)
				}
			}
				
			// If ONE parameter is missing, but the rest are known, calculate the unknown one
			else if !lackingInformation {
				
				if (findPMT){
					t = t/12
					PMT = mortgagePayments(P, r, n, t)
					updateTextField(paymentTextField, PMT)
				}
				else if (findYears){
					years = mortgageLengthOfTimeInYears(PMT, P, t, r)
					updateTextField(noOfPaymentsTextField, years*12)
				}
				else if (findPresentValue){
					P = PresentValueMortgage(PMT, t, r, n)
					updateTextField(loanAmountTextField, P)
				}
				
			}
				
				// IF THERE IS MORE THAN 1 MISSING PART, any formula won't work,
				// Thus, give error message
			else if lackingInformation {
				setColourToError()
			}
			
		}
		
		// Changes background color of textfield to colourError, if textfield is empty
		func setColourToError(){
			if(loanAmountTextField.text!.isEmpty){
				loanAmountTextField.backgroundColor = colourError
			}
			if(noOfPaymentsTextField.text!.isEmpty){
				noOfPaymentsTextField.backgroundColor = colourError
			}
			if(paymentTextField.text!.isEmpty){
				paymentTextField.backgroundColor = colourError
			}
			if(interestTextField.text!.isEmpty){
				interestTextField.backgroundColor = colourError
			}
		}
		
		
		// Sets text for textField
		func updateTextField(_ textField: UITextField, _ meaning: Double){
			var meaning = meaning
			
			// rounding
			meaning = round(100 * meaning) / 100
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
	
