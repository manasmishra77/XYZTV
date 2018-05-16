//
//  JCLoginVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 12/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCLoginVC: UIViewController {

    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var signInWithJioIdView: UIView!
    @IBOutlet weak var LoginOptionView: UIView!
    @IBOutlet weak var signInOptionsContainer: UIView!
    
    @IBOutlet weak var pleaseLoginMessageButton: UIButton!
    @IBOutlet weak var signInJioIDButton: JCButton!
    @IBOutlet weak var signInOTPButton: JCButton!
    
    var isLoginPresentedFromAddToWatchlist = false
    var isLoginPresentedFromPlayNowButtonOfMetaData = false
    var isLoginPresentedFromItemCell = false
    var presentingVCOfLoginVc: Any? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInOTPButton.layer.cornerRadius = 8
        signInJioIDButton.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
        otpView.isHidden = true
        signInWithJioIdView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    deinit {
        print("In LoginVC Deinit")
    }
    
    @IBAction func didClickOnOTPSignIn(_ sender: UIButton)
    {
        let otpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: otpVCStoryBoardId) as! JCOTPVC
        otpVC.isLoginPresentedFromAddToWatchlist = isLoginPresentedFromAddToWatchlist
        otpVC.isLoginPresentedFromItemCell = isLoginPresentedFromItemCell
        otpVC.isLoginPresentedFromPlayNowButtonOfMetaData = isLoginPresentedFromPlayNowButtonOfMetaData
        otpVC.presentingVCOfLoginVc = presentingVCOfLoginVc
        otpVC.modalPresentationStyle = .overFullScreen
        otpVC.modalTransitionStyle = .coverVertical
        self.present(otpVC, animated: true, completion: nil)
    }
    
    @IBAction func didClickOnJioIdSignIn(_ sender: Any) {
        let singInOptionsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: signInOptionsStoryBoardId) as! JCSignInOptionsVC
        singInOptionsVC.isLoginPresentedFromAddToWatchlist = isLoginPresentedFromAddToWatchlist
        singInOptionsVC.isLoginPresentedFromItemCell = isLoginPresentedFromItemCell
        singInOptionsVC.isLoginPresentedFromPlayNowButtonOfMetaData = isLoginPresentedFromPlayNowButtonOfMetaData
        
        singInOptionsVC.presentingVCOfLoginVc = presentingVCOfLoginVc
        singInOptionsVC.modalPresentationStyle = .overFullScreen
        singInOptionsVC.modalTransitionStyle = .coverVertical
        singInOptionsVC.view.layer.speed = 0.7

        self.present(singInOptionsVC, animated: true, completion: {
            //self.changingSearchNCRootVC()
        })
    }
 
    
    //MARK:- Sign in via jio id view implementation
    
    @IBOutlet weak var passwordTF: JCPasswordField!
    @IBOutlet weak var jioIdTF: JCTextField!
    @IBAction func didClickOnSignInButton(_ sender: Any) {
    }
    
    //MARK:- Sign in via otp option
    
    @IBAction func didClickOnGetOtpButton(_ sender: Any) {
    }
    
    @IBAction func didClickOnResendOtpButton(_ sender: Any) {
    }
    @IBAction func didClickOnSignInViaOtpButton(_ sender: Any) {
    }
    
    
    
}
