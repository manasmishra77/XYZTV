//
//  SideNavigationVC.swift
//  JioCinema
//
//  Created by Vinit Somani on 12/5/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class SideNavigationVC: UIViewController {

    @IBOutlet weak var HolderView: UIView!
    @IBOutlet weak var navigationTableHolder: UIView!
    @IBOutlet weak var sideNavigationWidthConstraint: NSLayoutConstraint!
    
    var sideNavigationView: SideNavigationTableView?
    var sideNavigationViewModel: SideNavigationViewModel?
    let sideViewExpandedWidth: CGFloat = 300
    let sideViewCollapsedWidth: CGFloat = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.addSideNavigation()
        sideNavigationViewModel = SideNavigationViewModel()
        self.didSelectRowInNavigationTable(controllerType: (sideNavigationViewModel?.getSelectedViewController())!.rawValue)
    }
    
    func addSideNavigation() {
        sideNavigationView = Utility.getXib("SideNavigationTableView", type: SideNavigationTableView.self, owner: self)
        sideNavigationView?.delegate = self
        sideNavigationView?.frame = navigationTableHolder.frame
        navigationTableHolder.addSubview(sideNavigationView!)
        sideNavigationWidthConstraint.constant = sideViewCollapsedWidth
    }

}

extension SideNavigationVC: SideNavigationTableProtocol {

    
    func sideNavigationSwipeEnd(side: UIFocusHeading) {
        var navigationWidth = sideViewExpandedWidth
        if side == .right {
            navigationWidth = sideViewCollapsedWidth
        }
        self.sideNavigationWidthConstraint.constant = CGFloat(navigationWidth)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func didSelectRowInNavigationTable(controllerType: String) {
        
        sideNavigationWidthConstraint.constant = sideViewCollapsedWidth
        var viewControllerObject: UIViewController?
        switch controllerType {
        case ViewControllersType.disneyHome.rawValue :
            viewControllerObject = sideNavigationViewModel?.disneHomeVC
        case ViewControllersType.home.rawValue :
            viewControllerObject = sideNavigationViewModel?.homeVC
        case ViewControllersType.movies.rawValue :
            viewControllerObject = sideNavigationViewModel?.moviesVC
        case ViewControllersType.clips.rawValue :
            viewControllerObject = sideNavigationViewModel?.clips
        case ViewControllersType.tv.rawValue :
            viewControllerObject = sideNavigationViewModel?.tvVC
        case ViewControllersType.search.rawValue :
            viewControllerObject = sideNavigationViewModel?.searchVC
        case ViewControllersType.settings.rawValue :
            viewControllerObject = sideNavigationViewModel?.settingsVC
        case ViewControllersType.music.rawValue :
            viewControllerObject = sideNavigationViewModel?.musicVC
        default: break
        }
        
        if let vc = viewControllerObject {
            self.addChildViewController(vc)
            self.HolderView.addSubview(vc.view)
        }
    }
}
