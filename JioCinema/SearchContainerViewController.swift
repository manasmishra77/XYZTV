//
//  SearchContainerViewController.swift
//  JioCinema
//
//  Created by manas on 04/10/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
var fromSearchVC = false

class SearchContainerViewController: UIViewController {
    
    var present = true

    var vc: UISearchController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        if !present{
            present = true
            return
        }
        present = false
         let searchVC = JCSearchVC.init(nibName: "JCBaseVC", bundle: nil)
         searchVC.view.backgroundColor = .black
         
         
         let searchViewController = UISearchController.init(searchResultsController: searchVC)
         searchViewController.view.backgroundColor = .black
         searchViewController.searchBar.placeholder = "Search"
         searchViewController.searchBar.tintColor = UIColor.white
         searchViewController.searchBar.barTintColor = UIColor.black
         searchViewController.searchBar.tintColor = UIColor.gray
         searchViewController.hidesNavigationBarDuringPresentation = true
         searchViewController.obscuresBackgroundDuringPresentation = false
         searchViewController.searchBar.delegate = searchVC
         searchViewController.searchBar.searchBarStyle = .minimal
         searchVC.searchViewController = searchViewController
         let searchContainerController = UISearchContainerViewController.init(searchController: searchViewController)
         searchContainerController.view.backgroundColor = UIColor.black
         searchContainerController.tabBarItem = UITabBarItem.init(title: "Search", image: nil, tag: 5)
         searchContainerController.view.backgroundColor = .blue
        self.vc = searchViewController
        fromSearchVC = true
        self.present(searchViewController, animated: true, completion: nil)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
