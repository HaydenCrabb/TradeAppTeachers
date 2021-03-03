//
//  ViewController.swift
//  TradeApp Teachers
//
//  Created by Hayden Crabb on 2/15/17.
//  Copyright © 2017 Coconut Productions. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    var stopThat:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        errorMessageLabel.isHidden = true
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil
            {
                self.reset()
                if self.stopThat
                {
                    self.stopThat = false
                    otherInformation.currentUsersUID = (user!.uid)
                    
                }
               // UsersInfo.emailString = user!.email!
                self.performSegue(withIdentifier: "toClassesOverview", sender: nil)
            }
        })
    
    }

    @IBAction func loginButtonDidTouch(_ sender: Any) {
        if emailtextEnter.text != "" && passwordTextEnter.text != ""
        {
            FIRAuth.auth()?.signIn(withEmail: emailtextEnter.text!, password: passwordTextEnter.text!, completion: {  (user, error) in
                
                if error != nil
                {
                    self.errorMessageLabel.isHidden = false
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.errorMessageLabel.text = "Please enter a valid email."
                        case .errorCodeWrongPassword:
                            self.errorMessageLabel.text = "Inccorrect Password."
                        case .errorCodeUserNotFound:
                            self.errorMessageLabel.text = "User not found!"
                        default:
                            self.errorMessageLabel.text = "Unknown error."
                        }
                    }

                }
            
            })
        }
        else
        {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "Please Enter your Email and Password."
        }
    }
    @IBAction func forgotPasswordDidTouch(_ sender: Any) {
        let alert = UIAlertController(title: "Password Reset", message: "Enter your email to reset your password.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        alert.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
            let textField = alert.textFields![0]
            if textField.text != ""
            {
                FIRAuth.auth()?.sendPasswordReset(withEmail: textField.text!, completion: { (Error) in
                    self.errorMessageLabel.isHidden = false
                    if Error != nil
                    {
                        self.errorMessageLabel.text = "Email could not be sent."
                    }
                    else
                    {
                        self.errorMessageLabel.text = "Password reset sent succesfully."
                    }
                })
            }
            else
            {
                self.errorMessageLabel.text = "Please Enter an Email."
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }) )
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func SignUpButtonDidTouch(_ sender: Any) {
        reset()
        performSegue(withIdentifier: "toSignUp", sender: nil)
        
    }
    
    func reset()
    {
        self.emailtextEnter.text = ""
        self.passwordTextEnter.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var emailtextEnter: UITextField!
    @IBOutlet var passwordTextEnter: UITextField!

}

