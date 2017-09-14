//
//  JCLoginVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 12/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCLoginVC: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var signInOptionsContainer: UIView!
    
    @IBOutlet weak var pleaseLoginMessageButton: UIButton!
    @IBOutlet weak var signInJioIDButton: JCButton!
    @IBOutlet weak var signInOTPButton: JCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = #imageLiteral(resourceName: "loginBg.jpg")
        signInOTPButton.layer.cornerRadius = 8
        signInJioIDButton.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didClickOnOTPSignIn(_ sender: UIButton)
    {
        let otpVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: otpVCStoryBoardId) as! JCOTPVC
        /*
        let searchController = UISearchController(searchResultsController: otpVC)
        
        searchController.searchResultsUpdater = otpVC as? UISearchResultsUpdating
        
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.placeholder = "Enter Jio Number"
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.barTintColor = UIColor.black
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.keyboardType = .numberPad
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        otpVC.containerView.addSubview(searchController.searchBar)
        
        otpVC.searchController = searchController
        searchController.searchBar.sizeToFit()
        let searchContainerViewController = UISearchContainerViewController(searchController: searchController)
        searchContainerViewController.modalPresentationStyle = .overFullScreen
        searchContainerViewController.modalTransitionStyle = .coverVertical
        
        //self.present(searchContainerViewController, animated: true, completion: nil)
        */
        self.present(otpVC, animated: true, completion: nil)
    }
    
    
    
    @IBAction func didClickOnJioIdSignIn(_ sender: Any)
    {
        let singInOptionsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: signInOptionsStoryBoardId)
        singInOptionsVC.modalPresentationStyle = .overFullScreen
        singInOptionsVC.modalTransitionStyle = .coverVertical
        singInOptionsVC.view.layer.speed = 0.7

        self.present(singInOptionsVC, animated: true, completion: nil)
    }
 
}
