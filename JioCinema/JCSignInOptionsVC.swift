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
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        backgroundImageView.image = #imageLiteral(resourceName: "loginBg.jpg")
        signInButton.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickOnJioIDSignInButton(_ sender: Any)
    {
       // jioIdTextField.text     = "pallavtrivedi-4"
       // passwordTextField.text  = "pallav@1010"
        
        if(jioIdTextField.text?.characters.count == 0 || passwordTextField.text?.characters.count == 0)
        {
            self.showAlert(alertString: "Jio ID/Password cannot be empty")
        }
        else
        {
            let params:[String:String]? = ["os":"Android","username":jioIdTextField.text!,"password":passwordTextField.text!,"deviceId":"12345"]
            let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: loginUrl, params: params!, encoding: .BODY)
            weak var weakSelf = self
            
            RJILApiManager.defaultManager.post(request: loginRequest)
            {
                (data, response, error) in
                if let responseError = error
                {
                    print(responseError)
                    //Analytics for Login Fail
                    return
                }
                
                if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
                {
                    let code = parsedResponse["code"] as? Int
                    if(code == 200)
                    {
                        weakSelf?.setUserData(userData: parsedResponse)
                        JCLoginManager.sharedInstance.setUserToDefaults()
                        
                        //Analytics for Login Success   (jio id, Manual)
//                        let analyticsData = ["method":"JIOID","source":"manual","identity":JCAppUser.shared.uid]
//                        JIOMediaAnalytics.sharedInstance().recordEvent(withEventName: "logged_in", andEventProperties: analyticsData)
                        
                        DispatchQueue.main.async {
                            weakSelf?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                                
                                if !isLoginPresentedFromAddToWatchlist
                                {
                                NotificationCenter.default.post(name: readyToPlayNotificationName, object: nil)
                                }
                                isLoginPresentedFromAddToWatchlist = false
                            })
                        }
                        
                    }
                    else if(code == 400)
                    {
                        self.showAlert(alertString: parsedResponse["message"]! as! String)
                        //Analytics for Login Fail
//                        let pro = ["userid":]
//                        let analyticsData = ["method":"4G","source":"skip","identity":JCAppUser.shared.commonName]
//                        JIOMediaAnalytics.sharedInstance().recordEvent(withEventName: "logged_in", andEventProperties: analyticsData)
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

}
