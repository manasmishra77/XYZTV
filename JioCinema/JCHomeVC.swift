//
//  JCHomeVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 12/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
class JCHomeVC: JCBaseVC, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate
{
    var loadedPage = 0
    var isResumeWatchDataAvailable = false
    var isLanguageDataAvailable = false
    var isGenereDataAvailable = false
    var isFirstLoaded = false
    var dataItemsForTableview = [DataContainer]()

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        isFirstLoaded = true
        super.activityIndicator.isHidden = true
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(callResumeWatchWebServiceOnPlayerDismiss), name: playerDismissNotificationName, object: nil)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.tabBarController?.delegate = self
        callWebServiceForLanguageList()
        callWebServiceForGenreList()
        
        if JCLoginManager.sharedInstance.isUserLoggedIn()
        {
            callWebServiceForResumeWatchData()
        }
        else
        {
            baseTableView.reloadData()
        }
        
        JCAnalyticsManager.sharedInstance.screenNavigation(screenName: "Home", customParameters: [String:String]())
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if JCDataStore.sharedDataStore.homeData?.data != nil
        {

            if !JCLoginManager.sharedInstance.isUserLoggedIn(){
                isResumeWatchDataAvailable = false
            }
            dataItemsForTableview = (JCDataStore.sharedDataStore.homeData?.data)!
            if let isCarousal = dataItemsForTableview[0].isCarousal{
                if isCarousal{
                    dataItemsForTableview.remove(at: 0)
                }
            }
            if isLanguageDataAvailable{
                
                if let languageData = JCDataStore.sharedDataStore.languageData?.data?[0], let languagePosition = JCDataStore.sharedDataStore.configData?.configDataUrls?.languagePosition
                {
                    if languagePosition < dataItemsForTableview.count{
                        dataItemsForTableview.insert(languageData, at: (JCDataStore.sharedDataStore.configData?.configDataUrls?.languagePosition)!)
                    }
                    
                }
            }
            if isGenereDataAvailable{
                if let genreData = JCDataStore.sharedDataStore.genreData?.data?[0], let genrePosition = JCDataStore.sharedDataStore.configData?.configDataUrls?.genrePosition
                {
                    if genrePosition < dataItemsForTableview.count{
                        dataItemsForTableview.insert(genreData, at: (JCDataStore.sharedDataStore.configData?.configDataUrls?.genrePosition)!)
                    }
                    
                }
                
            }
            if isResumeWatchDataAvailable{
                if let dataResume = JCDataStore.sharedDataStore.resumeWatchList?.data {
                        dataItemsForTableview.insert(dataResume, at: 0)
                }
            }
            return dataItemsForTableview.count
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.tableCellCollectionView.tag = indexPath.row
        cell.itemFromViewController = VideoType.Home
        cell.isResumeWatchCell = false
        
        if isResumeWatchDataAvailable, indexPath.row == 0 {
            cell.isResumeWatchCell = true
        }
        cell.data = dataItemsForTableview[indexPath.row].items
        cell.categoryTitleLabel.text = dataItemsForTableview[indexPath.row].title
        cell.tableCellCollectionView.reloadData()
        
        
        if(indexPath.row == (JCDataStore.sharedDataStore.homeData?.data?.count)! - 2)
        {
            if(loadedPage < (JCDataStore.sharedDataStore.homeData?.totalPages)! - 1)
            {
                callWebServiceForHomeData(page: loadedPage + 1)
                loadedPage += 1
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //For autorotate carousel
        let carouselViews = Bundle.main.loadNibNamed("kInfinityScrollView", owner: self, options: nil)
        let carouselView = carouselViews?.first as! InfinityScrollView
        carouselView.carouselArray = (JCDataStore.sharedDataStore.homeData?.data?[0].items)!
        carouselView.loadViews()
        uiviewCarousel = carouselView
        return carouselView
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (JCDataStore.sharedDataStore.homeData?.totalPages) != nil
        {
            if(loadedPage == (JCDataStore.sharedDataStore.homeData?.totalPages)! - 1)
            {
                return UIView()
            }
            else
            {
                let footerCell = tableView.dequeueReusableCell(withIdentifier: baseFooterTableViewCellIdentifier) as! JCBaseTableViewFooterCell
                return footerCell
            }
        }
        else
        {
            return UIView()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 650
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
    {
        
        return false
    }
    
    
    func callWebServiceForHomeData(page:Int)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        let url = homeDataUrl.appending(String(page))
        let homeDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: homeDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
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
        JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Home)
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.baseTableView.reloadData()
        }
    }
    
    func callWebServiceForResumeWatchData()
    {
        let url = resumeWatchGetUrl
        let params = ["uniqueId":JCAppUser.shared.unique]
        let resumeWatchDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: resumeWatchDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateResumeWatchData(dictionaryResponseData: responseData)
                DispatchQueue.main.async {
                    self.isResumeWatchDataAvailable = false
                    if let resumeItems = JCDataStore.sharedDataStore.resumeWatchList?.data?.items{
                        if resumeItems.count > 0{
                            self.isResumeWatchDataAvailable = true
                        }
                        self.baseTableView.reloadData()
                    }
                }
                return
            }
        }
    }
    
    func evaluateResumeWatchData(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .ResumeWatchList)
        JCDataStore.sharedDataStore.resumeWatchList?.data?.title = "Resume Watching"
        /*
        weak var weakSelf = self
        if (JCDataStore.sharedDataStore.resumeWatchList?.data?.items?.count)! > 0
        {
            isResumeWatchDataAvailable = true
            
            DispatchQueue.main.async {
                let visibleCell = weakSelf?.baseTableView.visibleCells
                if (weakSelf?.isFirstLoaded)! {
                    weakSelf?.isFirstLoaded = false
                    weakSelf?.baseTableView.reloadData()
                   // weakSelf?.isFirstLoaded = false
                }
                else
                {
                    for visible in visibleCell!
                    {
                        let visibleIndex = weakSelf?.baseTableView.indexPath(for: visible)
                        if visibleIndex?.row == 0
                        {
                            let resumeCell = weakSelf?.baseTableView.cellForRow(at: visibleIndex!) as! JCBaseTableViewCell
                            if resumeCell.isResumeWatchCell {
                                resumeCell.data = JCDataStore.sharedDataStore.resumeWatchList?.data?.items
                                resumeCell.tableCellCollectionView.reloadData()
                            }
                            else
                            {
                                weakSelf?.baseTableView.reloadData()
                            }
                            
                            break
                        }
                    }
                }

            }
        }
        else{
            if (self.isFirstLoaded) {
                //weakSelf?.isFirstLoaded = false
                DispatchQueue.main.async {
                    self.baseTableView.reloadData()
                }
                self.isFirstLoaded = false
            }
        }
 */
    }
    
    func callResumeWatchWebServiceOnPlayerDismiss()
    {
        //callWebServiceForResumeWatchData()
    }
        
    //ChangingTheAlpha
    var uiviewCarousel: UIView? = nil
    var focusShiftedFromTabBarToVC = true
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        //ChangingTheAlpha when focus shifted from tab bar item to view controller view
        if focusShiftedFromTabBarToVC{
            focusShiftedFromTabBarToVC = false
            if let cells = baseTableView.visibleCells as? [JCBaseTableViewCell]{
                for cell in cells{
                    if cell != cells.first {
                        cell.tableCellCollectionView.alpha = 0.5
                    }
                }
                if cells.count < 3{
                    cells.first?.tableCellCollectionView.alpha = 0.5
                }
                
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //ChangingTheAlpha when tab bar item selected
        focusShiftedFromTabBarToVC = true
        if let headerViewOfTableSection = uiviewCarousel as? InfinityScrollView{
            headerViewOfTableSection.middleButton.alpha = 1
        }
        for each in (self.baseTableView.visibleCells as? [JCBaseTableViewCell])!{
            each.tableCellCollectionView.alpha = 1
        }
    }
    
    
    //TBC
    func callWebServiceForLanguageList()
    {
        let url = languageListUrl
        let languageListRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        //dispatchGroup.enter()
        RJILApiManager.defaultManager.post(request: languageListRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            
            if let responseData = data
            {
                weakSelf?.evaluateLanguageList(dictionaryResponseData: responseData)
                DispatchQueue.main.async {
                    if let languageData = JCDataStore.sharedDataStore.languageData?.data{
                        if languageData.count > 0{
                            self.isLanguageDataAvailable = true
                            self.baseTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func evaluateLanguageList(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Language)
        JCDataStore.sharedDataStore.languageData?.data?[0].title = "Languages"
        
    }
    
    func callWebServiceForGenreList()
    {
        let url = genreListUrl
        let genreListRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: genreListRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                //weakSelf?.dispatchGroup.leave()
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateGenreList(dictionaryResponseData: responseData)
                //weakSelf?.dispatchGroup.leave()
                DispatchQueue.main.async {
                    if let genreData = JCDataStore.sharedDataStore.genreData?.data{
                        if genreData.count > 0{
                            self.isGenereDataAvailable = true
                            self.baseTableView.reloadData()
                        }
                        }
                }
            }
        }
    }
    
    func evaluateGenreList(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Genre)
        JCDataStore.sharedDataStore.genreData?.data?[0].title = "Genres"
        
    }
    
    
    
}



















