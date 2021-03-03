//
//  StudentCell.swift
//  TradeApp Teachers
//
//  Created by Hayden Crabb on 6/23/18.
//  Copyright © 2018 Coconut Productions. All rights reserved.
//

import UIKit

class StudentCell:UITableViewCell {
    var name:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    public func getName() -> String
    {
        return name
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
    @IBOutlet var namedCell: UILabel!
}
