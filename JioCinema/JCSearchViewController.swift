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
        
        //Stting background gray image
        let imageView = UIImageView(image: UIImage(named: "MetaDatBackGroundImage"))
        imageView.frame = self.view.frame
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
       // print("123")
        
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        //Sending event to the searchvc when menu button preesed
        if presses.first?.type == UIPressType.menu {
            if let searchVc = self.searchResultsController as? JCSearchResultViewController {
                searchVc.pressesBegan(presses, with: event)
            }
        }
    }

}
