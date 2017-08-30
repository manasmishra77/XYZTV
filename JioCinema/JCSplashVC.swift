//
//  JCSplashVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 11/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSplashVC: UIViewController {

    @IBOutlet weak var splashImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Call config service
        callWebServiceForConfigData()
        
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
        
       callWebServiceForHomeData(page: 0)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateConfigData(dictionaryResponseData: responseData)
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
        RJILApiManager.defaultManager.post(request: homeDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                DispatchQueue.main.async {
                    weakSelf?.showAlert(alertString: "Unable to Connect")
                }
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateHomeData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateHomeData(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Home)
        
        self.navigateToHomeVC()
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
        weak var weakSelf = self
        let alert = UIAlertController(title: "Connection Error",
                                      message: alertString,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            weakSelf?.callWebServiceForHomeData(page: 0)
        }
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
