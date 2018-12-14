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
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self) {
            self.iconLabel.backgroundColor = .white
            self.titleLabel.textColor = .white
        } else {
            self.iconLabel.backgroundColor = .black
            self.titleLabel.textColor = .black
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
