//
//  ClassInformation.swift
//  TradeApp Teachers
//
//  Created by Hayden Crabb on 2/20/17.
//  Copyright © 2017 Coconut Productions. All rights reserved.
//

import UIKit
import Firebase

class classInformation: UIViewController {
    
    var classThatWasCalledName:String = "Thanks ZV"
    var ThisClassCodeThatsCalled:String = "Thanks DA"
    let ourActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var numberOfDays = 0
    var endingDate:Int = 0
    var timeUpdater:Timer? = nil
    
    override func viewDidLoad()
    {
        //create activty indicator
        ourActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ourActivityIndicator.hidesWhenStopped = true
        ourActivityIndicator.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/3, height: self.view.frame.width/3)
        ourActivityIndicator.center = self.view.center
        self.view.addSubview(ourActivityIndicator)
        //set up variables
        ThisClassCodeThatsCalled = otherInformation.activeClasses[classThatWasCalledName]!
        ActivateButtonOutlet.isHidden = true
        ActivateLabelOutlet.isHidden = true
        classCodesLabel.text = "Class Code: \(ThisClassCodeThatsCalled)"
        classTitle.text = classThatWasCalledName
        NumberOfPlayers.titleLabel?.numberOfLines = 0
        NumberOfPlayers.titleLabel?.adjustsFontSizeToFitWidth = true
        NumberOfPlayers.titleLabel?.textAlignment = .center
        resultsButton.titleLabel?.numberOfLines = 0
        resultsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        resultsButton.titleLabel?.textAlignment = .center
        downloadClassInformation()
        
    }
    @IBAction func DeleteClassButton(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Class?", message: "Are you sure you want to delete this class?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
            var counter:Int = 0
            for classy in otherInformation.namesOfActiveClasses
            {
                if classy == self.classThatWasCalledName
                {
                    otherInformation.namesOfActiveClasses.remove(at: counter)
                }
                counter += 1
            }
            otherInformation.activeClasses.removeValue(forKey: self.classThatWasCalledName)
            let classToRemove = FIRDatabase.database().reference(withPath: "AllUsers").child(otherInformation.currentUsersUID).child("TeacherInfo").child(self.classThatWasCalledName)
            classToRemove.removeValue()
            FIRDatabase.database().reference(withPath: self.ThisClassCodeThatsCalled).removeValue()
            let classInClasses = FIRDatabase.database().reference(withPath: "Classes").child(self.ThisClassCodeThatsCalled)
            classInClasses.removeValue()
            
            //check if they deleted a class that they had bought to create.
            if (otherInformation.totalPossibleNumberOfClasses > 4)
            {
                //if totalPossibleNumberOfClasses is above 4, they purchased this class
                otherInformation.totalPossibleNumberOfClasses -= 1
                FIRDatabase.database().reference(withPath: "AllUsers").child(otherInformation.currentUsersUID).child("TeacherInfo").child("PossibleClasses").setValue(otherInformation.totalPossibleNumberOfClasses)
            }
            
            self.performSegue(withIdentifier: "infoBackToOverview", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }) )
        self.present(alert, animated: true, completion: nil)
    }
    func createActivityIndicator()
    {
        ourActivityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    func removeActivityIndicator()
    {
        ourActivityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    func downloadClassInformation()
    {
        createActivityIndicator()
        FIRDatabase.database().reference(withPath: ThisClassCodeThatsCalled).child("Information").observeSingleEvent(of: .value) { (snapshot) in
            self.removeActivityIndicator()
            if snapshot.exists()
            {
                let allInformation = snapshot.value as! [String:Any]
                if allInformation["NumberOfDays"] != nil
                {
                    //This Class Has Not been Activated!!
                    self.resultsButton.isHidden = true
                    self.ActivateLabelOutlet.isHidden = false
                    self.ActivateButtonOutlet.isHidden = false
                    self.numberOfDays = allInformation["NumberOfDays"] as! Int
                }
                else
                {
                    //This Class Has Been Activated! Lets see how much time is left.
                    self.resultsButton.isHidden = false
                    let currentDate:Int = Int(truncating: NSNumber(value:Date().timeIntervalSince1970))
                    self.endingDate = allInformation["EndDate"] as! Int
                    if (currentDate < self.endingDate)
                    {
                        //this class is still going
                        self.timeUpdater = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimeRemaining), userInfo: nil, repeats: true)
                    }
                    else
                    {
                        //this class has finished
                        self.resultsButton.setTitle("Results →", for: .normal)
                        self.timeRemainingOutlet.text = "This class has finished."
                        //add in button to move to finished screen
                    }
                }
            }
        }
        createActivityIndicator()
        FIRDatabase.database().reference(withPath: ThisClassCodeThatsCalled).child("AllUserNames").observeSingleEvent(of: .value, with: { (snapshot) in
            self.removeActivityIndicator()
            if snapshot.exists()
            {
                //there are users.
                var allUserNames = snapshot.value as! [String:String]
                for user in allUserNames
                {
                    if user.value != "Active"
                    {
                        allUserNames.removeValue(forKey: user.key)
                    }
                }
                otherInformation.allUsersNames = allUserNames 
                self.NumberOfPlayers.setTitle("There \(otherInformation.allUsersNames.count == 1 ? "is" : "are") currently \(otherInformation.allUsersNames.count) \(otherInformation.allUsersNames.count == 1 ? "user" : "users") in your class. →", for: UIControlState.normal)
                self.NumberOfPlayers.isEnabled = true
                
            }
            else {
                //there are no users
                self.NumberOfPlayers.setTitle("There are currently no users for this class.", for: UIControlState.normal)
                self.NumberOfPlayers.isEnabled = false
            }
        })
    }
    
    @IBAction func resultsButtonWasPressed(_ sender: Any) {
        //play sound
        self.performSegue(withIdentifier: "finishedScreen", sender: nil)
    }
    
    
    @IBAction func Players(_ sender: Any) {
        performSegue(withIdentifier: "toStudents", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is Students
        {
            let vc = segue.destination as? Students
            vc?.classThatWasCalledName = classThatWasCalledName
        }
        else if segue.destination is FinishedScreen
        {
            let vc = segue.destination as? FinishedScreen
            vc?.classThatWasCalledName = classThatWasCalledName
        }

    }
    @objc func updateTimeRemaining()
    {
        //I needed to turn this giant interval value into a readable form so we're converting
        //time into days hours minute seconds
        
        let currentDate:Int = Int(truncating: NSNumber(value:Date().timeIntervalSince1970))
        if (currentDate < endingDate)
        {
            var fakeTimeRemaining = endingDate - currentDate
            let days:Int = Int(fakeTimeRemaining / 86400)
            fakeTimeRemaining -= (days * 86400)
            let hours:Int = Int(fakeTimeRemaining / 3600)
            fakeTimeRemaining -= (hours * 3600)
            let minutes:Int = Int(fakeTimeRemaining / 60)
            fakeTimeRemaining -= (minutes * 60)
            let seconds:Int = Int(fakeTimeRemaining)
            timeRemainingOutlet.text = "Time Remaining: \(days) Days, \(hours) Hours, \(minutes) Minutes, and \(seconds) Seconds."
        }
        else
        {
            //this class has finished
            self.timeRemainingOutlet.text = "This class has finished."
            //add in button to move to finished screen
        }
        
    }

    @IBAction func ActivateClassButton(_ sender: Any) {
        self.ActivateButtonOutlet.isHidden = true
        self.ActivateLabelOutlet.isHidden = true
        
        var currentDate:Int = Int(truncating: NSNumber(value:Date().timeIntervalSince1970))
        let secondsInADay = 86400
        var endDate = 0
        endDate = currentDate + (secondsInADay * numberOfDays)
        currentDate -= 3000
        let lenghtOfSimulation = FIRDatabase.database().reference(withPath: ThisClassCodeThatsCalled).child("Information").child("NumberOfDays")
        lenghtOfSimulation.removeValue()
        let activationDate = FIRDatabase.database().reference(withPath: ThisClassCodeThatsCalled).child("Information").child("ActivationDate")
        activationDate.setValue(currentDate)
        let firebaseEndDate = FIRDatabase.database().reference(withPath: ThisClassCodeThatsCalled).child("Information").child("EndDate")
        firebaseEndDate.setValue(endDate)
        downloadClassInformation()
        
    }
    @IBAction func backButtonWasPressed(_ sender: Any) {
        timeUpdater?.invalidate()
        performSegue(withIdentifier: "infoBackToOverview", sender: nil)
        
    }

    @IBOutlet var resultsButton: UIButton!
    @IBOutlet var classTitle: UILabel!
    @IBOutlet var timeRemainingOutlet: UILabel!
    @IBOutlet var NumberOfPlayers: UIButton!
    @IBOutlet var ActivateLabelOutlet: UILabel!
    @IBOutlet var ActivateButtonOutlet: UIButton!
    @IBOutlet var classCodesLabel: UILabel!
}
