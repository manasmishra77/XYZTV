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

    var selectedVC: UIViewController?

    static let shared = SideNavigationVC()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addSideNavigation()
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(SideNavigationVC.menuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        self.view.addGestureRecognizer(menuPressRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSerchNavRemoving(_:)), name: AppNotification.serchViewUnloading, object: nil)
        if #available(tvOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onFocusFailed(_:)), name: NSNotification.Name(rawValue: UIFocusSystem.movementDidFailNotification.rawValue), object: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func onSerchNavRemoving(_ notification:Notification) {
        self.presentedViewController?.dismiss(animated: true, completion: {
            if let index = self.sideNavigationView?.selectedIndex {
                self.sideNavigationView?.performNavigationTableSelection(index: index)
            }
        })
    }
    
    @objc func onFocusFailed(_ notification:Notification) {
        if let contextDict = notification.userInfo as? [String: UIFocusUpdateContext], let context = contextDict["UIFocusUpdateContextKey"] {
            print(context)
            
            if context.previouslyFocusedItem is SideNavigationTableCell && selectedVC != nil {
                if (context.focusHeading == .right) {
                    
                    
                    DispatchQueue.main.async {                        
                        self.sideNavigationWidthConstraint.constant = SideNavigationConstants.collapsedWidth
                        self.myPreferdFocusedView = nil
                        
                        if let nextFocusItem = (self.selectedVC as? BaseViewController)?.lastFocusableItem {
                            self.myPreferdFocusedView = nextFocusItem
                        }
                        else {
                            self.myPreferdFocusedView = self.selectedVC?.view
                        }

                        self.updateFocusIfNeeded()
                        self.setNeedsFocusUpdate()
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func addSideNavigation() {
        sideNavigationView = Utility.getXib("SideNavigationTableView", type: SideNavigationTableView.self, owner: self)
        sideNavigationView?.delegate = self
        sideNavigationView?.frame = navigationTableHolder.frame
        navigationTableHolder.addSubview(sideNavigationView!)
        sideNavigationWidthConstraint.constant = SideNavigationConstants.collapsedWidth
        self.sideNavigationView?.setMenuListItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navView = sideNavigationView {
            didSelectRowInNavigationTable(menuItem: navView.itemsList[navView.selectedIndex])
        }
    }
   
    @objc func menuButtonAction(recognizer:UITapGestureRecognizer) {
        if (self.sideNavigationWidthConstraint.constant == SideNavigationConstants.collapsedWidth) {
            self.sideNavigationSwipeEnd(side: .left)
        }
        else {
            let app = UIApplication.shared
            app.perform(#selector(NSXPCConnection.suspend))
        }
    }


    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferedView = myPreferdFocusedView {
            return [preferedView]
        }
        return []
    }
    
    private func getSearchController() -> SearchNavigationController{
        let searchViewController = Utility.sharedInstance.prepareSearchViewController(searchText: "")
        let searchContainerController = UISearchContainerViewController.init(searchController: searchViewController)
        searchContainerController.view.backgroundColor = UIColor.black
        return SearchNavigationController(rootViewController: searchContainerController)
    }
    
}

extension SideNavigationVC: SideNavigationTableProtocol {
    func sideNavigationSwipeEnd(side: UIFocusHeading) {
        var navigationWidth = SideNavigationConstants.expandedWidth
        if side == .right {
            navigationWidth = SideNavigationConstants.collapsedWidth
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
        sideNavigationWidthConstraint.constant = SideNavigationConstants.collapsedWidth
        if let vc = menuItem.viewControllerObject {
            
            if menuItem.type == .search {
                (vc as? SearchNavigationController)?.jCSearchVC?.searchResultForkey(with: "")
                self.navigationController?.present(vc, animated: false, completion: {
                    
                })
            }
            else {
                //                if let uiView = self.HolderView.subviews.first {
                selectedVC?.willMove(toParent: nil)
                selectedVC?.view.removeFromSuperview()
                selectedVC?.removeFromParent()
                //                    content.willMove(toParentViewController: nil)
                //                    content.view.removeFromSuperview()
                //                    content.removeFromParentViewController()
                //                    uiView.removeFromSuperview()
                //                }
                self.addChild(vc)
                self.HolderView.addSubview(vc.view)
                vc.didMove(toParent: self)
                selectedVC = vc
                
                DispatchQueue.main.async {
                    self.myPreferdFocusedView = nil
                    self.myPreferdFocusedView = self.HolderView
                    self.updateFocusIfNeeded()
                    self.setNeedsFocusUpdate()
                }
                
            }
        } else {
            if menuItem.type == .search {
                self.navigationController?.present(self.getSearchController(), animated: true, completion: nil)
            }
        }
    }
}
