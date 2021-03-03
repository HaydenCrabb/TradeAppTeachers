//
//  ClassesOverview.swift
//  TradeApp Teachers
//
//  Created by Hayden Crabb on 2/15/17.
//  Copyright © 2017 Coconut Productions. All rights reserved.
//

import UIKit
import Firebase

class ClassesOverview: UIViewController
{
    let ourActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var classToCall:Int = 0
    let mainScrollView:UIScrollView = UIScrollView()
    var alreadySetUpAssets:Bool = false
    var informationDownloaded:Bool = false
    
    override func viewDidLoad() {
        //create activty indicator
        ourActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ourActivityIndicator.hidesWhenStopped = true
        ourActivityIndicator.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/3, height: self.view.frame.width/3)
        ourActivityIndicator.center = self.view.center
        self.view.addSubview(ourActivityIndicator)
        if otherInformation.firstTimeAround == false
        {
            if otherInformation.currentUsersUsername == "T*&#234AaBREkYoung#!Tribe*&&1193847"
            {
                //we don't give one care about their username, don't observe it.
                createActivityIndicator()
                FIRDatabase.database().reference(withPath: "AllUsers").child("\(otherInformation.currentUsersUID)").child("TeacherInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                    self.removeActivityIndicator()
                    if snapshot.exists()
                    {
                        var allInfo = snapshot.value as! [String: Any]
                        if ((allInfo["PossibleClasses"]) != nil)
                        {
                            otherInformation.totalPossibleNumberOfClasses = allInfo["PossibleClasses"] as! Int
                            allInfo.removeValue(forKey: "PossibleClasses")
                        }
                        else{
                            //if "PossibleClasses" does not exist we need to set it.
                            FIRDatabase.database().reference(withPath: "AllUsers").child(otherInformation.currentUsersUID).child("TeacherInfo").child("PossibleClasses").setValue(otherInformation.totalPossibleNumberOfClasses)
                        }
                        //the rest of the things in allInfo are classes (once PossibleClasses is removed)
                        otherInformation.activeClasses = allInfo as! [String : String]
                        for simulation in otherInformation.activeClasses
                        {
                            otherInformation.namesOfActiveClasses.append(simulation.key)
                        }
                        self.setUpClassButtons()

                    }
                })
            }
            otherInformation.firstTimeAround = true // prevent cleaning of emails multiple times.
        }
        else
        {
            _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_) in
                self.setUpClassButtons()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        if (!alreadySetUpAssets)
        {
            let scrollViewHeight:CGFloat = addClassButton.frame.minY - activeClassesLabel.frame.maxY - 15
            mainScrollView.frame = CGRect(x: activeClassesLabel.frame.minX, y: activeClassesLabel.frame.maxY + 5, width: activeClassesLabel.frame.width, height: scrollViewHeight)
            mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: self.view.frame.height/8 * CGFloat(otherInformation.namesOfActiveClasses.count))
            mainScrollView.showsVerticalScrollIndicator = true
            self.view.addSubview(mainScrollView)
        }
        alreadySetUpAssets = true
    }
    func removeSpecialCharacters(text: String) -> String
    {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890@!#$%^&*()?/><")
        return String(text.filter {okayChars.contains($0) })
        
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
    func setUpClassButtons()
    {
            if otherInformation.activeClasses.count != 0
            {
                for elements in 0...(otherInformation.namesOfActiveClasses.count - 1)
                {
                    let container:UIView = UIView()
                    container.frame = CGRect(x: 0, y: (0 + (self.view.frame.height/8 * CGFloat(elements))), width: mainScrollView.frame.width, height: self.view.frame.height/10)
                    container.tag = elements
                    
                    let buttonImage = UIImage(named: "ClassIcon")
                    let framesize:CGRect = CGRect(x: mainScrollView.frame.width * 0.05, y: 0, width: mainScrollView.frame.width * 0.9, height: container.frame.height/1.5)
                    let classImage:UIButton = UIButton(type: UIButtonType.custom) as UIButton
                    classImage.setImage(buttonImage, for: .normal)
                    classImage.frame = framesize
                    classImage.tag = elements
                    classImage.addTarget(self, action: #selector(ClassesOverview.classOverviewInfo(sender:)), for: UIControlEvents.touchUpInside)
                    
                    let buttonLabel:UILabel = UILabel(frame: CGRect(x: classImage.frame.minX, y: classImage.frame.maxY + 3, width: classImage.frame.width, height: container.frame.height/3))
                    buttonLabel.text = "\(otherInformation.namesOfActiveClasses[elements])"
                    container.addSubview(classImage)
                    container.addSubview(buttonLabel)
                    mainScrollView.addSubview(container)
                }
                mainScrollView.setContentOffset(CGPoint(x: 0, y: mainScrollView.contentSize.height - mainScrollView.frame.height), animated: false)
                UIView.animate(withDuration: 1) {
                    self.mainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
            }
    }
    @objc func classOverviewInfo(sender:UIButton)
    {
        classToCall = sender.tag
        performSegue(withIdentifier: "toClassInfo", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is classInformation
        {
            let nextViewController = segue.destination as? classInformation
            nextViewController?.classThatWasCalledName = otherInformation.namesOfActiveClasses[classToCall]
        }
    }
    @IBAction func signOutDidTouch(_ sender: Any) {
        //reset the values
        otherInformation.namesOfActiveClasses = []
        otherInformation.activeClasses = [:]
        otherInformation.currentUsersUID = "XcodeDude"
        otherInformation.firstTimeAround = false
        otherInformation.totalPossibleNumberOfClasses = 4
        
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "toSignOut", sender: nil)
    }
    
    @IBOutlet var teachersLogo: UIImageView!

    @IBOutlet var addClassButton: UIButton!
    @IBOutlet var activeClassesLabel: UILabel!

}
