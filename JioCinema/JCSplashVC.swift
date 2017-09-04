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
    
    let dispatchGroup = DispatchGroup()
    var isHomeDataAvailable:Bool?
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
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callWebservicesForHomeData()
    {
        callWebServiceForHomeData(page: 0)
        callWebServiceForLanguageList()
        callWebServiceForGenreList()
        weak var weakSelf = self
        dispatchGroup.notify(queue: DispatchQueue.main)
        {
            weakSelf?.mergeDataArray()
            if (weakSelf?.isHomeDataAvailable)!
            {
                weakSelf?.navigateToHomeVC()
            }
            else
            {
                weakSelf?.showAlert(alertString: "No Network Available")
            }
        }
    }
    
    func mergeDataArray()
    {
        var tempArray = JCDataStore.sharedDataStore.homeData?.data
        if let languageData = JCDataStore.sharedDataStore.languageData?.data?[0]
        {
            tempArray?.insert(languageData, at: (JCDataStore.sharedDataStore.configData?.configDataUrls?.languagePosition)!)
        }
        
        if let genreData = JCDataStore.sharedDataStore.genreData?.data?[0]
        {
            tempArray?.insert(genreData, at: (JCDataStore.sharedDataStore.configData?.configDataUrls?.genrePosition)!)
        }
        
        JCDataStore.sharedDataStore.mergedHomeData = tempArray
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
                weakSelf?.showAlert(alertString: "No Network Available")
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
    
    
    func callWebServiceForLanguageList()
    {
        let url = languageListUrl
        let languageListRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        dispatchGroup.enter()
        RJILApiManager.defaultManager.post(request: languageListRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                weakSelf?.dispatchGroup.leave()
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateLanguageList(dictionaryResponseData: responseData)
                weakSelf?.dispatchGroup.leave()
                return
            }
        }
    }
    
    func evaluateLanguageList(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Language)
        
    }
    
    func callWebServiceForGenreList()
    {
        let url = genreListUrl
        let genreListRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        dispatchGroup.enter()
        RJILApiManager.defaultManager.post(request: genreListRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                weakSelf?.dispatchGroup.leave()
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateGenreList(dictionaryResponseData: responseData)
                weakSelf?.dispatchGroup.leave()
                return
            }
        }
    }
    
    func evaluateGenreList(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Genre)
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
            weakSelf?.callWebServiceForConfigData()
        }
        
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
