//
//  JCMoviesVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCMoviesVC:JCBaseVC,UITableViewDataSource,UITableViewDelegate, UITabBarControllerDelegate
{
    var loadedPage = 0
    var isMoviesWatchlistAvailable = false
    var dataItemsForTableview = [DataContainer]()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        callWebServiceForMoviesData(page: loadedPage)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        screenDisAppearTime = Date().timeIntervalSince(screenAppearTime)
        
        //Clevertap Navigation Event
        let eventProperties = ["Screen Name":"Movies","Platform":"TVOS","Metadata Page":""]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        Utility.sharedInstance.handleScreenNavigation(screenName: "Movies")
        screenAppearTime = Date()

        self.tabBarController?.delegate = self
        if JCDataStore.sharedDataStore.moviesData?.data == nil
        {
            callWebServiceForMoviesData(page: loadedPage)
        }
        if JCLoginManager.sharedInstance.isUserLoggedIn()
        {
            self.callWebServiceForMoviesWatchlist()
        }
        else
        {
            isMoviesWatchlistAvailable = false
        }
        baseTableView.reloadData()
        
//        //Clevertap Navigation Event
//        let eventProperties = ["Screen Name":"Movies","Platform":"TVOS","Metadata Page":""]
//        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
//        Utility.sharedInstance.handleScreenNavigation(screenName: "Movies")
    }
    override func viewDidDisappear(_ animated: Bool) {
        //screenDisAppearTime = Date().timeIntervalSince(screenAppearTime)

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
    
        //dataItemsForTableview.removeAll()
        if (JCDataStore.sharedDataStore.moviesData?.data) != nil
        {
            changingDataSourceForBaseTableView()
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
        cell.itemFromViewController = VideoType.Movie
        cell.categoryTitleLabel.tag = indexPath.row + 500000

        cell.data = dataItemsForTableview[indexPath.row].items
        cell.categoryTitleLabel.text = dataItemsForTableview[indexPath.row].title
        cell.tableCellCollectionView.reloadData()
        if(indexPath.row == (JCDataStore.sharedDataStore.moviesData?.data?.count)! - 2)
        {
            if(loadedPage < (JCDataStore.sharedDataStore.moviesData?.totalPages)! - 1)
            {
                callWebServiceForMoviesData(page: loadedPage + 1)
                loadedPage += 1
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(JCDataStore.sharedDataStore.moviesData?.data?[0].isCarousal == true)
        {
            //For autorotate carousel
            let carouselViews = Bundle.main.loadNibNamed("kInfinityScrollView", owner: self, options: nil)
            let carouselView = carouselViews?.first as! InfinityScrollView
            if let items = (JCDataStore.sharedDataStore.moviesData?.data?[0].items){
                carouselView.carouselArray = items
                    carouselView.loadViews()
                uiviewCarousel = carouselView
                selectedItemFromViewController = VideoType.Movie
                collectionIndex = 0
                return carouselView
            }
           
        }
            return UIView()
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if(JCDataStore.sharedDataStore.moviesData?.data?[0].isCarousal == true)
        {
            return CGFloat(heightOfCarouselSection)
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (JCDataStore.sharedDataStore.moviesData?.totalPages) == nil
        {
            return UIView()
        }
        else
        {
            if(loadedPage == (JCDataStore.sharedDataStore.moviesData?.totalPages)! - 1)
            {
                return UIView()
            }
            else
            {
                let footerCell = tableView.dequeueReusableCell(withIdentifier: baseFooterTableViewCellIdentifier) as! JCBaseTableViewFooterCell
                return footerCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 650
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func changingDataSourceForBaseTableView(){
        dataItemsForTableview.removeAll()
        if (JCDataStore.sharedDataStore.moviesData?.data) != nil
        {
            if !JCLoginManager.sharedInstance.isUserLoggedIn()
            {
                isMoviesWatchlistAvailable = false
            }
            dataItemsForTableview = (JCDataStore.sharedDataStore.moviesData?.data)!
            if let isCarousal = dataItemsForTableview[0].isCarousal {
                if isCarousal{
                    dataItemsForTableview.remove(at: 0)
                }
            }
            if isMoviesWatchlistAvailable{
                if let items = JCDataStore.sharedDataStore.moviesWatchList?.data?.items {
                    if items.count > 0 {
                        dataItemsForTableview.insert((JCDataStore.sharedDataStore.moviesWatchList?.data)!, at: 0)
                    }
                }
            }
        }
        
    }
    
    func callWebServiceForMoviesData(page:Int)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        let url = moviesDataUrl.appending(String(page))
        let moviesDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: moviesDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                //print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateMoviesData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateMoviesData(dictionaryResponseData responseData:Data)
    {
        //Success
        
        if(loadedPage == 0)
        {
            JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Movies)
            weak var weakSelf = self
            DispatchQueue.main.async {
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
            }
        }
        else
        {
            JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Movies)
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.baseTableView.reloadData()
            }
        }
    }
    
    func callWebServiceForMoviesWatchlist()
    {
        let url = moviesWatchListUrl
        let uniqueID = JCAppUser.shared.unique
        var params: Dictionary<String, Any> = [:]
        params["uniqueId"] = uniqueID
        let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: loginRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //print(responseError)
                return
            }
            
            if let responseData = data
            {
                
                DispatchQueue.main.async {
                    weakSelf?.evaluateMoviesWatchlistData(dictionaryResponseData: responseData)
                }
                return
            }
        }
        
    }
    
    func evaluateMoviesWatchlistData(dictionaryResponseData responseData:Data)
    {
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .MoviesWatchList)
        if (JCDataStore.sharedDataStore.moviesWatchList?.data?.items?.count)! > 0 {
            weak var weakSelf = self
            self.isMoviesWatchlistAvailable = true
             self.changingDataSourceForBaseTableView()
            DispatchQueue.main.async {
                
                JCDataStore.sharedDataStore.moviesWatchList?.data?.title = "Watch List"
                if weakSelf?.baseTableView != nil{
                    weakSelf?.baseTableView.reloadData()
                }
                
            }
        }
        
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
                if cells.count <= 2{
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
    
    
    
    
}
