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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utility.sharedInstance.startNetworkNotifier()
        
        if(JCLoginManager.sharedInstance.isUserLoggedIn()) {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            callWebServiceToCheckVersion()
        } else {
            JCLoginManager.sharedInstance.performNetworkCheck(completion: { [weak self] (isOnJioNetwork) in
                guard let self = self else {return}
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
        RJILApiManager.callWebServiceToCheckVersion {[weak self] (response) in
            guard let self = self else {return}
            if response.isSuccess {
                self.tryAgainCount = 0
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
                self.callWebServiceForConfigData()
            } else {
                self.showAlertForCheckVersion(alertString: "")
            }
            
        }
    }
    func callWebServiceForConfigData() {
        RJILApiManager.getConfigData {[weak self] (isSuccess, errorMsg) in
            guard let self = self else {return}
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
        RJILApiManager.getBaseModel(pageNum: page, type: .home) {[weak self] (isSuccess, erroMsg) in
            guard let self = self else {return}
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
            let sideNavVC = SideNavigationVC(nibName: "SideNavigationVC", bundle: nil)
            let navController = UINavigationController(rootViewController: sideNavVC)
            navController.navigationBar.isHidden = true
            self.view.window?.rootViewController = navController

        }
    }
    
    

    
    func showAlert(alertString: String) {
        weak var weakSelf = self
        let alert = UIAlertController(title: "Connection Error",
                                      message: alertString,
                                      preferredStyle: UIAlertController.Style.alert)
        
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
    
    func showAlertForCheckVersion(alertString: String) {
        weak var weakSelf = self
        let alert = UIAlertController(title: "Connection Error",
                                      message: alertString,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            weakSelf?.tryAgainCount += 1
            if let count = weakSelf?.tryAgainCount {
                if count < 4 {
                    weakSelf?.callWebServiceToCheckVersion()
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
    
    func showUpdateAlert(isMandatory: Bool, alertMessage: String, title: String) {
        weak var weakSelf = self
        let alert = UIAlertController(title: title,
                                      message: alertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let skipAction = UIAlertAction(title: "Skip", style: .default) { (action) in
            weakSelf?.callWebServiceForConfigData()
            
        }
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            let urlString = "com.apple.TVAppStore://itunes.apple.com/in/app/jiocinema/id1067316596?mt=8"
            guard let url = URL(string: urlString) else {return}
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary(["": ""]), completionHandler: { (bool) in
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
        if presses.first?.type == UIPress.PressType.menu {
            exit(0)
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
