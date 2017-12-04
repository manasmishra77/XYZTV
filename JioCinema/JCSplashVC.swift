//
//  JCSplashVC.swift
//  JioCinema
//
//  Crevard by Pallav Trivedi on 11/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit


class JCSplashVC: UIViewController {
    
    @IBOutlet weak var splashImage: UIImageView!
    
    let dispatchGroup = DispatchGroup()
    var isHomeDataAvailable:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utility.sharedInstance.startNetworkNotifier()
        callWebServiceToCheckVersion()

        if(JCLoginManager.sharedInstance.isUserLoggedIn())
        {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
        }
        else
        {
            JCLoginManager.sharedInstance.performNetworkCheck(completion: { (isOnJioNetwork) in
                //user has been set in user defaults
            })
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callWebservicesForHomeData()
    {
        callWebServiceForHomeData(page: 0)
        weak var weakSelf = self
        dispatchGroup.notify(queue: DispatchQueue.main)
        {
            //weakSelf?.mergeDataArray()
            if (weakSelf?.isHomeDataAvailable)!
            {
                weakSelf?.navigateToHomeVC()
            }
            else
            {
                weakSelf?.showAlert(alertString: networkErrorMessage)
            }
        }
    }
    
    func callWebServiceForConfigData()
    {
        let params = [kAppKey:kAppKeyValue]
        
        let configDataRequest = RJILApiManager.defaultManager.prepareRequest(path: configUrl, params: params, encoding: .URL)
        weak var weakSelf = self
        RJILApiManager.defaultManager.get(request: configDataRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                //print(responseError)
                weakSelf?.showAlert(alertString: networkErrorMessage)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateConfigData(dictionaryResponseData: responseData)
                weakSelf?.callWebservicesForHomeData()
                return
            }
        }
    }
    
    func evaluateConfigData(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setConfigData(withResponseData: responseData)
    }
    
    func callWebServiceForHomeData(page:Int)
    {
        let url = homeDataUrl.appending(String(page))
        let homeDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        dispatchGroup.enter()
        RJILApiManager.defaultManager.post(request: homeDataRequest) { (data, response, error) in
            if error != nil
            {
                //TODO: handle error
                weakSelf?.isHomeDataAvailable = false
                weakSelf?.dispatchGroup.leave()
                
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateHomeData(dictionaryResponseData: responseData)
                weakSelf?.isHomeDataAvailable = true
                weakSelf?.dispatchGroup.leave()
                return
            }
        }
    }
    
    func evaluateHomeData(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Home)
    }
    
    func navigateToHomeVC()
    {
        DispatchQueue.main.async {
            
            let tabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: tabBarStoryBoardId)
            let navController = UINavigationController(rootViewController: tabBarVC)
            navController.navigationBar.isHidden = false
            self.view.window?.rootViewController = navController
        }
    }
    
     func showAlert(alertString:String)
    {
        weak var weakSelf = self
        let alert = UIAlertController(title: "Connection Error",
                                      message: alertString,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
           
            
                weakSelf?.callWebServiceForConfigData()
            
        }
        
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //MARK:- Version check and update
    func callWebServiceToCheckVersion() {
        let url = checkVersionUrl
        let checkVersionRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        //dispatchGroup.enter()
        RJILApiManager.defaultManager.get(request: checkVersionRequest) { (data, response, error) in
            if error != nil
            {
               //print(error)
                weakSelf?.callWebServiceForConfigData()
                return
            }
            if let responseData = data
            {
                let checkModel = weakSelf?.parseCheckVersionData(responseData)
                let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1000"
                let versionBuildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
                
                // If build number is coming from back-end
                if let currentBuildNumber = Int(versionBuildNumber), let upComingBuildNumber = checkModel?.result?.data?[0].buildNumber, upComingBuildNumber != 0{
                    if upComingBuildNumber > currentBuildNumber{
                        if let mandatory = checkModel?.result?.data?[0].mandatory, mandatory{
                            weakSelf?.showUpdateAlert(isMandatory: true, alertMessage: checkModel?.result?.data?[0].description ?? "", title: checkModel?.result?.data?[0].heading ?? "")
                        }else{
                            weakSelf?.showUpdateAlert(isMandatory: false, alertMessage: checkModel?.result?.data?[0].description ?? "", title: checkModel?.result?.data?[0].heading ?? "")
                        }
                    }
                    else{
                        weakSelf?.callWebServiceForConfigData()
                    }
                }
                
                //If version string is coming from back-end
                else if let currentVersion = Float(versionString), let upComingVersion = checkModel?.result?.data?[0].version{
                    if currentVersion < upComingVersion{
                        if let mandatory = checkModel?.result?.data?[0].mandatory, mandatory{
                            weakSelf?.showUpdateAlert(isMandatory: true, alertMessage: checkModel?.result?.data?[0].description ?? "", title: checkModel?.result?.data?[0].heading ?? "")
                        }else{
                            weakSelf?.showUpdateAlert(isMandatory: false, alertMessage: checkModel?.result?.data?[0].description ?? "", title: checkModel?.result?.data?[0].heading ?? "")
                        }
                    }else{
                        weakSelf?.callWebServiceForConfigData()
                    }
                }
                else
                {
                    weakSelf?.callWebServiceForConfigData()
                }
                return
            }
        }
        
    }
    
    func parseCheckVersionData(_ responseData: Data) -> CheckVersionModel? {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
            if let responseDict = jsonDict as? [String: Any]{
                var checkModel = CheckVersionModel(messageCode: nil, result: nil)
                checkModel.messageCode = responseDict["messageCode"] as? Int
                if let resultDict = jsonDict as? [String: Any]{
                    if let resultDataDict = resultDict["result"] as? [String: Any]{
                        if let resultDataArray = resultDataDict["data"] as? [[String: Any]]{
                            let resultData = resultDataArray.first
                            var checkModelData = CheckVersionData(version: nil, url: nil, mandatory: nil, description: nil, heading: nil, buildNumber: nil)
                            if resultData != nil{
                            let versionString = resultData!["version"] as? String ?? "0"
                            checkModelData.version = Float(versionString)
                            checkModelData.description = resultData!["description"] as? String
                            checkModelData.heading = resultData!["heading"] as? String
                            checkModelData.url = resultData!["url"] as? String
                            checkModelData.mandatory = resultData!["mandatory"] as? Bool
                            checkModelData.buildNumber = resultData!["buildnumber"] as? Int ?? 0
                            checkModel.result = CheckVersionResult(data: [checkModelData])
                            return checkModel
                            }
                        }
                    }
                }
            }
            
        } catch {
            //print("Error deserializing JSON: \(error)")
        }
        return nil
    }
    
    func showUpdateAlert(isMandatory: Bool, alertMessage: String, title: String)
    {
        
        weak var weakSelf = self
        let alert = UIAlertController(title: title,
                                      message: alertMessage,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let skipAction = UIAlertAction(title: "Skip", style: .default) { (action) in
            
            
            weakSelf?.callWebServiceForConfigData()
            
        }
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            
            let urlString = "com.apple.TVAppStore://itunes.apple.com/in/app/jiocinema/id1067316596?mt=8"
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: ["": ""], completionHandler: { (bool) in
                exit(0)
            })
        }
        if !isMandatory{
            alert.addAction(skipAction)
        }
        alert.addAction(updateAction)
        DispatchQueue.main.async
        {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == UIPressType.menu
        {
            exit(0)
        }
    }
   
    
}
















