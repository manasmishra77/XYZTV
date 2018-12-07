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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.addSideNavigation()
        sideNavigationViewModel = SideNavigationViewModel()
    }
    
    func addSideNavigation() {
        sideNavigationView = Utility.getXib("SideNavigationTableView", type: SideNavigationTableView.self, owner: self)
        sideNavigationView?.delegate = self
        sideNavigationView?.frame = navigationTableHolder.frame
        navigationTableHolder.addSubview(sideNavigationView!)
        sideNavigationWidthConstraint.constant = 120
    }

}

extension SideNavigationVC: SideNavigationTableProtocol {

    
    func sideNavigationSwipeEnd(side: UIFocusHeading) {
        if side == .left {
            sideNavigationWidthConstraint.constant = 350
        }
        else if side == .right {
            sideNavigationWidthConstraint.constant = 120
        }
    }
    
    func didSelectRowInNavigationTable(controllerType: String) {
        
        sideNavigationWidthConstraint.constant = 120
        switch controllerType {
        case ViewControllersType.Disney.rawValue :
            let myViewController = sideNavigationViewModel?.disneHomeVC
            self.addChildViewController(myViewController!)
            self.HolderView.addSubview(myViewController!.view)
        default:
            let myViewController = sideNavigationViewModel?.settingsVC
            self.addChildViewController(myViewController!)
            self.HolderView.addSubview(myViewController!.view)
        }

    }
}
