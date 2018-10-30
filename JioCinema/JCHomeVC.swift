//
//  JCHomeVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 12/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
class JCHomeVC: JCBaseVC, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, JCBaseTableViewCellDelegate, JCCarouselCellDelegate {
    var isResumeWatchRowReloadNeeded = false
    var loadedPage = 1
    var isResumeWatchDataAvailable = false
    var isLanguageDataAvailable = false
    var isGenereDataAvailable = false
    var isFirstLoaded = false
    var isUserRecommendationAvailable = false
    var dataItemsForTableview = [DataContainer]()
    
    var isMetadataScreenToBePresentedFromResumeWatchCategory = false
    
    fileprivate var screenAppearTiming = Date()
    fileprivate var toScreenName: String? = nil
    fileprivate var carousalView: InfinityScrollView?
    fileprivate var footerView: JCBaseTableViewFooterView?
    fileprivate var isHomeDatabeingCalled = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        isFirstLoaded = true
        super.activityIndicator.isHidden = true
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        //Clevertap screen viewed event
        let eventProperties = ["Screen Viewed": "Home", "Platform": "TVOS"]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Screen View", properties: eventProperties)
        
        // Do any additional setup after loading the view.
        callWebServiceForLanguageList()
        callWebServiceForGenreList()
        callWebServiceForUserRecommendationList()
        if JCLoginManager.sharedInstance.isUserLoggedIn() {
            callWebServiceForResumeWatchData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadResumeWathcData),name: resumeWatchReloadNotification,object: nil)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (ParentalPinManager.shouldShowFirstTimeParentalControlAlert) {
            handleAlertForFirstTimeLaunchParentalControl()
        }
        if isMetadataScreenToBePresentedFromResumeWatchCategory {
            isMetadataScreenToBePresentedFromResumeWatchCategory = false
            super.activityIndicator.isHidden = false
            self.baseTableView.isHidden = true
            super.activityIndicator.startAnimating()
        } else {
            super.activityIndicator.isHidden = true
            self.baseTableView.isHidden = false
            super.activityIndicator.stopAnimating()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let toScreen = toScreenName {
            Utility.sharedInstance.handleScreenNavigation(screenName: HOME_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
            toScreenName = nil
        } else {
            let toScreen = self.tabBarController?.selectedViewController?.tabBarItem.title ?? ""
            Utility.sharedInstance.handleScreenNavigation(screenName: HOME_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenAppearTiming = Date()
        self.tabBarController?.delegate = self
        if !JCLoginManager.sharedInstance.isUserLoggedIn(), isResumeWatchDataAvailable {
            isResumeWatchDataAvailable = false
            isUserRecommendationAvailable = false
            baseTableView.reloadData()
        }
        
        //Clevertap Navigation Event
        let eventProperties = ["Screen Name": "Home", "Platform": "TVOS", "Metadata Page": ""]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func hideTableView() {
        self.baseTableView.isHidden = !self.baseTableView.isHidden
    }
    //MARK: Top Shelf interatcion
    func handleTopShelfCalls() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if let modal = delegate.topShelfContentModel {
            let videoType = Utility.checkType(modal.type ?? "")
            switch videoType{
                case .Movie,.TVShow :
                    let metadataVC = Utility.sharedInstance.prepareMetadata(modal.contentId ?? "", appType: videoType, fromScreen: TVOS_HOME_SCREEN_CAROUSEL, categoryName: TVOS_HOME_SCREEN_CAROUSEL, categoryIndex: 0, tabBarIndex: 0)
                    self.present(metadataVC, animated: true, completion: nil)
                case .Music,.Trailer,.Clip :
                    let tappedItem = Item()
                    tappedItem.id = modal.contentId
                    let app = App()
                    app.type = videoType.rawValue
                    tappedItem.app = app
                    checkLoginAndPlay(tappedItem, categoryName: TVOS_HOME_SCREEN_CAROUSEL, categoryIndex: 0)
                default:
                print(videoType.name)
           
            }
            delegate.topShelfContentModel = nil
            self.perform(#selector(JCHomeVC.hideTableView), with: nil, afterDelay: 1.0)
        } else {
            baseTableView.isHidden = false
        }
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
            if isUserRecommendationAvailable{
                if let recommendationDataArray = JCDataStore.sharedDataStore.userRecommendationList?.data {
                    var i = 0
                    for recommendationData in recommendationDataArray {
                        let pos = recommendationData.position ?? 4+i
                        if pos < dataItemsForTableview.count {
                            dataItemsForTableview.insert(recommendationData, at: pos)
                        }
                        i = i + 1
                    }
                }
            }
            if isLanguageDataAvailable {
                let pos = (JCDataStore.sharedDataStore.configData?.configDataUrls?.languagePosition) ?? 4
                if let languageData = JCDataStore.sharedDataStore.languageData?.data?[0] {
                    if pos < dataItemsForTableview.count {
                        dataItemsForTableview.insert(languageData, at: pos)
                    }
                }
            }
            if isGenereDataAvailable {
                let pos = (JCDataStore.sharedDataStore.configData?.configDataUrls?.genrePosition) ?? 6
                if let genreData = JCDataStore.sharedDataStore.genreData?.data?[0] {
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
        cell.tag = indexPath.row
        cell.isResumeWatchCell = false
        if isResumeWatchDataAvailable, indexPath.row == 0 {

            cell.itemArrayType = .resumeWatch
        } else {
            cell.itemArrayType = .item
        }
        //Added for multiple audio
        cell.defaultAudioLanguage = dataItemsForTableview[indexPath.row].defaultAudioLanguage
        cell.itemsArray = dataItemsForTableview[indexPath.row].items
        let categoryTitle = (dataItemsForTableview[indexPath.row].title ?? "")
        cell.categoryTitleLabel.text = categoryTitle
        cell.tableCellCollectionView.reloadData()
        

        //Pagination call
        if(indexPath.row == (JCDataStore.sharedDataStore.homeData?.data?.count)! - 2) {
            if(loadedPage < (JCDataStore.sharedDataStore.homeData?.totalPages)!) {
                callWebServiceForHomeData(page: loadedPage)
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //For autorotate carousel
        if carousalView == nil {
            if let items = JCDataStore.sharedDataStore.homeData?.data?[0].items {
                carousalView = Utility.getHeaderForTableView(for: self, with: items)
            }
        }
        return carousalView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (JCDataStore.sharedDataStore.homeData?.data?[0].isCarousal ?? false), let carouselItems = JCDataStore.sharedDataStore.homeData?.data?[0].items, carouselItems.count > 0 {
            return 650
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Utility.getFooterHeight(JCDataStore.sharedDataStore.homeData, loadedPage: loadedPage)
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
    
    
    func callWebServiceForHomeData(page: Int) {
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        if isHomeDatabeingCalled {
            return
        }
        isHomeDatabeingCalled = true
        
        let url = homeDataUrl.appending(String(page))
        let homeDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.get(request: homeDataRequest) { (data, response, error) in
            
            if let responseError = error {
                //TODO: handle error
                print(responseError)
                weakSelf?.isHomeDatabeingCalled = false
                return
            }
            if let responseData = data {
                weakSelf?.evaluateHomeData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateHomeData(dictionaryResponseData responseData:Data) {
        //Success
        JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Home)
        self.loadedPage += 1
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.baseTableView.reloadData()
            weakSelf?.baseTableView.layoutIfNeeded()
            weakSelf?.isHomeDatabeingCalled = false
            
        }
    }
    
    @objc func reloadResumeWathcData(notification: NotificationCenter) {
        self.callWebServiceForResumeWatchData()
    }

    func callWebServiceForResumeWatchData() {
        guard JCLoginManager.sharedInstance.isUserLoggedIn() else {
            isResumeWatchDataAvailable = false
            return
        }
        let url = resumeWatchGetUrl
        let params = ["uniqueId":JCAppUser.shared.unique]
        let resumeWatchDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: resumeWatchDataRequest) { (data, response, error) in
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
                weakSelf?.evaluateResumeWatchData(dictionaryResponseData: responseData)
                DispatchQueue.main.async {
                    self.isResumeWatchDataAvailable = false
                    if let resumeItems = JCDataStore.sharedDataStore.resumeWatchList?.data?.items, resumeItems.count > 0 {
                        weakSelf?.isResumeWatchDataAvailable = true
                    }
                    weakSelf?.baseTableView.reloadData()
                    weakSelf?.baseTableView.layoutIfNeeded()
                }
                return
            }
        }
    }
  
    
    func evaluateResumeWatchData(dictionaryResponseData responseData: Data) {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .ResumeWatchList)
        JCDataStore.sharedDataStore.resumeWatchList?.data?.title = "Resume Watching"
        
    }
    
    func callResumeWatchWebServiceOnPlayerDismiss() {
        //callWebServiceForResumeWatchData()
    }
    
    //ChangingTheAlpha
    var focusShiftedFromTabBarToVC = true
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        Utility.changingAlphaTabAbrToVC(carousalView: carousalView, tableView: baseTableView, toChange: &focusShiftedFromTabBarToVC)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        Utility.changeAlphaWhenTabBarSelected(baseTableView, carousalView: carousalView, toChange: &focusShiftedFromTabBarToVC)
    }

    
    
    //TBC
    func callWebServiceForLanguageList() {
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
                            weakSelf?.isLanguageDataAvailable = true
                            weakSelf?.baseTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func evaluateLanguageList(dictionaryResponseData responseData:Data) {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Language)
        JCDataStore.sharedDataStore.languageData?.data?[0].title = "Languages"
        
    }
    
    func callWebServiceForGenreList() {
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
            if let responseData = data {
                weakSelf?.evaluateGenreList(dictionaryResponseData: responseData)
                //weakSelf?.dispatchGroup.leave()
                DispatchQueue.main.async {
                    if let genreData = JCDataStore.sharedDataStore.genreData?.data{
                        if genreData.count > 0{
                            weakSelf?.isGenereDataAvailable = true
                            weakSelf?.baseTableView.reloadData()
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
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: "", message: networkErrorMessage)
            return
        }
        if let tappedItem = item as? Item {
            
            //Screenview event to Google Analytics
            let customParams: [String: String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: HOME_SCREEN, action: VIDEO_ACTION, label: tappedItem.name, customParameters: customParams)
            
            let categoryName = baseCell?.categoryTitleLabel.text ?? "Carousel"
            print(tappedItem)
            guard let itemAppType = VideoType(rawValue: tappedItem.app?.type ?? -111) else {
                return
            }
            switch itemAppType {
            case .Movie:
                print("At Movie")
                if let duration = tappedItem.duration?.floatValue(), duration > 0 {
                    checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
                } else {
                    toScreenName = METADATA_SCREEN
                    let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .Movie, fromScreen: HOME_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 0, defaultAudioLanguage: tappedItem.defaultAudioLanguage)
                    self.present(metadataVC, animated: false, completion: nil)
                }
            case .Music, .Episode, .Clip, .Trailer:
                checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
            case .TVShow:
                print("At TvShow")
                if let duration = tappedItem.duration?.floatValue(), duration > 0 {
                    tappedItem.app?.type = VideoType.Episode.rawValue
                    checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
                } else {
                    toScreenName = METADATA_SCREEN
                    let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .TVShow, fromScreen: HOME_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 0)
                    self.present(metadataVC, animated: true, completion: nil)
                }
            case .Genre, .Language:
                presentLanguageGenreController(item: tappedItem)
            default:
                print("Default")
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
    
    func prepareToPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int) {
        toScreenName = PLAYER_SCREEN
        if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt) {
            switch appType {
            case .Clip, .Music, .Trailer:
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: (categoryName == TVOS_HOME_SCREEN_CAROUSEL ? TVOS_HOME_SCREEN : HOME_SCREEN), fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            case .Episode:
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: HOME_SCREEN, fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "")
                
                self.present(playerVC, animated: true, completion: nil)
            case .Movie:
                print("Play Movie")
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, fromScreen: HOME_SCREEN, fromCategory: categoryName, fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "", audioLanguage : itemToBePlayed.languageIndex)
                self.present(playerVC, animated: true, completion: nil)
            default:
                print("No Item")
                toScreenName = nil
            }
        }
    }
    
    func presentLoginVC() {
        toScreenName = LOGIN_SCREEN
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func presentLanguageGenreController(item: Item) {
        toScreenName = LANGUAGE_SCREEN
        let languageGenreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreStoryBoardId) as! JCLanguageGenreVC
        languageGenreVC.item = item
        self.present(languageGenreVC, animated: false, completion: nil)
    }
    func callWebServiceForUserRecommendationList() {
        guard JCLoginManager.sharedInstance.isUserLoggedIn() else {
            isUserRecommendationAvailable = false
            return
        }
        let url = userRecommendationURL
        let params = ["uniqueId": JCAppUser.shared.unique, "jioId": JCAppUser.shared.uid]
        let recommendationListRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: recommendationListRequest) { (data, response, error) in
            if let responseError = error as NSError? {
                //TODO: handle error
                print(responseError)
                
                //Refresh sso token call fails
                if responseError.code == 143 {
                    print("Refresh sso token call fails")
                    DispatchQueue.main.async {
                        //JCLoginManager.sharedInstance.logoutUser()
                        //self.presentLoginVC()
                    }
                }
                return
            }
            if let responseData = data {
                weakSelf?.evaluateUserRecommendationList(dictionaryResponseData: responseData)
                //weakSelf?.dispatchGroup.leave()
                DispatchQueue.main.async {
                    if let recommendationData = JCDataStore.sharedDataStore.userRecommendationList?.data, recommendationData.count > 0 {
                        self.isUserRecommendationAvailable = true
                        self.baseTableView.reloadData()
                    } else {
                        self.isUserRecommendationAvailable = false
                    }
                }
            }
        }
    }
    
    func evaluateUserRecommendationList(dictionaryResponseData responseData: Data) {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .UserRecommendation)
    }
    
    func handleAlertForFirstTimeLaunchParentalControl() {
        let actionOk = Utility.AlertAction(title: "Ok", style: .default)
        let actionCancel = Utility.AlertAction(title: "Cancel", style: .cancel)
        let alertVC = Utility.getCustomizedAlertController(with: "", message: ParentalControlAlertMsg, actions: [actionOk, actionCancel]) { (alertAction) in
                if alertAction.title == actionOk.title {
                    
                    self.sendParentalPINPopupActionEvent(userAction: actionOk.title)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.tabBarController?.selectedIndex = 6
                    })
            }
                else {
                    self.sendParentalPINPopupActionEvent(userAction: actionCancel.title)
            }
        }
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func sendParentalPINPopupActionEvent(userAction: String) {
        // For Clever Tap Event
        let eventProperties = ["platform":"TVOS", "User Action": userAction]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Parental PIN Popup", properties: eventProperties)
        
        // For Internal Analytics Event
        let parentalPinPopupActionEvent = JCAnalyticsEvent.sharedInstance.getParentalPINPopupActionPerformedEvent(userAction: userAction)
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: parentalPinPopupActionEvent)
    }
}



