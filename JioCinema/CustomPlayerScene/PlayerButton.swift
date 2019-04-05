//
//  PlayerButton.swift
//  JioCinema
//
//  Created by Shweta Adagale on 04/04/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class PlayerButton: UIView {
    var buttonItem : PlayerButtonItem!
    @IBOutlet weak var playerButton: JCPlayerButton!
    @IBOutlet weak var titleOfButton: UILabel!
    func configButtons(buttonItem: PlayerButtonItem) {
        playerButton.setImage(UIImage(named: buttonItem.selectedImage), for: .normal)
        titleOfButton.text = buttonItem.titleOfButton
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
