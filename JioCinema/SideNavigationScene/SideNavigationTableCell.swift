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
    
    @IBOutlet weak var selectionIndicatorView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionIndicatorView.backgroundColor = .clear
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self) {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
        } else {
            self.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.01960784314, blue: 0.2117647059, alpha: 1).withAlphaComponent(1.0)
        }
    }
}
