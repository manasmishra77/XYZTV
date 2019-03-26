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
    
    
    
    override func awakeFromNib() {
        menuTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = menuItems[indexPath.row]
//        cell?.textLabel!.font.pointSize = 50
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}


