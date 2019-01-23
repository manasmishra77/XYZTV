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
    
    var myPreferdFocusedView : UIView?
    var sideNavigationView: SideNavigationTableView?
    let sideViewExpandedWidth: CGFloat = 368
    let sideViewCollapsedWidth: CGFloat = 108
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addSideNavigation()
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(SideNavigationVC.menuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
        self.view.addGestureRecognizer(menuPressRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSerchNavRemoving(_:)), name: AppNotification.serchViewUnloading, object: nil)
    }
    
    @objc func onSerchNavRemoving(_ notification:Notification) {
        self.presentedViewController?.dismiss(animated: true, completion: {
            self.sideNavigationView?.performNavigationTableSelection(index: (self.sideNavigationView?.selectedIndex)!)
        })
    }
    
    func addSideNavigation() {
        sideNavigationView = Utility.getXib("SideNavigationTableView", type: SideNavigationTableView.self, owner: self)
        sideNavigationView?.delegate = self
        sideNavigationView?.frame = navigationTableHolder.frame
        navigationTableHolder.addSubview(sideNavigationView!)
        sideNavigationWidthConstraint.constant = sideViewCollapsedWidth
        self.sideNavigationView?.setMenuListItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
   
    @objc func menuButtonAction(recognizer:UITapGestureRecognizer) {
        if (self.sideNavigationWidthConstraint.constant == self.sideViewCollapsedWidth) {
            self.sideNavigationSwipeEnd(side: .left)
        }
        else {
            exit(0)
        }
    }
    
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        if(presses.first?.type == UIPressType.menu) {
//            if (self.sideNavigationWidthConstraint.constant == self.sideViewCollapsedWidth) {
//                self.sideNavigationSwipeEnd(side: .left)
//                return
//            }
//        }
//            super.pressesBegan(presses, with: event)
//    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferedView = myPreferdFocusedView {
            return [preferedView]
        }
        return []
    }
    
}

extension SideNavigationVC: SideNavigationTableProtocol {

    
    func sideNavigationSwipeEnd(side: UIFocusHeading) {
        var navigationWidth = sideViewExpandedWidth
        if side == .right {
            navigationWidth = sideViewCollapsedWidth
        }
        else {
            myPreferdFocusedView = self.sideNavigationView?.navigationTable
            self.updateFocusIfNeeded()
            self.setNeedsFocusUpdate()
        }
        self.sideNavigationWidthConstraint.constant = CGFloat(navigationWidth)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (animationDone) in

        })
        
        
    }
    
    func didSelectRowInNavigationTable(menuItem: MenuItem) {
        

        sideNavigationWidthConstraint.constant = sideViewCollapsedWidth
        if let vc = menuItem.viewControllerObject {
            
            if menuItem.type == .search {
                (vc as? SearchNavigationController)?.jCSearchVC?.searchResultForkey(with: "")
                self.navigationController?.present(vc, animated: false, completion: {
                    
                })
            }
            else {
                if let uiView = self.HolderView.subviews.first {
                    uiView.removeFromSuperview()
                }
            self.addChildViewController(vc)
            self.HolderView.addSubview(vc.view)
                
                DispatchQueue.main.async {
                    self.myPreferdFocusedView = nil
                    self.myPreferdFocusedView = self.HolderView
                    self.updateFocusIfNeeded()
                    self.setNeedsFocusUpdate()
                }

            }
        }
    }
}
