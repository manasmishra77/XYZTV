//
//  JCTVVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCTVVC: JCBaseVC,UITableViewDelegate,UITableViewDataSource, UITabBarControllerDelegate, JCBaseTableViewCellDelegate, JCCarouselCellDelegate
{

    var loadedPage = 0
    var isTVWatchlistAvailable = false
    var dataItemsForTableview = [DataContainer]()
    fileprivate var screenAppearTiming = Date()
    fileprivate var toScreenName: String?
    fileprivate var carousalView: InfinityScrollView?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        callWebServiceForTVData(page: loadedPage)
        
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        if JCLoginManager.sharedInstance.isUserLoggedIn() {
            self.callWebServiceForTVWatchlist()
        } else {
            isTVWatchlistAvailable = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        screenAppearTiming = Date()

        self.tabBarController?.delegate = self
        
        //Clevertap Navigation Event
        let eventProperties = ["Screen Name": "TV", "Platform": "TVOS", "Metadata Page": ""]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        
        //Removing watchlist when user loggedout
        if !JCLoginManager.sharedInstance.isUserLoggedIn(), isTVWatchlistAvailable{
            isTVWatchlistAvailable = false
            dataItemsForTableview.remove(at: 0)
            baseTableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        if let toScreen = toScreenName {
            Utility.sharedInstance.handleScreenNavigation(screenName: TV_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
            toScreenName = nil
        } else {
            let toScreen = self.tabBarController?.selectedViewController?.tabBarItem.title ?? ""
            Utility.sharedInstance.handleScreenNavigation(screenName: TV_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
        }
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
        if (JCDataStore.sharedDataStore.tvData?.data) != nil {
           changingDataSourceForBaseTableView()
            return dataItemsForTableview.count
        }
        else
        {
            return 0
        }
        
    }
    func changingDataSourceForBaseTableView(){
        dataItemsForTableview.removeAll()
        if let tvData = JCDataStore.sharedDataStore.tvData?.data {
            if !JCLoginManager.sharedInstance.isUserLoggedIn() {
                isTVWatchlistAvailable = false
            }
            dataItemsForTableview = tvData
            if dataItemsForTableview[0].isCarousal ?? false {
                dataItemsForTableview.remove(at: 0)
            }
            if isTVWatchlistAvailable{
                if let watchListData = JCDataStore.sharedDataStore.tvWatchList?.data, (watchListData.items?.count ?? 0) > 0 {
                    dataItemsForTableview.insert(watchListData, at: 0)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.tableCellCollectionView.tag = indexPath.row
        cell.itemFromViewController = VideoType.TVShow
        
        cell.data = dataItemsForTableview[indexPath.row].items
        let categoryTitle = (dataItemsForTableview[indexPath.row].title ?? "")
        cell.categoryTitleLabel.text = categoryTitle
        cell.tableCellCollectionView.reloadData()
        cell.cellDelgate = self
        cell.tag = indexPath.row
        if(indexPath.row == (JCDataStore.sharedDataStore.tvData?.data?.count)! - 2) {
            if(loadedPage < (JCDataStore.sharedDataStore.tvData?.totalPages)! - 1)
            {
                callWebServiceForTVData(page: loadedPage + 1)
                loadedPage += 1
            }
        }
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //For autorotate carousel
        if carousalView == nil {
            if let items = JCDataStore.sharedDataStore.tvData?.data?[0].items {
                carousalView = Utility.getHeaderForTableView(for: self, with: items)
            }
        }
        return carousalView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (JCDataStore.sharedDataStore.tvData?.data?[0].isCarousal ?? false), let carouselItems = JCDataStore.sharedDataStore.tvData?.data?[0].items, carouselItems.count > 0 {
            return 650
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
        if (JCDataStore.sharedDataStore.tvData?.totalPages) == nil
        {
            return UIView.init()
        }
        else
        {
            if(loadedPage == (JCDataStore.sharedDataStore.tvData?.totalPages)! - 1)
            {
                return UIView.init()
            }
            else
            {
                let footerCell = tableView.dequeueReusableCell(withIdentifier: baseFooterTableViewCellIdentifier) as! JCBaseTableViewFooterCell
                return footerCell
            }
        }
    }

    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func callWebServiceForTVData(page:Int)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        let url = tvDataUrl.appending(String(page))
        let tvDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: tvDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateTVData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateTVData(dictionaryResponseData responseData:Data)
    {
        //Success
        
        if(loadedPage == 0) {
            JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .TV)
            weak var weakSelf = self
            DispatchQueue.main.async {
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
            }
        }  else {
            JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .TV)
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.baseTableView.reloadData()
            }
        }
    }

    func callWebServiceForTVWatchlist()
    {
        let url = tvWatchListUrl
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
                    weakSelf?.evaluateTVWatchlistData(dictionaryResponseData: responseData)
                }
                return
            }
        }
    }
    
    func evaluateTVWatchlistData(dictionaryResponseData responseData:Data)
    {
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .TVWatchList)
        if (JCDataStore.sharedDataStore.tvWatchList?.data?.items?.count)! > 0 {
            weak var weakSelf = self
            weakSelf?.isTVWatchlistAvailable = true
            weakSelf?.changingDataSourceForBaseTableView()
            DispatchQueue.main.async {
                JCDataStore.sharedDataStore.tvWatchList?.data?.title = "Watch List"
                if weakSelf?.baseTableView != nil{
                    weakSelf?.baseTableView.reloadData()
                }
            }
        }
    }
    
    //ChangingTheAlpha
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
        if let headerViewOfTableSection = carousalView {
            headerViewOfTableSection.middleButton.alpha = 1
        }
        for each in (self.baseTableView.visibleCells as? [JCBaseTableViewCell])!{
            each.tableCellCollectionView.alpha = 1
        }
    }
    
    //MARK:- JCBaseTableCell Delegate Methods

    func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int) {
        if let tappedItem = item as? Item{
            
            //Screenview event to Google Analytics
            let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: TV_SCREEN, action: VIDEO_ACTION, label: tappedItem.name, customParameters: customParams)
            
            print(tappedItem)
            if tappedItem.app?.type == VideoType.TVShow.rawValue{
                print("At Tvshow")
                toScreenName = METADATA_SCREEN
                let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .TVShow, fromScreen: TV_SCREEN, categoryName: (baseCell?.categoryTitleLabel.text!)!, categoryIndex: indexFromArray, tabBarIndex: 1)
                self.present(metadataVC, animated: true, completion: nil)
            }
        }
    }
    
    func didTapOnCarouselItem(_ item: Any?) {
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        if let tappedItem = item as? Item {
            //Screenview event to Google Analytics
            let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: TV_SCREEN, action: VIDEO_ACTION, label: tappedItem.name, customParameters: customParams)
            
            if tappedItem.app?.type == VideoType.TVShow.rawValue{
                print("At TvShow")
                let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .TVShow, fromScreen: HOME_SCREEN, categoryName: "Carousel", categoryIndex: 0, tabBarIndex: 1)
                self.present(metadataVC, animated: true, completion: nil)
            }
        }
    }

}
