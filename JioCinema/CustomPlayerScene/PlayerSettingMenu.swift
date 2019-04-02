//
//  PlayerSettingMenu.swift
//  JioCinema
//
//  Created by Vinit Somani on 3/25/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

enum MenuType: String {
    case multiaudio = "Audio"
    case multilanguage = "Subtitle"
    case videobitratequality = "Video Quality"
}


class PlayerSettingMenu: UIView {
    @IBOutlet weak var menuTable: UITableView!
    var menuType: MenuType?
    var menuItems = [String]()
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var currentSelectedItem: String?
    var priviousSelectedIndexpath: IndexPath = IndexPath(row: 0, section: 0)
    
    
    override func awakeFromNib() {
        menuTable.register(UINib(nibName: "PlayerPopupTableViewCell", bundle: nil), forCellReuseIdentifier: "PlayerPopupTableViewCell")
        menuTable.delegate = self
        menuTable.dataSource = self
    }
    
    func configurePlayerSettingMenu(menuItems: [String], menuType: MenuType) {
        self.menuItems = menuItems
        self.menuType = menuType
        self.titleLabel.text = menuType.rawValue
        DispatchQueue.main.async {
            self.menuTable.reloadData()
        }
    }    
    
}

extension PlayerSettingMenu: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerPopupTableViewCell") as! PlayerPopupTableViewCell
        cell.title.text = menuItems[indexPath.row]
        cell.subtitle.text = "subtitle"
        if indexPath.row == menuItems.count - 1 {
            cell.horizontalBaseLine.isHidden = true
        }
        if indexPath == priviousSelectedIndexpath{
            cell.rabioButtonImageView.image = UIImage(named: "radioButttonFilled")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedItem = menuItems[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! PlayerPopupTableViewCell
//        cell.rabioButtonImageView.image = UIImage(named: "radioButttonFilled")
        if priviousSelectedIndexpath != indexPath {
           cell.rabioButtonImageView.image = UIImage(named: "radioButttonFilled")
            let cell2 = tableView.cellForRow(at: priviousSelectedIndexpath) as! PlayerPopupTableViewCell
            cell2.rabioButtonImageView.image = UIImage(named: "radioButton")
        }
        priviousSelectedIndexpath = indexPath
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}


