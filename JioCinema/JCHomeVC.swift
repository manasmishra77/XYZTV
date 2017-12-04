//
//  JCHomeVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 12/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
class JCHomeVC: JCBaseVC, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, JCBaseTableViewCellDelegate, JCCarouselCellDelegate
{
    var loadedPage = 0
    var isResumeWatchDataAvailable = false
    var isLanguageDataAvailable = false
    var isGenereDataAvailable = false
    var isFirstLoaded = false
    var dataItemsForTableview = [DataContainer]()
    fileprivate var screenAppearTiming = Date()

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
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        //Clevertap screen viewed event
        let eventProperties = ["Screen Viewed": "Home", "Platform": "TVOS"]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Screen View", properties: eventProperties)
        
        
        // Do any additional setup after loading the view.
        callWebServiceForLanguageList()
        callWebServiceForGenreList()
        if JCLoginManager.sharedInstance.isUserLoggedIn()
        {
            callWebServiceForResumeWatchData()
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        Utility.sharedInstance.handleScreenNavigation(screenName: HOME_SCREEN, toScreen: "", duration: Int(Date().timeIntervalSince(screenAppearTiming)))
        
    }
    override func viewDidAppear(_ animated: Bool)
    {
        screenAppearTiming = Date()
        
        self.tabBarController?.delegate = self
        if !JCLoginManager.sharedInstance.isUserLoggedIn(), isResumeWatchDataAvailable{
            isResumeWatchDataAvailable = false
            dataItemsForTableview.remove(at: 0)
            baseTableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        //Clevertap Navigation Event
        let eventProperties = ["Screen Name": "Home", "Platform": "TVOS", "Metadata Page": ""]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        
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
                let pos = (JCDataStore.sharedDataStore.configData?.configDataUrls?.languagePosition)  ?? 4
                if let languageData = JCDataStore.sharedDataStore.languageData?.data?[0]
                {
                    if pos < dataItemsForTableview.count{
                        dataItemsForTableview.insert(languageData, at: pos)
                    }
                    
                }
            }
            if isGenereDataAvailable{
                let pos = (JCDataStore.sharedDataStore.configData?.configDataUrls?.genrePosition) ?? 6
                if let genreData = JCDataStore.sharedDataStore.genreData?.data?[0]{
                    if pos < dataItemsForTableview.count{
                        dataItemsForTableview.insert(genreData, at: pos)
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
        cell.cellDelgate = self
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
        carouselView.carouselDelegate = self
        uiviewCarousel = carouselView
//        selectedItemFromViewController = VideoType.Home
//        collectionIndex = 0
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
                if cells.count < 2{
                    cells.first?.tableCellCollectionView.alpha = 0.5
                }else{
                    if let headerViewOfTableSection = uiviewCarousel as? InfinityScrollView{
                        headerViewOfTableSection.middleButton.alpha = 0.5
                    }
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
        //Making tab bar delegate searchvc
        if let searchNavVC = tabBarController.selectedViewController as? UINavigationController, let svc = searchNavVC.viewControllers[0] as? UISearchContainerViewController{
            if let searchVc = svc.searchController.searchResultsController as? JCSearchVC{
                tabBarController.delegate = searchVc
            }
        }
    }
    
    
    //TBC
    func callWebServiceForLanguageList()
    {
        let url = languageListUrl
        print(url)
        let languageListRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        //dispatchGroup.enter()
        RJILApiManager.defaultManager.get(request: languageListRequest) { (data, response, error) in
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
        RJILApiManager.defaultManager.get(request: genreListRequest) { (data, response, error) in
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
    
    //MARK:- JCBaseTableCell Delegate Methods
    func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int) {
        if let tappedItem = item as? Item{
            let categoryName = baseCell?.categoryTitleLabel.text ?? "Carousel"
            print(tappedItem)
            if tappedItem.app?.type == VideoType.Home.rawValue{
                print("At Home")
            }
            else if tappedItem.app?.type == VideoType.Music.rawValue{
                print("At Music")
                checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
            }
            else if tappedItem.app?.type == VideoType.Movie.rawValue{
                print("At Movie")
                let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .Movie, fromScreen: HOME_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 0)
                self.present(metadataVC, animated: true, completion: nil)
            }
            else if tappedItem.app?.type == VideoType.TVShow.rawValue{
                print("At TvShow")
                if tappedItem.duration != nil, let drn = Float(tappedItem.duration!){
                    if drn > 0{
                        tappedItem.app?.type = VideoType.Episode.rawValue
                        checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
                    }else{
                        let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .TVShow, fromScreen: HOME_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 0)
                        self.present(metadataVC, animated: true, completion: nil)
                    }
                }else{
                    let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .TVShow, fromScreen: HOME_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 0)
                    self.present(metadataVC, animated: true, completion: nil)
                }
            }
            else if tappedItem.app?.type == VideoType.Episode.rawValue{
                print("At Episode")
                checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
            }
            else if tappedItem.app?.type == VideoType.Clip.rawValue{
                print("At Clip")
                checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
            }
            else if tappedItem.app?.type == VideoType.Trailer.rawValue{
                print("At Trailer")
               checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
            }
            else if tappedItem.app?.type == VideoType.Language.rawValue{
                print("At Language")
                presentLanguageGenreController(item: tappedItem)
            }
            else if tappedItem.app?.type == VideoType.Genre.rawValue{
                print("At Genre")
                presentLanguageGenreController(item: tappedItem)
            }
            else if tappedItem.app?.type == VideoType.Search.rawValue{
                print("At Search")
            }
        }
    }
    
    //MARK:- JCCarouselCell Delegate Methods
    func didTapOnCarouselItem(_ item: Any?) {
        didTapOnItemCell(nil, item, 0)
    }
    
    //For after login function
    fileprivate var itemAfterLogin: Item? = nil
    fileprivate var categoryIndexAfterLogin: Int? = nil
    fileprivate var categoryNameAfterLogin: String? = nil
    
    func checkLoginAndPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int) {
        //weak var weakSelf = self
        if(JCLoginManager.sharedInstance.isUserLoggedIn())
        {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            prepareToPlay(itemToBePlayed, categoryName: categoryName, categoryIndex: categoryIndex)
        }
        else
        {
            self.itemAfterLogin = itemToBePlayed
            self.categoryNameAfterLogin = categoryName
            self.categoryIndexAfterLogin = categoryIndex
            presentLoginVC()
        }
    }
    
    func playItemAfterLogin() {
        checkLoginAndPlay(itemAfterLogin!, categoryName: categoryNameAfterLogin!, categoryIndex: categoryIndexAfterLogin!)
        self.itemAfterLogin = nil
        self.categoryIndexAfterLogin = nil
        self.categoryNameAfterLogin = nil
    }
    
    func prepareToPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int)
    {
        if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt){
            if appType == .Clip || appType == .Music || appType == .Trailer{
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: HOME_SCREEN, fromCategory: "", fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            }
            else if appType == .Episode{
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: HOME_SCREEN, fromCategory: categoryName, fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "")
                
                self.present(playerVC, animated: true, completion: nil)
            }
        }  
    }
    
    func presentLoginVC()
    {
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func presentLanguageGenreController(item: Item)
    {
        let languageGenreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreStoryBoardId) as! JCLanguageGenreVC
        languageGenreVC.item = item
        self.present(languageGenreVC, animated: false, completion: nil)
        
    }
   
}



