//
//  OTPVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 17/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCOTPVC: UIViewController
{
    
    @IBOutlet weak var resendOTPButton: JCButton!
    @IBOutlet weak var signInButton: JCButton!
    @IBOutlet weak var getOTPButton: JCButton!
   var searchController:UISearchController? = nil
    var enteredNumber:String? = nil
    let containerView = UIView.init(frame: CGRect.init(x: 200, y: 200, width: 600, height: 400))
     
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getOTPButton.layer.cornerRadius = 8
        signInButton.layer.cornerRadius = 8
        resendOTPButton.layer.cornerRadius = 8
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]
    {
        return [getOTPButton]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickOnSignInButton(_ sender: Any)
    {
        let enteredOTP = searchController?.searchBar.text!
        if(enteredOTP?.characters.count == 0)
        {
            self.showAlert(alertString: "Please Enter OTP")
        }
        else
        {
            self.callWebServiceToVerifyOTP(otp: enteredOTP!)
            searchController?.searchBar.text = ""
            searchController?.searchBar.placeholder = "Enter OTP"
        }
    }
    
    @IBAction func didClickOnResendOTPButton(_ sender: Any)
    {
        
    }
    
    @IBAction func didClickOnGetOTPButton(_ sender: Any)
    {
        let enteredNumber = searchController?.searchBar.text!
        if(enteredNumber?.characters.count == 0)
        {
            self.showAlert(alertString: "Please Enter Jio Number")
        }
        else
        {
            self.callWebServiceToGetOTP(number: enteredNumber!)
            searchController?.searchBar.text = ""
            searchController?.searchBar.placeholder = "Enter OTP"
            searchController?.searchBar.isSecureTextEntry = true
            getOTPButton.isHidden = true
            resendOTPButton.isHidden = false
            signInButton.isHidden = false
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
    
    
    fileprivate func callWebServiceToGetOTP(number:String)
    {
        enteredNumber = "+91".appending(number)
        let params = [identifierKey:enteredNumber,otpIdentifierKey:enteredNumber,actionKey:actionValue]
        
        let otpRequest = RJILApiManager.defaultManager.prepareRequest(path: getOTPUrl, params: params as Any as? Dictionary<String, Any>, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: otpRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                print(responseData)
                return
            }
        }
    }
    
    fileprivate func callWebServiceToVerifyOTP(otp:String)
    {
        let params = [identifierKey:enteredNumber,otpKey:otp,upgradeAuthKey:upgradAuthValue,returnSessionDetailsKey:returnSessionDetailsValue]
        
        let otpVerficationRequest = RJILApiManager.defaultManager.prepareRequest(path: verifyOTPUrl, params: params as Any as? Dictionary<String, Any>, encoding: .JSON)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: otpVerficationRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
               
                    weakSelf?.callWebServiceToLoginViaSubId(info: parsedResponse )
               
            }
        }
    }
    
    
    fileprivate func callWebServiceToLoginViaSubId(info:[String:Any])
    {
        JCLoginManager.sharedInstance.loggingInViaSubId = true
        
        let sessionAttributes = info["sessionAttributes"] as! [String:Any]
        let userData = sessionAttributes["user"] as! [String:Any]
        let subId = userData["subscriberId"] as! String
        let params = [subscriberIdKey:subId]
        JCAppUser.shared.lbCookie = info["lbCookie"] as! String
        JCAppUser.shared.ssoToken = info["ssoToken"] as! String
        
        let url = basePath.appending(loginViaSubIdUrl)
        let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params as Any as? Dictionary<String, Any>, encoding: .JSON)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: loginRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                    JCLoginManager.sharedInstance.loggingInViaSubId = false
                let code = parsedResponse["messageCode"] as! Int
                if(code == 200)
                {
                    weakSelf?.setUserData(data: parsedResponse )
                    JCLoginManager.sharedInstance.setUserToDefaults()
                    DispatchQueue.main.async {
                        weakSelf?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: readyToPlayNotificationName, object: nil)
                        })
                    }
                }
                else
                {
                
                }
            }
        }
    }
    
    
    func setUserData(data:[String:Any])
    {
        JCAppUser.shared.lbCookie = data["lbCookie"] as! String
        JCAppUser.shared.ssoToken = data["ssoToken"] as! String
        JCAppUser.shared.commonName = data["name"] as! String
        JCAppUser.shared.userGroup = data["userGrp"] as! String
        JCAppUser.shared.subscriberId = data["subscriberId"] as! String
        JCAppUser.shared.unique = data["uniqueId"] as! String
    }
    
}
