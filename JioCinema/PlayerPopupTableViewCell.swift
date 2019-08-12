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
    
     var isSelectedCell: Bool = false
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
        if context.nextFocusedView == self {
            if isSelectedCell {
                self.rabioButtonImageView.tintColor =  .white
            }
            self.title.textColor = .white
            self.title.font = UIFont(name: "JioType-Medium", size: 36)
            self.backgroundColor =  ThemeManager.shared.selectionColor
        } else {
            self.title.textColor = #colorLiteral(red: 0.6500751972, green: 0.650090754, blue: 0.6500824094, alpha: 0.9957405822)
            self.title.font = UIFont(name: "JioType-Light", size: 36)
            self.backgroundColor =  .clear
            if isSelectedCell {
                self.title.textColor = .white
                self.rabioButtonImageView.tintColor =  ThemeManager.shared.selectionColor
                self.title.font = UIFont(name: "JioType-Medium", size: 36)
            }
        }
    }
    

}
