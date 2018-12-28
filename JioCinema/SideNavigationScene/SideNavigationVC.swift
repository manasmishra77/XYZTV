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
    let sideViewExpandedWidth: CGFloat = 300
    let sideViewCollapsedWidth: CGFloat = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addSideNavigation()
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(SideNavigationVC.menuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
        self.view.addGestureRecognizer(menuPressRecognizer)
    }
    
    func addSideNavigation() {
        sideNavigationView = Utility.getXib("SideNavigationTableView", type: SideNavigationTableView.self, owner: self)
        sideNavigationView?.delegate = self
        sideNavigationView?.frame = navigationTableHolder.frame
        navigationTableHolder.addSubview(sideNavigationView!)
        sideNavigationWidthConstraint.constant = sideViewCollapsedWidth
//        sideNavigationView?.performNavigationTableSelection(index: 1)
        sideNavigationView?.navigationTable.selectRow (at: IndexPath.init(item: 1, section: 0), animated: true, scrollPosition: .none)
        
        
        
    }
   
    @objc func menuButtonAction(recognizer:UITapGestureRecognizer) {
        
        if (self.sideNavigationWidthConstraint.constant == self.sideViewCollapsedWidth) {
            self.sideNavigationSwipeEnd(side: .left)
        }
        else {

        }
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
    
    func didSelectRowInNavigationTable(menuItem: MenuItem) {
        if let uiView = self.HolderView.subviews.first {
            uiView.removeFromSuperview()
        }
        sideNavigationWidthConstraint.constant = sideViewCollapsedWidth
        if let vc = menuItem.viewControllerObject {
            self.addChildViewController(vc)
            self.HolderView.addSubview(vc.view)
        }
    }
}
