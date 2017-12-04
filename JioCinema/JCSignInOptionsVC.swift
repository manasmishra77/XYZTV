//
//  JCSignInOptionsVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 13/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSignInOptionsVC: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var passwordTextField: JCPasswordField!
    @IBOutlet weak var jioIdTextField: JCTextField!
    @IBOutlet weak var signInButton: JCButton!
    
    var isLoginPresentedFromAddToWatchlist = false
    var isLoginPresentedFromPlayNowButtonOfMetaData = false
    var isLoginPresentedFromItemCell = false
    var presentingVCOfLoginVc: Any = false
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        backgroundImageView.image = #imageLiteral(resourceName: "loginBg.jpg")
        signInButton.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        //self.changingSearchNCRootVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickOnJioIDSignInButton(_ sender: Any)
    {
        jioIdTextField.text     = "pallavtrivedi-4"
        passwordTextField.text  = "pallav@1010"
        //     jioIdTextField.text     = "poonam2016"
        //     passwordTextField.text  = "poonam@12"
        
        if(jioIdTextField.text?.count == 0 || passwordTextField.text?.count == 0)
        {
            self.showAlert(alertString: "Jio ID/Password cannot be empty")
        }
        else
        {
            let params:[String:String]? = ["os": "Android","username":jioIdTextField.text!,"password":passwordTextField.text!,"deviceId":"12345"]
            let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: loginUrl, params: params!, encoding: .BODY)
            weak var weakSelf = self
            
            RJILApiManager.defaultManager.post(request: loginRequest)
            {
                (data, response, error) in
                if let responseError = error
                {
                    print(responseError)
                    //Analytics for Login Fail
                    self.sendLoggedInAnalyticsEventWithFailure(errorMessage: (error?.localizedDescription)!)
                    return
                }
                
                if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
                {
                    let code = parsedResponse["code"] as? Int
                    if(code == 200)
                    {
                        weakSelf?.setUserData(userData: parsedResponse)
                        JCLoginManager.sharedInstance.setUserToDefaults()
                        let vc = weakSelf?.presentingVCOfLoginVc
                        let presentedFromAddToWatchList = weakSelf?.isLoginPresentedFromAddToWatchlist
                        let presentedFromPlayNowButtonOfMetadata = weakSelf?.isLoginPresentedFromPlayNowButtonOfMetaData
                        let loginPresentedFromItemCell = weakSelf?.isLoginPresentedFromItemCell
                        
                        //Updates after login
                        if let navVc = weakSelf?.presentingViewController?.presentingViewController as? UINavigationController, let tabVc = navVc.viewControllers[0] as? UITabBarController{
                            if let homevc = tabVc.viewControllers![0] as? JCHomeVC{
                                homevc.callWebServiceForResumeWatchData()
                                homevc.callWebServiceForUserRecommendationList()
                            }
                            if let movieVC = tabVc.viewControllers![1] as? JCMoviesVC{
                                movieVC.callWebServiceForMoviesWatchlist()
                            }
                            if let tvVc = tabVc.viewControllers![2] as? JCTVVC{
                                tvVc.callWebServiceForTVWatchlist()
                            }
                        }
                        
                        DispatchQueue.main.async {
                            weakSelf?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                                if loginPresentedFromItemCell!{
                                    if let vc = vc as? JCHomeVC {
                                        vc.playItemAfterLogin()
                                    }
                                    else if (vc as? JCMoviesVC) != nil {
                                        //vc.playItemAfterLogin()
                                    }
                                    else if (vc as? JCTVVC) != nil {
                                        //vc.playItemAfterLogin()
                                    }
                                    else if let vc = vc as? JCMusicVC {
                                        vc.playItemAfterLogin()
                                    }
                                    else if let vc = vc as? JCClipsVC {
                                        vc.playItemAfterLogin()
                                    }
                                    else if let vc = vc as? JCSearchVC {
                                        vc.playItemAfterLogin()
                                    }
                                    else if let vc = vc as? JCMetadataVC {
                                        vc.playItemAfterLogin()
                                    }
                                    else if let vc = vc as? JCLanguageGenreVC {
                                        vc.playItemAfterLogin()
                                    }
                                }
                                if presentedFromAddToWatchList!{
                                    if let vc = vc as? JCMetadataVC{
                                        //Change Add to watchlist button status
                                        
                                    }
                                }
                                if presentedFromPlayNowButtonOfMetadata!{
                                    if let vc = vc as? JCMetadataVC{
                                        //Play after login
                                        vc.didClickOnWatchNowButton(nil)
                                    }
                                }
                            })
                        }
                        self.sendLoggedInAnalyticsEventWithSuccess()
                        
                        
                    }
                    else if(code == 400)
                    {
                        self.showAlert(alertString: parsedResponse["message"]! as! String)
                        self.sendLoggedInAnalyticsEventWithFailure(errorMessage: parsedResponse["message"]! as! String)
                    }
                    else{
                        self.sendLoggedInAnalyticsEventWithFailure(errorMessage: parsedResponse["message"]! as! String)
                    }
                }
            }
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
        if(textField.isEqual(jioIdTextField))
        {
            //textField.frame.size = passwordTextField.frame.size
            if(textField.text?.characters.count == 0)
            {
                self.showAlert(alertString: "JioID can't be empty")
                //                let animation = CABasicAnimation(keyPath: "position")
                //                animation.duration = 0.07
                //                animation.repeatCount = 4
                //                animation.autoreverses = true
                //                animation.fromValue = NSValue.init(cgPoint: CGPoint(x: textField.center.x-10, y: textField.center.y))
                //                animation.toValue = NSValue.init(cgPoint: CGPoint(x: textField.center.x+10, y: textField.center.y))
                //                textField.layer.add(animation, forKey: "position")
            }
        }
        
        if(textField.isEqual(passwordTextField))
        {
            //textField.frame.size.width = passwordTextField.frame.size
            if(textField.text?.characters.count == 0)
            {
                self.showAlert(alertString: "Password can't be empty")
            }
        }
    }
    
    
    func setUserData(userData: [String:Any])
    {
        let result = userData["result"] as? [String:Any]
        
        JCAppUser.shared.lbCookie = result?["lbCookie"] as! String
        JCAppUser.shared.ssoLevel = ""
        JCAppUser.shared.ssoToken = result?["ssoToken"] as! String
        JCAppUser.shared.commonName = result?["displayName"] as! String
        JCAppUser.shared.preferredLocale = ""
        JCAppUser.shared.subscriberId = result?["subscriberId"] as! String
        JCAppUser.shared.mail = result?["mail"] as! String
        JCAppUser.shared.profileId = result?["profileId"] as! String
        JCAppUser.shared.uid = result?["uId"] as! String
        JCAppUser.shared.unique = result?["uniqueId"] as! String
        JCAppUser.shared.userGroup = userData["userGrp"] as! String
    }
    
    func navigateToHomeVC()
    {
        DispatchQueue.main.async {
            let tabBarController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: tabBarStoryBoardId)
            let navController = UINavigationController.init(rootViewController: tabBarController)
            navController.navigationBar.isHidden = true
            self.view.window?.rootViewController = navController
        }
    }
    //Removing seasarch container from search navigation controller
    func changingSearchNCRootVC(){
        if JCAppReference.shared.isTempVCRootVCInSearchNC!{
            JCAppReference.shared.isTempVCRootVCInSearchNC = false
            if let vc = presentingVCOfLoginVc as? JCSearchVC {
                let searchVC = Utility.sharedInstance.prepareSearchViewController(searchText: "", jcSearchVc: vc)
                let searchContainerController = UISearchContainerViewController(searchController: searchVC)
                searchContainerController.view.backgroundColor = UIColor.black
                if let navVcForSearchContainer = JCAppReference.shared.tabBarCotroller?.viewControllers![5] as? UINavigationController{
                    navVcForSearchContainer.setViewControllers([searchContainerController], animated: false)
                }
            }
        }
    }
    
    fileprivate func showAlert(alertString:String)
    {
        let alert = UIAlertController(title: "Alert",
                                      message: alertString,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Send Logged In Analytics Event With Success
    func sendLoggedInAnalyticsEventWithSuccess() {
        
        // For Clever Tap Event
        let eventProperties = ["Source":"Jio ID","Platform":"TVOS","Userid":Utility.sharedInstance.encodeStringWithBase64(aString: JCAppUser.shared.uid)]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Logged In", properties: eventProperties)
        
        // For Internal Analytics Event
        let loginSuccessInternalEvent = JCAnalyticsEvent.sharedInstance.getLoggedInEventForInternalAnalytics(methodOfLogin: "JIOID", source: "Manual", jioIdValue: Utility.sharedInstance.encodeStringWithBase64(aString: JCAppUser.shared.uid))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: loginSuccessInternalEvent)
        
    }
    
    //MARK:- Send Logged In Analytics Event With Failure
    func sendLoggedInAnalyticsEventWithFailure(errorMessage:String) {
        
        // For Clever Tap Event
        let eventProperties = ["Userid":Utility.sharedInstance.encodeStringWithBase64(aString: self.jioIdTextField.text!),"Reason":"Jio ID","Platform":"TVOS","Error Code":"400","Message":errorMessage]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Login Failed", properties: eventProperties)
        
        // For Internal Analytics Event
        let loginFailedInternalEvent = JCAnalyticsEvent.sharedInstance.getLoginFailedEventForInternalAnalytics(jioID: self.jioIdTextField.text!, errorMessage: errorMessage)
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: loginFailedInternalEvent)
        
        
    }
    
    
    
    
}

