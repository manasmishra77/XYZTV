//
//  ButtonCollectionViewCell.swift
//  JioCinema
//
//  Created by Shweta Adagale on 05/04/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class ButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var buttonTitle: UILabel!
    @IBOutlet weak var playerButton: JCPlayerButton!
    var buttonItem: PlayerButtonItem?
    func configCellView(item: PlayerButtonItem) {
        self.buttonItem = item
        playerButton.setImage(UIImage(named: buttonItem?.unselectedImage ?? ""), for: .normal)
        buttonTitle.text = buttonItem?.titleOfButton
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.buttonTitle.isHidden = false
            if self.buttonTitle.text == "Play" || self.buttonTitle.text == "Pause"{
            } else {
                playerButton.setImage(UIImage(named: buttonItem?.selectedImage ?? ""), for: .normal)
            }
            self.playerButton.backgroundColor = ThemeManager.shared.selectionColor
        } else {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.buttonTitle.isHidden = true
            if self.buttonTitle.text == "Play" || self.buttonTitle.text == "Pause"{
            } else {
                playerButton.setImage(UIImage(named: buttonItem?.unselectedImage ?? ""), for: .normal)
            }
            self.playerButton.backgroundColor = .clear
        }
    }
    deinit {
        print("ButtonCollectionViewCell deinit called")
    }
}
