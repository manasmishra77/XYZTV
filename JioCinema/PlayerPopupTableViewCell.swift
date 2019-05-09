//
//  PlayerPopupTableViewCell.swift
//  JioCinema
//
//  Created by Shweta Adagale on 28/03/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class PlayerPopupTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var horizontalBaseLine: UIView!
    @IBOutlet weak var rabioButtonImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self{
            self.backgroundColor =  ThemeManager.shared.selectionColor
        } else {
            self.backgroundColor =  .clear
        }
    }
    

}
