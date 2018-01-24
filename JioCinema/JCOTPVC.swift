//
//  OTPVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 17/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

let MESSAGE_LOGINWITHOUTERROR   = "Login Failed"


class JCOTPVC: UIViewController,UISearchBarDelegate
{
    
    @IBOutlet weak var keyBoardButton1: JCKeyboardButton!
    @IBOutlet weak var jioNumberTFLabel: UILabel!
    @IBOutlet weak var resendOTPButton: JCButton!
    @IBOutlet weak var signInButton: JCButton!
    @IBOutlet weak var getOTPButton: JCButton!
    @IBOutlet weak var resendOTPLableToast: UILabel!
    var activityIndicator:UIActivityIndicatorView?
    var isRequestMadeForResend = false
    //var searchController:UISearchController? = nil
    var myPreferredFocuseView: UIView? = nil
    var enteredJioNumber:String?
    var enteredNumber:String? = nil
    var timerCount = 0
    let containerView = UIView(frame: CGRect.init(x: 200, y: 200, width: 600, height: 400))
    
    var isLoginPresentedFromAddToWatchlist = false
    var isLoginPresentedFromPlayNowButtonOfMetaData = false
    var isLoginPresentedFromItemCell = false
    var presentingVCOfLoginVc: Any = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getOTPButton.layer.cornerRadius = 8
        signInButton.layer.cornerRadius = 8
        resendOTPButton.layer.cornerRadius = 8
        jioNumberTFLabel.layer.cornerRadius = 8
        
        //searchController?.searchBar.delegate = self
        addSwipeGesture()
    }
    
    
    //MARK:- Add Swipe Gesture
    func addSwipeGesture()
    {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureHandler))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
    }
    
    func swipeGestureHandler(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                // self.swipeUpRecommendationView()
                break
            case UISwipeGestureRecognizerDirection.down:
                //self.swipeDownRecommendationView()
                if signInButton.isHidden{
                    if getOTPButton.isFocused == false{
                        myPreferredFocuseView = getOTPButton
                        self.setNeedsFocusUpdate()
                        self.updateFocusIfNeeded()
                    }
                }
                else{
                    if signInButton.isFocused == false && resendOTPButton.isFocused == false{
                        myPreferredFocuseView = signInButton
                        self.setNeedsFocusUpdate()
                        self.updateFocusIfNeeded()
                    }
                }
                break
            default:
                break
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        myPreferredFocuseView = getOTPButton
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]
    {
        return [myPreferredFocuseView!]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickOnSignInButton(_ sender: Any)
    {
        let enteredOTP = jioNumberTFLabel.text//searchController?.searchBar.text!
        if(enteredOTP?.count == 0)
        {
            self.showAlert(alertTitle: "Invalid Entry", alertMessage: "Please Enter OTP")
        }
        else
        {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            view.addSubview(activityIndicator!)
            activityIndicator?.frame.origin = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
            activityIndicator?.startAnimating()
            
            self.callWebServiceToVerifyOTP(otp: enteredOTP!)
            //searchController?.searchBar.text = ""
            //searchController?.searchBar.placeholder = "Enter OTP"
        }
    }
    
    @IBAction func didClickOnKeyBoardButton(_ sender: JCKeyboardButton) {
        if sender.tag == -1{
            if jioNumberTFLabel.text != "" && jioNumberTFLabel.text != "Enter Jio Number" && jioNumberTFLabel.text != "Enter OTP" {
                let number = jioNumberTFLabel.text
                let truncatedNumber = number?.substring(to: (number?.index(before: (number?.endIndex)!))!)
                jioNumberTFLabel.text = truncatedNumber
                
                if truncatedNumber == ""
                {
                    jioNumberTFLabel.text = signInButton.isHidden ? "Enter Jio Number" : "Enter OTP"
                    
                }
            }
        }
        else{
            var number = jioNumberTFLabel.text
            if number == "Enter Jio Number" || number == "Enter OTP"{
                number = ""
            }
            if signInButton.isHidden == true{
                if (number?.count)! > 9{
                    return
                }
            }
            else{
                if (number?.count)! > 5{
                    return
                }
            }
            jioNumberTFLabel.text = number! + String(sender.tag)
            
        }
    }
    
    @IBAction func didClickOnResendOTPButton(_ sender: Any)
    {
        resendOTPButton.isEnabled = false
        self.isRequestMadeForResend = true
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
       // jioNumberTFLabel.text = "8356903414"
        enteredJioNumber = jioNumberTFLabel.text
        if(enteredJioNumber?.count != 10)
        {
            self.showAlert(alertTitle: "Invalid Entry", alertMessage: "Please Enter Jio Number")
            self.jioNumberTFLabel.text = "Enter Jio Number"
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
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        view.addSubview(activityIndicator!)
        activityIndicator?.frame.origin = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        activityIndicator?.startAnimating()
        
        enteredNumber = "+91".appending(number)
        let params = [identifierKey:enteredNumber,otpIdentifierKey:enteredNumber,actionKey:actionValue]
        weak var weakSelf = self
        let otpRequest = RJILApiManager.defaultManager.prepareRequest(path: getOTPUrl, params: params as Any as? Dictionary<String, Any>, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: otpRequest) { (data, response, error) in
            DispatchQueue.main.async {
                weakSelf?.activityIndicator?.stopAnimating()
            }
            
            if let responseError = error as NSError?
            {
                if responseError.code == 204
                {
                    DispatchQueue.main.async {
                        
                        //weakSelf?.searchController?.searchBar.text = ""
                        //weakSelf?.searchController?.searchBar.placeholder = "Enter OTP"
                        //weakSelf?.searchController?.searchBar.isSecureTextEntry = true
                        weakSelf?.getOTPButton.isHidden = true
                        weakSelf?.resendOTPButton.isHidden = false
                        weakSelf?.resendOTPButton.isEnabled = false
                        weakSelf?.signInButton.isHidden = false
                        weakSelf?.jioNumberTFLabel.text = "Enter OTP"
                        _ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.enableResendButton), userInfo: nil, repeats: false)
                        
                    }
                }
                else
                {
                    let errorString = responseError.userInfo["NSLocalizedDescription"]! as? String ?? ""
                    let data = errorString.data(using: .utf8)
                    _ = try? JSONSerialization.jsonObject(with: data!)
                    
                    
                    DispatchQueue.main.async {
                        if (weakSelf?.isRequestMadeForResend)!
                        {
                            weakSelf?.showAlert(alertTitle: "Unable to send OTP", alertMessage: "Please try again after some time")
                            //weakSelf?.searchController?.searchBar.text = ""
                        }
                        else
                        {
                            weakSelf?.showAlert(alertTitle: "Invalid Jio Number", alertMessage: "Entered Jio Number is invalid, please try again")
                            self.jioNumberTFLabel.text = "Enter Jio Number"
                            //weakSelf?.searchController?.searchBar.text = ""
                        }
                        
                        weakSelf?.isRequestMadeForResend = false
                    }
                    _ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.enableResendButton), userInfo: nil, repeats: false)
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
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                }
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
        
        let sessionAttributes = info["sessionAttributes"] as? [String:Any]
        let userData = sessionAttributes!["user"] as? [String:Any]
        let subId = userData!["subscriberId"] as? String ?? ""
        let params = [subscriberIdKey:subId]
        JCAppUser.shared.lbCookie = info["lbCookie"] as? String ?? ""
        JCAppUser.shared.ssoToken = info["ssoToken"] as? String ?? ""
        
        let url = basePath.appending(loginViaSubIdUrl)
        let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params as Any as? Dictionary<String, Any>, encoding: .JSON)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: loginRequest) { (data, response, error) in
            
            DispatchQueue.main.async {
                weakSelf?.activityIndicator?.stopAnimating()
            }
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                
                self.sendLoggedInAnalyticsEventWithFailure(errorMessage: responseError.localizedDescription)
                
                return
            }
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                JCLoginManager.sharedInstance.loggingInViaSubId = false
                let code = parsedResponse["messageCode"] as? Int ?? 0
                if(code == 200)
                {
                    
                    weakSelf?.setUserData(data: parsedResponse)
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
                else
                {
                    self.sendLoggedInAnalyticsEventWithFailure(errorMessage: MESSAGE_LOGINWITHOUTERROR)
                }
            }
        }
    }
    
    
    func setUserData(data:[String:Any])
    {
        JCAppUser.shared.lbCookie = data["lbCookie"] as? String ?? ""
        JCAppUser.shared.ssoToken = data["ssoToken"] as? String ?? ""
        JCAppUser.shared.commonName = data["name"] as? String ?? ""
        JCAppUser.shared.userGroup = data["userGrp"] as? String ?? ""
        JCAppUser.shared.subscriberId = data["subscriberId"] as? String ?? ""
        JCAppUser.shared.unique = data["uniqueId"] as? String ?? ""
        JCAppUser.shared.uid = data["username"] as? String ?? ""
        JCAppUser.shared.mToken = data["mToken"] as? String ?? ""
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if resendOTPButton.isHidden == true {
            if (searchBar.text?.count)! < 10 {
                getOTPButton.isUserInteractionEnabled = false
            }
            else
            {
                getOTPButton.isUserInteractionEnabled = true
            }
        }
        else
        {
            if (searchBar.text?.count)! < 6 {
                signInButton.isUserInteractionEnabled = false
            }
            else
            {
                signInButton.isUserInteractionEnabled = true
            }
        }
        
    }
    //MARK:- Send Logged In Analytics Event With Success
    func sendLoggedInAnalyticsEventWithSuccess() {
        //Sending events to clever tap
        let eventProperties = ["Source":"OTP","Platform":"TVOS","Userid":Utility.sharedInstance.encodeStringWithBase64(aString: JCAppUser.shared.uid)]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Logged In", properties: eventProperties)
        
        //Sending events for internal analytics
        let eventDict = JCAnalyticsEvent.sharedInstance.getLoggedInEventForInternalAnalytics(methodOfLogin: "OTP", source: "Manual", jioIdValue: Utility.sharedInstance.encodeStringWithBase64(aString: JCAppUser.shared.uid))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: eventDict)
        
        //For Google Analytics Event
        let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
        JCAnalyticsManager.sharedInstance.event(category: LOGIN_EVENT, action: SUCCESS_ACTION, label: "OTP", customParameters: customParams)
        
    }
    
    
    
    //MARK:- Send Logged In Analytics Event With Failure
    func sendLoggedInAnalyticsEventWithFailure(errorMessage:String)
    {
        
        // For Clever Tap Event
        let eventProperties = ["Userid":Utility.sharedInstance.encodeStringWithBase64(aString: self.enteredNumber),"Reason":"OTP","Platform":"TVOS","Error Code":"01000","Message":"Authentication failed"]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Login Failed", properties: eventProperties)
        
        // For Internal Analytics Event
        
        let loginFailedInternalEvent = JCAnalyticsEvent.sharedInstance.getLoginFailedEventForInternalAnalytics(jioID: self.jioNumberTFLabel.text!, errorMessage: errorMessage)
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: loginFailedInternalEvent)
        
        //For Google Analytics Event
        let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
        JCAnalyticsManager.sharedInstance.event(category: LOGIN_EVENT, action: FAILURE_ACTION, label:"Type: OTP" + errorMessage, customParameters: customParams)
        
    }
    
    
}

