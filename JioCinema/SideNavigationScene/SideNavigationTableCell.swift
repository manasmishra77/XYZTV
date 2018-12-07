//
//  SideNavigationTableCell.swift
//  JioCinema
//
//  Created by Vinit Somani on 12/6/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class SideNavigationTableCell: UITableViewCell {

    
    @IBOutlet weak var iconLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconLabel.text = "A"        
        titleLabel.text = "ABCD"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
