//
//  SideNavigationTableView.swift
//  JioCinema
//
//  Created by Vinit Somani on 12/5/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol SideNavigationTableProtocol {
    func sideNavigationSwipeEnd(side: UIFocusHeading)
    func didSelectRowInNavigationTable(controllerType: String)
}

enum ViewControllersType: String, CaseIterable {
    case home
    case movies
    case tv
    case music
    case clips
    case search
    case disneyHome
    case settings
}


class SideNavigationTableView: UIView {
    
    @IBOutlet weak var navigationTable: UITableView!
    
    var delegate: SideNavigationTableProtocol?
    var controllersType: ViewControllersType?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        navigationTable.register(UINib(nibName: "SideNavigationTableCell", bundle: nil), forCellReuseIdentifier: "SideNavigationTableCell")
        navigationTable.delegate = self
        navigationTable.dataSource = self
        self.navigationTable.remembersLastFocusedIndexPath = true
    }

}




extension SideNavigationTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectRowInNavigationTable(controllerType: ViewControllersType.allCases[indexPath.row].rawValue)
        let cell = tableView.cellForRow(at: indexPath) as! SideNavigationTableCell
        cell.selectionIndicatorView.backgroundColor = .blue
        cell.iconLabel.backgroundColor = .white
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SideNavigationTableCell
        cell.selectionIndicatorView.backgroundColor = .clear
    }
    
}

extension SideNavigationTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewControllersType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideNavigationTableCell", for: indexPath) as! SideNavigationTableCell
        cell.titleLabel.text = ViewControllersType.allCases[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.focusHeading == .left ||  context.focusHeading == .right{
            delegate?.sideNavigationSwipeEnd(side: context.focusHeading)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        if context.nextFocusedIndexPath == nil && (context.focusHeading == .down || context.focusHeading == .up ) {
         return false
        }
        return true
    }
    
    
    
}

