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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedItem = menuItems[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}


