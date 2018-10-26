//
//  JCMoviesVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import Crashlytics

class JCMoviesVC: JCBaseVC,UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, JCBaseTableViewCellDelegate, JCCarouselCellDelegate {
    var loadedPage = 0
    var isMoviesWatchlistAvailable = false
    var dataItemsForTableview = [DataContainer]()
    fileprivate var screenAppearTiming = Date()
    fileprivate var toScreenName: String? = nil
    fileprivate var carousalView: InfinityScrollView?
    fileprivate var footerView: JCBaseTableViewFooterView?
    fileprivate var isMovieDataBeingCalled = false
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //callWebServiceForMoviesData(page: loadedPage)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        if JCDataStore.sharedDataStore.moviesData?.data == nil {
            callWebServiceForMoviesData(page: loadedPage)
        }
        if JCLoginManager.sharedInstance.isUserLoggedIn() {
            self.callWebServiceForMoviesWatchlist()
        } else {
            isMoviesWatchlistAvailable = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if JCDataStore.sharedDataStore.moviesData?.data == nil
        {
            //callWebServiceForMoviesData(page: loadedPage)
        }
        self.tabBarController?.delegate = self
        //Clevertap Navigation Event
        let eventProperties = ["Screen Name": "Movies", "Platform": "TVOS", "Metadata Page": ""]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        screenAppearTiming = Date()
        
        //Removing watchlist when user loggedout
        if !JCLoginManager.sharedInstance.isUserLoggedIn(), isMoviesWatchlistAvailable {
            isMoviesWatchlistAvailable = false
            dataItemsForTableview.remove(at: 0)
            baseTableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        if let toScreen = toScreenName {
            Utility.sharedInstance.handleScreenNavigation(screenName: MOVIE_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
            toScreenName = nil
        } else {
            let toScreen = self.tabBarController?.selectedViewController?.tabBarItem.title ?? ""
            Utility.sharedInstance.handleScreenNavigation(screenName: MOVIE_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("In Movie Screen Deinit")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeightForPotrait
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
    
        //dataItemsForTableview.removeAll()
        if (JCDataStore.sharedDataStore.moviesData?.data) != nil {
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

        cell.itemsArray = dataItemsForTableview[indexPath.row].items
        let categoryTitle = (dataItemsForTableview[indexPath.row].title ?? "")
        cell.categoryTitleLabel.text = categoryTitle
        cell.tableCellCollectionView.reloadData()
        cell.cellDelgate = self
        cell.tag = indexPath.row
        
        //Pagination call
        if(indexPath.row == (JCDataStore.sharedDataStore.moviesData?.data?.count)! - 2) {
            if(loadedPage < (JCDataStore.sharedDataStore.moviesData?.totalPages)!) {
                callWebServiceForMoviesData(page: loadedPage)
            }
        }
        return cell
        
    }
    
  
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //For autorotate carousel
        if carousalView == nil {
            if let items = JCDataStore.sharedDataStore.moviesData?.data?[0].items {
                carousalView = Utility.getHeaderForTableView(for: self, with: items)
            }
        }
        return carousalView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (JCDataStore.sharedDataStore.moviesData?.data?[0].isCarousal ?? false), let carouselItems = JCDataStore.sharedDataStore.moviesData?.data?[0].items, carouselItems.count > 0 {
            return 650
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Utility.getFooterHeight(JCDataStore.sharedDataStore.moviesData, loadedPage: loadedPage)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if footerView == nil {
            footerView = Utility.getFooterForTableView(for: self)
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        Utility.baseTableView(tableView, didUpdateFocusIn: context, with: coordinator)
    }
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func changingDataSourceForBaseTableView() {
        dataItemsForTableview.removeAll()
        if let moviesData = JCDataStore.sharedDataStore.moviesData?.data {
            if !JCLoginManager.sharedInstance.isUserLoggedIn() {
                isMoviesWatchlistAvailable = false
            }
            dataItemsForTableview = moviesData
            if dataItemsForTableview[0].isCarousal ?? false {
                dataItemsForTableview.remove(at: 0)
            }
            if isMoviesWatchlistAvailable {
                if let watchListData = JCDataStore.sharedDataStore.moviesWatchList?.data?[0], (watchListData.items?.count ?? 0) > 0 {
                    dataItemsForTableview.insert(watchListData, at: 0)
                }
            }
        }
        
    }
    
    func callWebServiceForMoviesData(page: Int) {
        
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        if isMovieDataBeingCalled {
            return
        }
        isMovieDataBeingCalled = true
        RJILApiManager.getBaseModel(pageNum: page, type: .movie) {[unowned self] (isSuccess, erroMsg) in
            guard isSuccess else {
                self.isMovieDataBeingCalled = false
                return
            }
            //Success
            if(self.loadedPage == 0) {
                DispatchQueue.main.async {
                    self.loadedPage += 1
                    self.activityIndicator.isHidden = true
                    self.baseTableView.reloadData()
                    self.baseTableView.layoutIfNeeded()
                    self.isMovieDataBeingCalled = false
                }
            } else {
                DispatchQueue.main.async {
                    self.loadedPage += 1
                    self.activityIndicator.isHidden = true
                    self.baseTableView.reloadData()
                    self.baseTableView.layoutIfNeeded()
                    self.isMovieDataBeingCalled = false
                }
            }
        }
        /*
        let url = moviesDataUrl.appending(String(page))
        let moviesDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: moviesDataRequest) { (data, response, error) in
           
            if let responseError = error {
                //TODO: handle error
                print(responseError)
                DispatchQueue.main.async {
                    weakSelf?.handleAlertForMoviesDataFailure()
                     weakSelf?.isMovieDataBeingCalled = false
                }
                return
            }
            if let responseData = data {
                weakSelf?.evaluateMoviesData(dictionaryResponseData: responseData)
                return
            }
        }*/
    }
    
    func handleAlertForMoviesDataFailure() {
        let action = Utility.AlertAction(title: "Dismiss", style: .default)
        let alertVC = Utility.getCustomizedAlertController(with: "Server Error!", message: "", actions: [action]) { (alertAction) in
            if alertAction.title == action.title {
                //self.tabBarController?.selectedIndex = 2
            }
        }
        present(alertVC, animated: false) {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    
    func evaluateMoviesData(dictionaryResponseData responseData:Data)
    {
        //Success
        
        if(loadedPage == 0)
        {
            weak var weakSelf = self
            DispatchQueue.main.async {
        
                JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Movies)
                super.activityIndicator.isHidden = true
                weakSelf?.loadedPage += 1
                weakSelf?.baseTableView.reloadData()
               weakSelf?.baseTableView.layoutIfNeeded()
                 weakSelf?.isMovieDataBeingCalled = false
                
            }
        }
        else
        {
            weak var weakSelf = self
            DispatchQueue.main.async {
                JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Movies)
                 weakSelf?.loadedPage += 1
                weakSelf?.baseTableView.reloadData()
               weakSelf?.baseTableView.layoutIfNeeded()
                 weakSelf?.isMovieDataBeingCalled = false
               
            }
        }
    }
    
    func callWebServiceForMoviesWatchlist()
    {
        RJILApiManager.getWatchListData(isDisney : false ,type: .movie) {[unowned self] (isSuccess, errorMsg) in
            guard isSuccess else {
                return
            }
            if (JCDataStore.sharedDataStore.moviesWatchList?.data?[0].items?.count ?? 0) > 0 {
                self.isMoviesWatchlistAvailable = true
                self.changingDataSourceForBaseTableView()
                DispatchQueue.main.async {
                    JCDataStore.sharedDataStore.moviesWatchList?.data?[0].title = "Watch List"
                    if self.baseTableView != nil{
                        self.baseTableView.reloadData()
                        self.baseTableView.layoutIfNeeded()
                    }
                }
            }  else if JCDataStore.sharedDataStore.moviesWatchList?.data?[0].items?.count == nil {
                self.isMoviesWatchlistAvailable = false
                DispatchQueue.main.async {
                    self.baseTableView?.reloadData()
                }
            }
            
        }
        /*
        let url = moviesWatchListUrl
        let uniqueID = JCAppUser.shared.unique
        var params: Dictionary<String, Any> = [:]
        params["uniqueId"] = uniqueID
        let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: loginRequest) { (data, response, error) in
            if let responseError = error as NSError?
            {
                //TODO: handle error
                print(responseError)
                
                //Refresh sso token call fails
                if responseError.code == 143{
                    print("Refresh sso token call fails")
                    DispatchQueue.main.async {
                        //JCLoginManager.sharedInstance.logoutUser()
                        //self.presentLoginVC()
                    }
                }
                return
            }
            
            if let responseData = data
            {
                
                DispatchQueue.main.async {
                    weakSelf?.evaluateMoviesWatchlistData(dictionaryResponseData: responseData)
                }
                return
            }
        }*/
    }
    /*
    func evaluateMoviesWatchlistData(dictionaryResponseData responseData:Data)
    {
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .MoviesWatchList)
        if (JCDataStore.sharedDataStore.moviesWatchList?.data?[0].items?.count)! > 0 {
            weak var weakSelf = self
            self.isMoviesWatchlistAvailable = true
             self.changingDataSourceForBaseTableView()
            DispatchQueue.main.async {
                JCDataStore.sharedDataStore.moviesWatchList?.data?.title = "Watch List"
                if weakSelf?.baseTableView != nil{
                    weakSelf?.baseTableView.reloadData()
                    weakSelf?.baseTableView.layoutIfNeeded()
                }
            }
        }
    }*/
    
    //ChangingTheAlpha
    var focusShiftedFromTabBarToVC = true
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        Utility.changingAlphaTabAbrToVC(carousalView: carousalView, tableView: baseTableView, toChange: &focusShiftedFromTabBarToVC)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        Utility.changeAlphaWhenTabBarSelected(baseTableView, carousalView: carousalView, toChange: &focusShiftedFromTabBarToVC)
    }

    
    //MARK:- JCBaseTableCell Delegate Methods
    func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int) {
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: "", message: networkErrorMessage)
            return
        }
        if let tappedItem = item as? Item {
            //Screenview event to Google Analytics
            let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: MOVIE_SCREEN, action: VIDEO_ACTION, label: tappedItem.name, customParameters: customParams)
            
            let categoryName = baseCell?.categoryTitleLabel.text ?? "Carousel"
            print(tappedItem)
            if tappedItem.app?.type == VideoType.Movie.rawValue {
                print("At Movie")
                toScreenName = METADATA_SCREEN
                let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .Movie, fromScreen: MOVIE_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 1)
//                self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
//                self.tabBarController?.navigationController?.pushViewController(metadataVC, animated: false)
                self.present(metadataVC, animated: true, completion: nil)
            }
        }
    }
    //MARK:- Carousel Delegate Methods
    func didTapOnCarouselItem(_ item: Any?) {
       // Crashlytics.sharedInstance().crash()
        didTapOnItemCell(nil, item, 0)
    }
}
