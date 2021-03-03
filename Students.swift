//
//  Students.swift
//  TradeApp Teachers
//
//  Created by Hayden Crabb on 6/23/18.
//  Copyright © 2018 Coconut Productions. All rights reserved.
//

import UIKit
import Firebase

class Students:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var studentsToDisplay:[String] = []
    var classThatWasCalledName:String = ""
    
    override func viewDidLoad() {
        mainTableView.delegate = self;
        mainTableView.dataSource = self;
        removeBannedStudents()
        mainTableView.reloadData()
    }
    func removeBannedStudents()
    {
        studentsToDisplay = []
        for user in otherInformation.allUsersNames
        {
            if user.value == "Active"
            {
                studentsToDisplay.append(user.key)
            }
        }
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            //get the username
            let name:String = studentsToDisplay[indexPath.row]
            otherInformation.allUsersNames[name] = "Gone"
            print(name)
            
            //set their username to Gone!
            let classWereIn = otherInformation.activeClasses[classThatWasCalledName]!
            print(classWereIn)
            FIRDatabase.database().reference(withPath: classWereIn).child("AllUserNames").child(name).setValue("Gone")
            
            //remove them from NamesOfUsers
            FIRDatabase.database().reference(withPath: classWereIn).child("NamesOfUsers").child(name).removeValue()
            
            //remove from individual resource multipliers
            FIRDatabase.database().reference(withPath: classWereIn).child("UserMultipliers").child(name).removeValue()
            
            //remove from view
            self.studentsToDisplay.remove(at: indexPath.row)
            self.mainTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return studentsToDisplay.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell = mainTableView.dequeueReusableCell(withIdentifier: "NamedCell", for: indexPath) as! StudentCell
        myCell.namedCell.text = studentsToDisplay[indexPath.row]
        myCell.name = studentsToDisplay[indexPath.row]
        return myCell
    }

    
    @IBAction func backButtonWasTouched(_ sender: Any) {
        performSegue(withIdentifier: "backToInformation", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is classInformation
        {
            let nextViewController = segue.destination as? classInformation
            nextViewController?.classThatWasCalledName = classThatWasCalledName
        }
    }
    
    @IBOutlet var mainTableView: UITableView!
}
