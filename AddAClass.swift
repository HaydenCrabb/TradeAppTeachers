//
//  AddAClass.swift
//  TradeApp Teachers
//
//  Created by Hayden Crabb on 2/15/17.
//  Copyright © 2017 Coconut Productions. All rights reserved.
//

import UIKit
import Firebase

class AddAClass:UIViewController
{
    var classCodes:String = ""
    let ref = FIRDatabase.database().reference()
    var mainScrollView:UIScrollView = UIScrollView()
    var alreadySetUpAssets:Bool = false
    var settings: [String: Bool] = ["NoAssets": false,"FixedResources": false, "CountryInequality": false]
    
    
    override func viewDidLayoutSubviews() {
        if (!alreadySetUpAssets)
        {
            addSettingsToScroller(position: CGPoint(x: 0, y: 0))
        }
        alreadySetUpAssets = true
    }
    
    
    @IBAction func CreateClass(_ sender: Any) {
        if classNameText.text != "" && otherInformation.namesOfActiveClasses.count <= otherInformation.totalPossibleNumberOfClasses && otherInformation.namesOfActiveClasses.contains(classNameText.text!) != true
        {
            let letters : NSString = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(60)
        
                for _ in 0 ... 7
                {
                    let rand = arc4random_uniform(len)
                    var nextChar = letters.character(at: Int(rand))
                    classCodes += NSString(characters: &nextChar, length: 1) as String
                }
            createTheSettings()
            setEndDate()
            ref.child(classCodes).child("Information").child("Multiplier").setValue(1.0) //edit
            let cleanedClassName = removeSpecialCharacters(text: classNameText.text!)
            otherInformation.namesOfActiveClasses.append(cleanedClassName)
            otherInformation.activeClasses["\(cleanedClassName)"] = classCodes
            ref.child("AllUsers").child(otherInformation.currentUsersUID).child("TeacherInfo").child(cleanedClassName).setValue(classCodes)
            ref.child("Classes").child(classCodes).setValue(classCodes)

            performSegue(withIdentifier: "backToOverview", sender: nil)
        }
        else
        {
            if classNameText.text == ""
            {
            classNameText.attributedPlaceholder = NSAttributedString(string:"Enter a name for your class.", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            }
            else if otherInformation.namesOfActiveClasses.contains(classNameText.text!)
            {
                let alert = UIAlertController(title: "Name already used.", message: "You already used this name on an active class, and names may not be repeated.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: "To many classes!", message: "You may only have \(otherInformation.totalPossibleNumberOfClasses) classes. Please delete a class before creating another.", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    func createTheSettings()
    {
        ref.child(classCodes).child("Information").child("Settings").setValue(settings)
    }
    func addSettingsToScroller(position:CGPoint)
    {
        //variables for setup
        var counter:Int = 1
        let settingTexts: [String:String] = ["Country Inequality": "When checked, some countries will start with more resources than others.", "Fixed Resources": "When checked all students will start with a fixed amount of resources and will not gain any more. (The amount depends on the number of days in the class).", "No Assets": "When checked students will not be allowed to purchase upgrades, or pay to produce resources."]
        
        //set up scroll view
        let scrollViewHeight:CGFloat = createClassButton.frame.minY - daysSelector.frame.maxY - 15
        mainScrollView.frame = CGRect(x: daysSelector.frame.minX, y: daysSelector.frame.maxY + 5, width: daysSelector.frame.width, height: scrollViewHeight)
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: self.view.frame.height/5 * CGFloat(settingTexts.count))
        //mainScrollView.showsHorizontalScrollIndicator = false
        
        for setting in settingTexts
        {
            print("creating assest \(setting.key)")
            let yPosition = (self.view.frame.height/5 * CGFloat(counter - 1))
            let containerView:UIView = UIView()
            containerView.tag = counter + 5
            containerView.frame = CGRect(x: 0, y: yPosition, width: mainScrollView.frame.width, height: self.view.frame.height/5)
            
            let checkBoxButton:UIButton = UIButton()
            checkBoxButton.tag = counter
            let checkBoxImage = UIImage(named: "CheckBox")
            checkBoxButton.setImage(checkBoxImage, for: .normal)
            checkBoxButton.addTarget(self, action: #selector(selectABox(pressedButton:)), for: .touchUpInside)
            checkBoxButton.frame = CGRect(x: 5, y: 10, width: containerView.frame.width/7, height: containerView.frame.width/7)
            
            let settingDescription:UILabel = UILabel()
            settingDescription.font = UIFont(name: settingDescription.font.fontName, size: 13)
            settingDescription.adjustsFontSizeToFitWidth = true
            settingDescription.minimumScaleFactor = 0.6
            settingDescription.tag = counter + 13
            settingDescription.numberOfLines = 0
            settingDescription.text = "\(setting.key): \(setting.value)"
            settingDescription.frame = CGRect(x: 5 + checkBoxButton.frame.maxX, y: 10, width: containerView.frame.width - (25 + checkBoxButton.frame.width), height: containerView.frame.height - 15)
            settingDescription.sizeToFit()
            
            containerView.addSubview(checkBoxButton)
            containerView.addSubview(settingDescription)
            
            let image = UIImage(named: "CheckMark")
            let checkMarkImage:UIImageView = UIImageView(image: image!)
            checkMarkImage.tag = counter + 37
            checkMarkImage.frame = CGRect(x: checkBoxButton.frame.minX + 7, y: checkBoxButton.frame.minY - 20, width: checkBoxButton.frame.width, height: checkBoxButton.frame.width * 1.5)
            checkMarkImage.isHidden = true
            containerView.addSubview(checkMarkImage)
            
            mainScrollView.addSubview(containerView)
            counter += 1
        }
        self.view.addSubview(mainScrollView)
        mainScrollView.setContentOffset(position, animated: false)
    }
    @objc func selectABox(pressedButton:UIButton)
    {
        //get the container from which the button was pressed
        let container = self.view.viewWithTag(pressedButton.tag + 5)
        
        //manipulate the text description to get something that looks like "NoAssets"
        let textView:UILabel = container?.viewWithTag(pressedButton.tag + 13)! as! UILabel
        var stripedText = textView.text?.components(separatedBy: ":")
        stripedText![0] = stripedText![0].replacingOccurrences(of: " ", with: "")
        
        //use that string: "NoAssets" to flip the value of the settings at that position
        settings[stripedText![0]] = !(settings[stripedText![0]]!)
        
        //set the check button to be hidden or not hidden depending on the attribute.
        container?.viewWithTag(pressedButton.tag + 37)?.isHidden = !settings[stripedText![0]]!
    }
    
    func setEndDate()
    {
        let numberOfDays = daysSelector.selectedSegmentIndex + 1
        ref.child(classCodes).child("Information").child("NumberOfDays").setValue(Int(numberOfDays))
        ref.child(classCodes).child("Information").child("EndDate").setValue(0)
        
    }
    func removeSpecialCharacters(text: String) -> String
    {
        let okayChars : Set<Character> =
            Set(".#$[]")
        return String(text.filter{!okayChars.contains($0)})
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBOutlet var classNameText: UITextField!
    @IBOutlet var daysSelector: UISegmentedControl!
    
    @IBOutlet var createClassButton: UIButton!
    
}
