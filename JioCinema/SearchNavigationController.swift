//
//  SearchNavigationController.swift
//  JioCinema
//
//  Created by manas on 25/05/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class SearchNavigationController: UINavigationController {
    
    
    var jCSearchVC: JCSearchResultViewController? {
        let searchContainer = self.viewControllers.first as? UISearchContainerViewController
        let searchViewController = searchContainer?.searchController
        if let searchResultVC = searchViewController?.searchResultsController as? JCSearchResultViewController {
            return searchResultVC
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
       jCSearchVC?.viewIsAppearing()
        
    }
    override func viewWillDisappear(_ animated: Bool) {

    }
   
    override func viewDidDisappear(_ animated: Bool) {
        jCSearchVC?.viewDidDisappearedCalled()
    }

}
