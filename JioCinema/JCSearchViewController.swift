//
//  SearchViewController.swift
//  JioCinema
//
//  Created by manas on 27/11/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSearchViewController: UISearchController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        print("123")
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == UIPressType.menu{
            if let searchVc = self.searchResultsController as? JCSearchVC{
                searchVc.pressesBegan(presses, with: event)
            }
        }
    }

}
