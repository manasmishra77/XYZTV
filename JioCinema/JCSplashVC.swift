//
//  JCSplashVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 11/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit


class JCSplashVC: UIViewController {
    
    fileprivate  var tryAgainCount = 0
    
    @IBOutlet weak var splashImage: UIImageView!
    
    let dispatchGroup = DispatchGroup()
    var isHomeDataAvailable:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        Utility.sharedInstance.startNetworkNotifier()
        
        if(JCLoginManager.sharedInstance.isUserLoggedIn()) {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            callWebServiceToCheckVersion()
        } else {
            JCLoginManager.sharedInstance.performNetworkCheck(completion: { [unowned self] (isOnJioNetwork) in
                //user has been set in user defaults
                self.callWebServiceToCheckVersion()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("In Splash Screen Deinit")
    }
    //MARK:- Version check and update
    func callWebServiceToCheckVersion() {
        RJILApiManager.callWebServiceToCheckVersion {[unowned self] (response) in
            if response.isSuccess {
                let checkModel =  response.model!
                let versionBuildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
                // If build number is coming from back-end
                if let currentBuildNumber = Float(versionBuildNumber), let upComingBuildNumber = checkModel.result?.data?[0].version?.floatValue(), upComingBuildNumber != 0 {
                    if upComingBuildNumber > currentBuildNumber {
                        if let mandatory = checkModel.result?.data?[0].mandatory, mandatory {
                            self.showUpdateAlert(isMandatory: true, alertMessage: checkModel.result?.data?[0].description ?? "", title: checkModel.result?.data?[0].heading ?? "")
                        } else {
                            self.showUpdateAlert(isMandatory: false, alertMessage: checkModel.result?.data?[0].description ?? "", title: checkModel.result?.data?[0].heading ?? "")
                        }
                        return
                    }
                }
            }
            self.callWebServiceForConfigData()
        }
    }
    func callWebServiceForConfigData() {
        RJILApiManager.getConfigData {[unowned self] (isSuccess, errorMsg) in
            if isSuccess {
                ParentalPinManager.shared.setParentalPinModel()
                self.callWebServiceForHomeData(page: 0)
            } else {
                DispatchQueue.main.async {
                    self.showAlert(alertString: networkErrorMessage)
                }
            }
        }
    }
    
    func callWebServiceForHomeData(page: Int) {
        RJILApiManager.getBaseModel(pageNum: page, type: .home) {[unowned self] (isSuccess, erroMsg) in
            guard isSuccess else {
                DispatchQueue.main.async {
                    self.showAlert(alertString: networkErrorMessage)
                }
                return
            }
            self.navigateToHomeVC()
        }
    }
    
    
    func navigateToHomeVC() {
        DispatchQueue.main.async {
            let tabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: tabBarStoryBoardId)
            let navController = UINavigationController(rootViewController: tabBarVC)
            navController.navigationBar.isHidden = true
            self.view.window?.rootViewController = navController
        }
    }
    
    
    /*
     func callWebservicesForHomeData() {
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
     print("*********home data failed**********")
     weakSelf?.showAlert(alertString: networkErrorMessage)
     }
     }
     }
     
     
     /*
     let params = [kAppKey: kAppKeyValue]
     
     let configDataRequest = RJILApiManager.defaultManager.prepareRequest(path: configUrl, params: params, encoding: .URL)
     weak var weakSelf = self
     RJILApiManager.defaultManager.get(request: configDataRequest!) { (data, response, error) in
     
     if let responseError = error {
     //TODO: handle error
     print(responseError)
     print("*********config data failed**********")
     weakSelf?.showAlert(alertString: networkErrorMessage)
     return
     }
     if let responseData = data
     {
     weakSelf?.evaluateConfigData(dictionaryResponseData: responseData)
     weakSelf?.callWebservicesForHomeData()
     return
     }
     }*/
     }
     
     func evaluateConfigData(dictionaryResponseData responseData:Data) {
     //Success
     //JCDataStore.sharedDataStore.setConfigData(withResponseData: responseData)
     }
     
     
     func callWebServiceForHomeData(page: Int) {
     let url = homeDataUrl.appending(String(page))
     let homeDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
     weak var weakSelf = self
     dispatchGroup.enter()
     RJILApiManager.defaultManager.get(request: homeDataRequest!) { (data, response, error) in
     if error != nil {
     //TODO: handle error
     weakSelf?.isHomeDataAvailable = false
     weakSelf?.dispatchGroup.leave()
     return
     }
     if let responseData = data {
     weakSelf?.evaluateHomeData(dictionaryResponseData: responseData)
     ParentalPinManager.shared.setParentalPinModel()
     weakSelf?.isHomeDataAvailable = true
     weakSelf?.dispatchGroup.leave()
     return
     }
     }
     }
     
     func evaluateHomeData(dictionaryResponseData responseData:Data) {
     //Success
     JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Home)
     }*/
    
    
    
    
    
    func showAlert(alertString: String) {
        weak var weakSelf = self
        let alert = UIAlertController(title: "Connection Error",
                                      message: alertString,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            weakSelf?.tryAgainCount += 1
            if let count = weakSelf?.tryAgainCount {
                if count < 4 {
                    weakSelf?.callWebServiceForConfigData()
                } else {
                    exit(0)
                }
            }
        }
        
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    //    func parseCheckVersionData(_ responseData: Data) -> CheckVersionModel? {
    //        do {
    //               return try JSONDecoder().decode(CheckVersionModel.self, from: responseData)
    //        } catch {
    //            print("Error deserializing JSON: \(error)")
    //        }
    //        return nil
    //    }
    
    func showUpdateAlert(isMandatory: Bool, alertMessage: String, title: String) {
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
        if !isMandatory {
            alert.addAction(skipAction)
        }
        alert.addAction(updateAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == UIPressType.menu {
            exit(0)
        }
    }
    
}
