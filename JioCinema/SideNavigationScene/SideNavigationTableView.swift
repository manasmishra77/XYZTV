//
//  SideNavigationTableView.swift
//  JioCinema
//
//  Created by Vinit Somani on 12/5/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol SideNavigationTableProtocol: AnyObject {
    func sideNavigationSwipeEnd(side: UIFocusHeading)
    func didSelectRowInNavigationTable(menuItem: MenuItem)
}

enum ViewControllersType: String {
    case home
    case movies
    case tv
    case music
    case clips
    case search
    case disneyHome
    case settings
    
    
    var name: String {
        switch self {
        case .disneyHome:
            return "Disney-Jio"
        case .tv:
            return "TV Shows"
        default:
            return self.rawValue.capitalized
        }
    }
}

struct MenuItem {
    var image: UIImage!
    var type : ViewControllersType!
    var index : Int!
    var viewControllerObject: UIViewController?
    
    init(type:ViewControllersType, index: Int) {
        self.index = index
        self.type = type
        switch type {
        case .home:
            self.image =  UIImage.init(named: "Home")
            self.viewControllerObject = BaseViewController(.home)
        case .clips:
            self.image = UIImage.init(named: "Clips")
            self.viewControllerObject = BaseViewController(.clip)
        case .movies:
            self.image = UIImage.init(named: "Movies")
            self.viewControllerObject = BaseViewController(.movie)
        case .tv:
            self.image = UIImage.init(named: "Tvshow")
            self.viewControllerObject = BaseViewController(.tv)
        case .search:
            self.image = UIImage.init(named: "Search")
            self.viewControllerObject = self.getSearchController()
        case .settings:
            self.image = UIImage.init(named: "SettingsIcon")
            self.viewControllerObject = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: settingsVCStoryBoardId) as? JCSettingsVC
        case .music:
            self.image = UIImage.init(named: "Music")
            self.viewControllerObject = BaseViewController(.music)
        case .disneyHome:
            self.image = UIImage.init(named: "Disney")
            self.viewControllerObject = BaseViewController(.disneyHome)
        }
      
    }

    private func getSearchController() -> SearchNavigationController{
        let searchViewController = Utility.sharedInstance.prepareSearchViewController(searchText: "")
        let searchContainerController = UISearchContainerViewController.init(searchController: searchViewController)
        searchContainerController.view.backgroundColor = UIColor.black
        return SearchNavigationController(rootViewController: searchContainerController)
    }
    
}


class SideNavigationTableView: UIView {
    
    @IBOutlet weak var navigationTable: UITableView!
    
    weak var delegate: SideNavigationTableProtocol?
    var controllersType: ViewControllersType?

    var itemsList = [MenuItem]()
    
    var selectedIndex = -1
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
//        self.setMenuListItem()
    }
    
    func setMenuListItem() {
        self.itemsList.append(MenuItem.init(type: .search, index: 0))
        self.itemsList.append(MenuItem.init(type: .home, index: 1))
        self.itemsList.append(MenuItem.init(type: .movies, index: 2))
        self.itemsList.append(MenuItem.init(type: .tv, index: 3))
        self.itemsList.append(MenuItem.init(type: .disneyHome, index: 4))
        self.itemsList.append(MenuItem.init(type: .music, index: 5))
        self.itemsList.append(MenuItem.init(type: .clips, index: 6))
        self.itemsList.append(MenuItem.init(type: .settings, index: 7))
        self.navigationTable.reloadData()
        selectedIndex = 1
        performNavigationTableSelection(index: 1)
    }
    
    func performNavigationTableSelection(index: Int) {
        if itemsList[index].type == ViewControllersType.search {
            
        }
        else {
            if let cell = self.navigationTable.cellForRow(at: IndexPath.init(item: selectedIndex, section: 0)) {
                (cell as? SideNavigationTableCell)?.selectionIndicatorView.backgroundColor = .clear
            }
            
            selectedIndex = index
            let cell = self.navigationTable.cellForRow(at: IndexPath.init(item: index, section: 0)) as! SideNavigationTableCell
            if itemsList[index].type == ViewControllersType.disneyHome {
                    cell.selectionIndicatorView.backgroundColor = ViewColor.selectionBarOnLeftNavigationColorForDisney
                    cell.backgroundColor = .black
                    self.navigationTable.backgroundColor = ViewColor.disneyLeftMenuBackground
            }
            else {
                    cell.selectionIndicatorView.backgroundColor = ViewColor.selectionBarOnLeftNavigationColor
                    self.navigationTable.backgroundColor = ViewColor.cinemaLeftMenuBackground
            }
        }
        delegate?.didSelectRowInNavigationTable(menuItem: self.itemsList[index])
    }
}




extension SideNavigationTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performNavigationTableSelection(index: indexPath.row)
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! SideNavigationTableCell
//        cell.selectionIndicatorView.backgroundColor = .clear
//    }
    
}

extension SideNavigationTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideNavigationTableCell", for: indexPath) as! SideNavigationTableCell
        cell.titleLabel.text = self.itemsList[indexPath.row].type.name
        cell.iconImageView.image = self.itemsList[indexPath.row].image
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
