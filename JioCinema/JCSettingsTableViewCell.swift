//
//  JCSettingsTableViewCell.swift
//  JioCinema
//
//  Created by Tania Jasam on 8/9/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit


class JCSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var settingsDetailLabel: UILabel!
    @IBOutlet weak var cellAccessoryImage: UIImageView!
    var cellIndexpath = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 10.0
        self.baseView.layer.cornerRadius = 10.0
        self.baseView.layer.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1).cgColor
        // Initialization code
    }
    
    func setCellTag(forCell cellTag: Int) {
        cellIndexpath = cellTag
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
