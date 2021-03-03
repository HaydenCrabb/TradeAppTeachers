//
//  signUpScreen.swift
//  TradeApp Teachers
//
//  Created by Hayden Crabb on 2/21/17.
//  Copyright © 2017 Coconut Productions. All rights reserved.
//

import UIKit
import Firebase

class signUpScreen: UIViewController
{
    override func viewDidLoad() {
        errorMessageLabel.isHidden = true
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil
            {
                self.reset()
               self.performSegue(withIdentifier: "signupToOverview", sender: nil)
            }
        })
    }
    func removeSpecialCharsFromString(text: String) -> String
    {
        let okayChars : Set<Character> =
            Set(".#$[]")
        let cleanedUsername = String(text.filter {!okayChars.contains($0) })
        return cleanedUsername
        
    }
    @IBAction func SignUpDidtouch(_ sender: Any) {
        if emailSignup.text != "" && passwordSignup.text != "" && UsernameTextEnter.text != ""
        {
            let cleanedUsername = removeSpecialCharsFromString(text: UsernameTextEnter.text!)
            FIRAuth.auth()?.createUser(withEmail: self.emailSignup.text!, password: self.passwordSignup.text!) { user, error in
                if error == nil
                {
                    let newUsers = FIRDatabase.database().reference(withPath: "AllUsers").child("\(user!.uid)")
                    newUsers.child("Username").setValue("\(cleanedUsername)")
                    newUsers.child("TeacherInfo").child("PossibleClasses").setValue(otherInformation.totalPossibleNumberOfClasses)
                    otherInformation.currentUsersUID = user!.uid
                    otherInformation.currentUsersUsername = cleanedUsername
                    FIRAuth.auth()?.signIn(withEmail: self.emailSignup.text!, password: self.passwordSignup.text!)
                }
                else
                {
                    self.errorMessageLabel.isHidden = false
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.errorMessageLabel.text = "Please enter a valid email."
                        case .errorCodeEmailAlreadyInUse:
                            self.errorMessageLabel.text = "That email is already in use."
                        default:
                            self.errorMessageLabel.text = "Unknown error."
                        }
                    }
                }
            }
        }
        else
        {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "Please fill in all fields."
        }
    }
    func reset()
    {
        self.passwordSignup.text = ""
        self.errorMessageLabel.isHidden = true
        self.emailSignup.text = ""
        
    }
    @IBAction func BackButtonDidTouch(_ sender: Any) {
        reset()
        performSegue(withIdentifier: "backToLogin", sender: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBOutlet var UsernameTextEnter: UITextField!
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var emailSignup: UITextField!
    @IBOutlet var passwordSignup: UITextField!

}
