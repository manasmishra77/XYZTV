//
//  OTPVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 17/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCOTPVC: UIViewController,UISearchBarDelegate
{
    @IBOutlet weak var resendOTPButton: JCButton!
    @IBOutlet weak var signInButton: JCButton!
    @IBOutlet weak var getOTPButton: JCButton!
    @IBOutlet weak var resendOTPLableToast: UILabel!
    var isRequestMadeForResend = false
   var searchController:UISearchController? = nil
    var enteredJioNumber:String?
    var enteredNumber:String? = nil
    var timerCount = 0
    let containerView = UIView.init(frame: CGRect.init(x: 200, y: 200, width: 600, height: 400))
     
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getOTPButton.layer.cornerRadius = 8
        signInButton.layer.cornerRadius = 8
        resendOTPButton.layer.cornerRadius = 8
        searchController?.searchBar.delegate = self
        
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
            self.showAlert(alertTitle: "Invalid Entry", alertMessage: "Please Enter OTP")
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
        resendOTPButton.isEnabled = false
        self.isRequestMadeForResend = false
        resendOTPLableToast.isHidden = false
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector (hideResendOTPLabelToast), userInfo: nil, repeats: false)
        self.callWebServiceToGetOTP(number: enteredJioNumber!)
    }
    
    func hideResendOTPLabelToast()
    {
        resendOTPLableToast.isHidden = true
    }
    
    @IBAction func didClickOnGetOTPButton(_ sender: Any)
    {
        enteredJioNumber = searchController?.searchBar.text!
        if(enteredJioNumber?.characters.count == 0)
        {
            self.showAlert(alertTitle: "Invalid Entry", alertMessage: "Please Enter Jio Number")
        }
        else
        {
            self.callWebServiceToGetOTP(number: enteredJioNumber!)
        }
    }
    
    
    
    fileprivate func showAlert(alertTitle:String,alertMessage:String)
    {
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
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
        weak var weakSelf = self
        let otpRequest = RJILApiManager.defaultManager.prepareRequest(path: getOTPUrl, params: params as Any as? Dictionary<String, Any>, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: otpRequest) { (data, response, error) in
            
            if let responseError = error as NSError?
            {
                if responseError.code == 204
                {
                    DispatchQueue.main.async {
                        weakSelf?.searchController?.searchBar.text = ""
                        weakSelf?.searchController?.searchBar.placeholder = "Enter OTP"
                        weakSelf?.searchController?.searchBar.isSecureTextEntry = true
                        weakSelf?.getOTPButton.isHidden = true
                        weakSelf?.resendOTPButton.isHidden = false
                        weakSelf?.resendOTPButton.isEnabled = false
                        weakSelf?.signInButton.isHidden = false
                        _ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.enableResendButton), userInfo: nil, repeats: false)
                        
                    }
                }
                else
                {
                    let errorString = responseError.userInfo["NSLocalizedDescription"]! as! String
                    let data = errorString.data(using: .utf8)
                    let json = try? JSONSerialization.jsonObject(with: data!)
                    
                    
                    DispatchQueue.main.async {
                        if (weakSelf?.isRequestMadeForResend)!
                        {
                            weakSelf?.showAlert(alertTitle: "Unable to send OTP", alertMessage: "Please try again after some time")
                            weakSelf?.searchController?.searchBar.text = ""
                        }
                        else
                        {
                            weakSelf?.showAlert(alertTitle: "Invalid Jio Number", alertMessage: "Entered Jio Number is invalid, please try again")
                            weakSelf?.searchController?.searchBar.text = ""
                        }
                        
                        weakSelf?.isRequestMadeForResend = false
                    }
                }
                return
            }
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                print(parsedResponse["code"]!)
                print(responseData)
                return
            }
        }
    }

    func enableResendButton()
    {
        resendOTPButton.isEnabled = true
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
                self.showAlert(alertTitle: "Invalid OTP", alertMessage: "Please Enter Valid OTP")
//                return
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
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var maxLength:Int?
        if resendOTPButton.isHidden == true
        {
            maxLength = 10
        }
        else
        {
            maxLength = 6
        }
        let currentString: NSString = searchBar.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: text) as NSString
            return newString.length <= maxLength!
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if resendOTPButton.isHidden == true {
            if (searchBar.text?.characters.count)! < 10 {
                getOTPButton.isUserInteractionEnabled = false
            }
            else
            {
                getOTPButton.isUserInteractionEnabled = true
            }
        }
        else
        {
            if (searchBar.text?.characters.count)! < 6 {
                signInButton.isUserInteractionEnabled = false
            }
            else
            {
                signInButton.isUserInteractionEnabled = true
            }
        }
        
    }
    
}
