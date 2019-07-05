//
//  PlayerSettingMenu.swift
//  JioCinema
//
//  Created by Vinit Somani on 3/25/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

enum MenuType: String {
    case multiaudioLanguage = "Audio"
    case multiSubtitle = "Subtitle"
    case videobitratequality = "Video Quality"
}


class PlayerSettingMenu: UIView {
    @IBOutlet weak var menuTable: UITableView!
    var menuType: MenuType?
    var menuItems = [String]()
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var currentSelectedItem: String?
    var previousSelectedIndexpath: IndexPath?
    
    
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
    deinit {
        print("Player Settings menu deinit called")
    }
}

extension PlayerSettingMenu: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerPopupTableViewCell") as! PlayerPopupTableViewCell
        cell.title.text = menuItems[indexPath.row]
        cell.subtitle.text = ""
        if indexPath.row == menuItems.count - 1 {
            cell.horizontalBaseLine.isHidden = true
        }
        if previousSelectedIndexpath == nil {
            previousSelectedIndexpath = IndexPath(row: menuType == .multiSubtitle ? 1 : 0, section: 0)
            if menuType == .multiSubtitle && menuItems.count == 1 {
                previousSelectedIndexpath = IndexPath(row: 0, section: 0)
            }
        }

        if indexPath == previousSelectedIndexpath{
            cell.rabioButtonImageView.image = UIImage(named: "radioButttonFilled")?.withRenderingMode(.alwaysTemplate)
            cell.title.font = UIFont(name: "JioType-Medium", size: 36)
            cell.title.textColor = .white
            cell.rabioButtonImageView.tintColor = ThemeManager.shared.selectionColor
            cell.isSelectedCell = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedItem = menuItems[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! PlayerPopupTableViewCell
        if previousSelectedIndexpath != indexPath {
           cell.rabioButtonImageView.image = UIImage(named: "radioButttonFilled")?.withRenderingMode(.alwaysTemplate)
            cell.rabioButtonImageView.tintColor = .white
            cell.isSelectedCell = true
            let cell2 = tableView.cellForRow(at: previousSelectedIndexpath ?? IndexPath(row: 0, section: 0)) as! PlayerPopupTableViewCell
            cell2.rabioButtonImageView.image = UIImage(named: "radioButton")
            cell2.title.font = UIFont(name: "JioType-Light", size: 36)
            cell2.title.textColor = #colorLiteral(red: 0.6500751972, green: 0.650090754, blue: 0.6500824094, alpha: 1)
            cell2.isSelectedCell = false
        }
        previousSelectedIndexpath = indexPath
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}


