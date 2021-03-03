//
//  FinishedScreen.swift
//  TradeApp Teachers
//
//  Created by Hayden Crabb on 6/29/18.
//  Copyright © 2018 Coconut Productions. All rights reserved.
//

import UIKit
import Firebase

class FinishedScreen:UIViewController {
    
    var classThatWasCalledName:String = String()
    let ourActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var contentScrollerAmount:CGFloat = 0
    
    override func viewDidLoad() {
        ourActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ourActivityIndicator.hidesWhenStopped = true
        ourActivityIndicator.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/3, height: self.view.frame.width/3)
        ourActivityIndicator.center = self.view.center
        self.view.addSubview(ourActivityIndicator)
        //download all class information
        createActivityIndicator()
        let classCode:String = otherInformation.activeClasses[classThatWasCalledName]!
        let classRef = FIRDatabase.database().reference(withPath: classCode)
        classRef.observeSingleEvent(of: .value) { (snapshot) in
            self.removeActivityIndicator()
            if snapshot.exists()
            {
                print("Watch out! Just downloaded the whole deal.")
                let everything:[String:Any] = snapshot.value as! [String:Any]
                var leaderboard:[String:[String:Int]] = [:]
                var sortedLeaderboard:[String] = []
                var totalWealth:Int = 0
                var TradedResources: [String:Int] = [:]
                var BoughtThings: [String:Int] = [:]
                var topThreeTraded:[String] = []
                var topThreeBought:[String] = []
                var totalAmountSpent:Int = 0
                if (everything["NamesOfUsers"] != nil)
                {
                    if (!(everything["NamesOfUsers"] as! [String:Any]).isEmpty)
                    {
                        //this segment of code takes the users names as input and begins to generate the JSON
                        let usersArray = everything["NamesOfUsers"] as! [String:[String:Int]]
                        for user in usersArray
                        {
                            leaderboard[user.key] = ["Wealth": user.value["Wealth"]!, "TotalTraded": 0]
                            totalWealth += user.value["Wealth"]!
                        }
                    }
                }
                if (everything["Trades"] != nil)
                {
                    if (!(everything["Trades"] as! [String:Any]).isEmpty)
                    {
                        let trades:[String:[String:Any]] = everything["Trades"] as! [String:[String:Any]]
                        TradedResources = self.determineAmountTraded(leaderboard: &leaderboard, allTrades: trades, firstThreeResources: &topThreeTraded)
                    }
                }
                
                //sort the leaderboard
                sortedLeaderboard = self.sortLeaderBoard(leaderboard: leaderboard)
                
                if everything["BoughtThings"] != nil
                {
                    if (!(everything["BoughtThings"] as! [String:Any]).isEmpty)
                    {
                        BoughtThings = self.determineBoughtThings(boughtThings: everything["BoughtThings"] as! [String:[String:Any]], totalAmountSpent: &totalAmountSpent, firstThreeBought: &topThreeBought)
                        print("Bought Things: \(BoughtThings)\n\n")
                    }
                }
                self.populateScrollerWithStuff(leaderboard: leaderboard, sortedLeaderboard: sortedLeaderboard, totalWealth: totalWealth, Bought: BoughtThings, Traded: TradedResources, topThreeTradedResources: topThreeTraded, topThreeBoughtProducts: topThreeBought, totalSpent: totalAmountSpent)
            }
        }
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
    func sortLeaderBoard(leaderboard: [String:[String:Int]]) -> [String]
    {
        var arrayOfKeys:[String] = Array(leaderboard.keys)
        for i in 0...arrayOfKeys.count - 1
        {
            var greatestKey = i
            for x in i...arrayOfKeys.count - 1
            {
                if leaderboard[arrayOfKeys[x]]!["Wealth"]! > leaderboard[arrayOfKeys[greatestKey]]!["Wealth"]!
                {
                    greatestKey = x
                }
            }
            arrayOfKeys.swapAt(i, greatestKey)
        }
        return arrayOfKeys
    }
    func determineAmountTraded(leaderboard: inout [String:[String:Int]], allTrades:[String:[String:Any]], firstThreeResources: inout [String]) -> [String:Int]
    {
        var totalTraded:[String:Int] = ["Wheat": 0, "Lumber": 0, "Iron": 0, "Glass": 0, "Oil": 0, "Rubber": 0, "Brick": 0, "Spices": 0, "Sugar": 0, "Wool": 0, "Rope": 0, "Stone": 0]
        for trade in allTrades
        {
            //if the trade is accepted we add it on.
            if (trade.value["Active"] as! Int == 1)
            {
                //add the amount the sender gave to their score
                var senderArray:[String:Int] = leaderboard[trade.value["From"] as! String]!
                senderArray["TotalTraded"]! += trade.value["AmountToReceiver"] as! Int
                leaderboard[trade.value["From"] as! String] = senderArray
                
                //add the amount the reciever gave to their score
                var receiverArray:[String:Int] = leaderboard[trade.value["To"] as! String]!
                receiverArray["TotalTraded"]! += trade.value["AmountToSender"] as! Int
                leaderboard[trade.value["To"] as! String] = receiverArray
                
                //add both amounts to the totalTraded, in order to track most traded resources
                totalTraded[trade.value["ResourceToReceiver"] as! String]! += trade.value["AmountToReceiver"] as! Int
                totalTraded[trade.value["ResourceToSender"] as! String]! += trade.value["AmountToSender"] as! Int
            }
        }
        firstThreeResources = determineFirstThree(amounts: totalTraded)
        return totalTraded
    }
    func determineBoughtThings(boughtThings:[String:[String:Any]], totalAmountSpent: inout Int, firstThreeBought:inout[String]) -> [String:Int]
    {
        var totalBoughtProducts:[String:Int] = ["Car": 0, "House": 0, "Boat": 0, "Bread": 0, "Candy": 0]
        for object in boughtThings
        {
            //determine if we bought a product
            if (object.value["Profit"] != nil)
            {
                //we bought a product
                totalBoughtProducts[object.value["BoughtProduct"] as! String]! += object.value["AmountBought"] as! Int
            }
            else if (object.value["AmountSpent"] != nil) //or if we purchased an upgrade
            {
                //we purchased an upgrade, so lets add the amount spent to the totals
                totalAmountSpent += object.value["AmountSpent"] as! Int
            }
        }
        firstThreeBought = determineFirstThree(amounts: totalBoughtProducts)
        return totalBoughtProducts
    }
    func populateScrollerWithStuff(leaderboard:[String:[String:Int]], sortedLeaderboard:[String], totalWealth:Int, Bought:[String:Int], Traded:[String:Int], topThreeTradedResources:[String], topThreeBoughtProducts:[String], totalSpent:Int)
    {
        var totalDistance:CGFloat = 0
        var counter:Int = 1
        let titleLabel:UILabel = UILabel()
        titleLabel.frame = CGRect(x: -mainScrollView.frame.width, y: 0, width: mainScrollView.frame.width, height: 30)
        titleLabel.text = "Leaderboard"
        titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 20)
        titleLabel.textAlignment = .left
        mainScrollView.addSubview(titleLabel)
        //add in leaderboard
        totalDistance += 30

        for user in sortedLeaderboard
        {
            let container:UIView = UIView()
            container.frame = CGRect(x: -mainScrollView.frame.width, y: totalDistance + 5, width: mainScrollView.frame.width, height: self.view.frame.height/10)
            container.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.4)
            container.layer.masksToBounds = true
            container.layer.cornerRadius = 4
            
            let nameLabel:UILabel = UILabel()
            nameLabel.frame = CGRect(x: 5, y: 0, width: container.frame.width/3, height: container.frame.height)
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.textAlignment = .left
            nameLabel.text = "\(counter). \(user)"
            container.addSubview(nameLabel)
            
            let wealthLabel:UILabel = UILabel()
            wealthLabel.frame = CGRect(x: nameLabel.frame.width + 5, y: 0, width: container.frame.width - (nameLabel.frame.width + 10), height: container.frame.height/2)
            wealthLabel.textAlignment = .right
            wealthLabel.adjustsFontSizeToFitWidth = true
            // it would be cool to make a function that takes this int and returns it as a string with commas in the right places.
            wealthLabel.text = "$ \(leaderboard[user]!["Wealth"]!)"
            container.addSubview(wealthLabel)
            
            let tradeLabel:UILabel = UILabel()
            tradeLabel.frame = CGRect(x: nameLabel.frame.width + 5, y: container.frame.height/2, width: container.frame.width - (nameLabel.frame.width + 10), height: container.frame.height/2)
            tradeLabel.textAlignment = .right
            tradeLabel.adjustsFontSizeToFitWidth = true
            tradeLabel.numberOfLines = 0
            tradeLabel.text = "Traded: \(leaderboard[user]!["TotalTraded"]!)"
            
            container.addSubview(tradeLabel)
            
            mainScrollView.addSubview(container)
            totalDistance += container.frame.height + 5
            counter += 1
        }
        
        //create all class wealth
        addAheader(text: "Total Wealth Gained as a Class:", totalDistance: &totalDistance)
        
        let totalWealthLabel:UILabel = UILabel()
        
        totalWealthLabel.frame = CGRect(x: -mainScrollView.frame.width, y: totalDistance + 5, width: mainScrollView.frame.width, height: 30)
        totalWealthLabel.adjustsFontSizeToFitWidth = true
        totalWealthLabel.font = UIFont(name: totalWealthLabel.font.fontName, size: 22)
        totalWealthLabel.textAlignment = .center
        totalWealthLabel.textColor = UIColor(displayP3Red: 60/255, green: 194/255, blue: 4/255, alpha: 1)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        var numberWithCommas:String = numberFormatter.string(from: NSNumber(value:totalWealth))!
        
        totalWealthLabel.text = "$" + numberWithCommas
        mainScrollView.addSubview(totalWealthLabel)
        
        totalDistance += 5 + totalWealthLabel.frame.height
        
        //create most traded resource.
        addAheader(text: "Most traded Resources:", totalDistance: &totalDistance)
        
        //we need to change elements to be a string:Int
        addTopThree(totalDistance: &totalDistance, elements: topThreeTradedResources, usingResources: true, amounts: Traded)
        
        //create most Bought things.
        addAheader(text: "Most Bought Products:", totalDistance: &totalDistance)
        
        addTopThree(totalDistance: &totalDistance, elements: topThreeBoughtProducts, usingResources: false, amounts: Bought)
        
        addAheader(text: "Total Amount Spent", totalDistance: &totalDistance)
        
        let totalSpentLabel:UILabel = UILabel()
        totalSpentLabel.frame = CGRect(x: -mainScrollView.frame.width, y: totalDistance + 5, width: mainScrollView.frame.width, height: 30)
        totalSpentLabel.adjustsFontSizeToFitWidth = true
        totalSpentLabel.font = UIFont(name: totalSpentLabel.font.fontName, size: 22)
        totalSpentLabel.textAlignment = .center
        totalSpentLabel.textColor = UIColor.red
        
        numberWithCommas = numberFormatter.string(from: NSNumber(value:totalSpent))!
        
        totalSpentLabel.text = "$" + numberWithCommas
        mainScrollView.addSubview(totalSpentLabel)
        
        totalDistance += 5 + totalSpentLabel.frame.height
        
        
        //set the mainscroll view to the size we have conflicted with total distance
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: totalDistance)
        
        var timeInterval:Double = 0.3
        for subview in mainScrollView.subviews
        {
            UIView.animate(withDuration: timeInterval) {
                subview.frame = CGRect(x: subview.frame.minX + self.mainScrollView.frame.width, y: subview.frame.minY, width: subview.frame.width, height: subview.frame.height)
            }
            timeInterval += 0.1
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //send back info
        if segue.destination is classInformation
        {
            let vc = segue.destination as? classInformation
            vc?.classThatWasCalledName = classThatWasCalledName
        }
    }
    func addAheader(text:String, totalDistance:inout CGFloat)
    {
        let headerLabel:UILabel = UILabel()
        headerLabel.frame = CGRect(x: -mainScrollView.frame.width, y: totalDistance + 30, width: mainScrollView.frame.width, height: 30)
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.font = UIFont(name: headerLabel.font.fontName, size: 22)
        headerLabel.textAlignment = .center
        headerLabel.text = text
        mainScrollView.addSubview(headerLabel)
        
        totalDistance += headerLabel.frame.height + 30
    }
    
    func determineFirstThree(amounts: [String:Int]) -> [String]
    {
        var arrayOfKeys:[String] = Array(amounts.keys)
        for i in 0...2 // only go to 2, because we only want the first 3
        {
            var greatestKey = i
            for x in i...arrayOfKeys.count - 1
            {
                if amounts[arrayOfKeys[x]]! > amounts[arrayOfKeys[greatestKey]]!
                {
                    greatestKey = x
                }
            }
            arrayOfKeys.swapAt(i, greatestKey)
        }
        
        var results:[String] = []
        var counter = 0
        for element in arrayOfKeys
        {
            results.append(element)
            counter += 1
            if (counter == 3)
            {
                break
            }
        }
        return results
        
    }
    func addTopThree(totalDistance: inout CGFloat, elements:[String], usingResources:Bool, amounts:[String:Int])
    {
        let namer:String = (usingResources ? "resource" : "product")
        var counter:Int = 0
        
        for element in elements
        {
            let Picture:UIImageView = UIImageView()
            var xPosition = (mainScrollView.frame.width/CGFloat(4 - counter)) - mainScrollView.frame.width
            if (counter == 2)
            {
                xPosition = (mainScrollView.frame.width * 0.375) - mainScrollView.frame.width
            }
            Picture.frame = CGRect(x: xPosition, y: totalDistance + 5, width: mainScrollView.frame.width/CGFloat(counter + 2), height: mainScrollView.frame.width/CGFloat(counter + 2))
            Picture.image = UIImage(named: "\(namer)\(element)")!
            mainScrollView.addSubview(Picture)
            
            totalDistance += Picture.frame.height + 5
            
            let elementLabel1:UILabel = UILabel()
            elementLabel1.frame = CGRect(x: -mainScrollView.frame.width, y: totalDistance + 5, width: mainScrollView.frame.width, height: 30)
            elementLabel1.textAlignment = .center
            elementLabel1.adjustsFontSizeToFitWidth = true
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let numberWithCommas:String = numberFormatter.string(from: NSNumber(value:amounts[element]!))!
            
            elementLabel1.text = "\(counter + 1). \(element): \(numberWithCommas)"
            mainScrollView.addSubview(elementLabel1)
            
            totalDistance += elementLabel1.frame.height + 5
            counter += 1
        }
        
    }
    
    @IBAction func backButtonWasTouched(_ sender: Any) {
        //play sound
        self.performSegue(withIdentifier: "backFromFinished", sender: nil)
    }
    
    @IBOutlet var mainScrollView: UIScrollView!
}
