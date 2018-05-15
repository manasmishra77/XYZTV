//
//  JCLoginManager.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 31/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//
import UIKit
import Foundation

class JCLoginManager: UIViewController {
    static let sharedInstance = JCLoginManager()
    
    var loggingInViaSubId = false
    var isLoginFromSettingsScreen = false
    func isUserLoggedIn() -> Bool {
        if((UserDefaults.standard.value(forKey: isUserLoggedInKey)) != nil) {
            return UserDefaults.standard.value(forKey: isUserLoggedInKey) as! Bool
        }
        return false
    }
    
    func setUserToDefaults() {
        UserDefaults.standard.setValue(true, forKeyPath: isUserLoggedInKey)
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: JCAppUser.shared)
        UserDefaults.standard.set(encodedData, forKey: savedUserKey)
    }
    
    func getUserFromDefaults() -> JCAppUser
    {
        if((UserDefaults.standard.value(forKey: savedUserKey)) != nil)
        {
            if let data = UserDefaults.standard.data(forKey: savedUserKey),
                let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? JCAppUser
            {
                JCAppUser.shared = user
            }
            else
            {
                print("There is an issue")
            }
            
        }
        
        return JCAppUser.shared
    }
    
    func performNetworkCheck(completion: @escaping NetworkCheckCompletionBlock) {
        let networkCheckRequest = RJILApiManager.defaultManager.prepareRequest(path: networkCheckUrl, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: networkCheckRequest) { (data, response, error) in
            
            //non jio network
            if let responseError = error {
                print(responseError)
                completion(false)
                return
            }
            
            if let responseData = data, let networkResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                let result = networkResponse["result"] as? [String: Any]
                let data = result?["data"] as? [String: Any]
                let isOnJioNetwork = data?["isJio"] as? Bool ?? false
                if isOnJioNetwork == true
                {
                    let zlaUserDataRequest = RJILApiManager.defaultManager.prepareRequest(path: zlaUserDataUrl, encoding: .URL)
                    RJILApiManager.defaultManager.get(request: zlaUserDataRequest, completion: { (data, response, error) in
                        if let responseError = error {
                            //self.navigateToLoginVC()
                            print(responseError)
                            completion(false)
                            return
                        }
                        
                        if let responseData = data, let userData:[String:Any] = RJILApiManager.parse(data: responseData)
                        {
                            self.callWebServiceToLoginViaSubId(info: userData, completion: { (isLoginSuccessful) in
                                completion(isLoginSuccessful)
                                
                            })
                        }
                        
                    })
                }
                else
                {
                    completion(false)
                    //self.navigateToLoginVC()
                }
            }
        }
    }
    
    fileprivate func callWebServiceToLoginViaSubId(info:[String:Any],completion:@escaping NetworkCheckCompletionBlock)
    {
        JCLoginManager.sharedInstance.loggingInViaSubId = true
        
        let sessionAttributes = info["sessionAttributes"] as? [String:Any]
        let user = sessionAttributes?["user"] as? [String:Any]
        
        JCAppUser.shared.lbCookie = info["lbCookie"] as? String ?? ""
        JCAppUser.shared.ssoToken = info["ssoToken"] as? String ?? ""
        let subId = user!["subscriberId"] as? String ?? ""
        
        let params = [subscriberIdKey:subId]
        
        let url = basePath.appending(loginViaSubIdUrl)
        let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params as Any as? Dictionary<String, Any>, encoding: .JSON)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: loginRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                completion(false)
                let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
                JCAnalyticsManager.sharedInstance.event(category: LOGIN_EVENT, action: FAILURE_ACTION, label: "4G", customParameters: customParams)
                return
            }
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                JCLoginManager.sharedInstance.loggingInViaSubId = false
                let code = parsedResponse["messageCode"] as? Int ?? 0
                if(code == 200)
                {
                    weakSelf?.setUserData(data: parsedResponse) 
                    
                    let eventProperties = ["Source": "4G", "Platform": "TVOS", "Userid": Utility.sharedInstance.encodeStringWithBase64(aString: JCAppUser.shared.uid)]
                    JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Logged In", properties: eventProperties)
                    
                    // For Internal Analytics Event
                    let loginSuccessInternalEvent = JCAnalyticsEvent.sharedInstance.getLoggedInEventForInternalAnalytics(methodOfLogin: "4G", source: "Skip", jioIdValue: Utility.sharedInstance.encodeStringWithBase64(aString: JCAppUser.shared.uid))
                    JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: loginSuccessInternalEvent)
                    let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
                    JCAnalyticsManager.sharedInstance.event(category: LOGIN_EVENT, action: SUCCESS_ACTION, label: "4G", customParameters: customParams)
                    JCLoginManager.sharedInstance.setUserToDefaults()
                    completion(true)
                    
                }
                else
                {
                    let eventProperties = ["Userid":Utility.sharedInstance.encodeStringWithBase64(aString: JCAppUser.shared.uid),"Reason":"4G","Platform":"TVOS","Error Code":code,"Message":""] as [String:Any]
                    JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Login Failed", properties: eventProperties)
                    
                    // For Internal Analytics Event
                    let loginFailedInternalEvent = JCAnalyticsEvent.sharedInstance.getLoginFailedEventForInternalAnalytics(jioID: "", errorMessage: "")
                    JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: loginFailedInternalEvent)
                    
                    let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
                    JCAnalyticsManager.sharedInstance.event(category: LOGIN_EVENT, action: FAILURE_ACTION, label: "4G", customParameters: customParams)
                    
                    completion(false)
                }
            }
        }
    }
    
    fileprivate func setUserData(data: [String:Any])
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
    
    func logoutUser()
    {
        UserDefaults.standard.setValue(false, forKeyPath: isUserLoggedInKey)
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: "")
        JCAppUser.shared = JCAppUser()
        UserDefaults.standard.set(encodedData, forKey: savedUserKey)
        JCDataStore.sharedDataStore.tvWatchList?.data = nil
        JCDataStore.sharedDataStore.moviesWatchList?.data = nil
        JCDataStore.sharedDataStore.resumeWatchList = nil
        JCDataStore.sharedDataStore.userRecommendationList = nil
    }
    
    
}
