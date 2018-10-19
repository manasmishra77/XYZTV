//
//  JCMusicVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 29/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCMusicVC: JCBaseVC, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, JCBaseTableViewCellDelegate, JCCarouselCellDelegate
{

    fileprivate var loadedPage = 0
    fileprivate var screenAppearTiming = Date()
    fileprivate var toScreenName: String? = nil
    fileprivate var carousalView: InfinityScrollView?
    fileprivate var footerView: JCBaseTableViewFooterView?
    fileprivate var isMusicDataBeingCalled = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       callWebServiceForMusicData(page: loadedPage)
        
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tabBarController?.delegate = self
        if JCDataStore.sharedDataStore.musicData?.data == nil
        {
            callWebServiceForMusicData(page: loadedPage)
        }
        //Clevertap Navigation Event
        let eventProperties = ["Screen Name":"Music","Platform":"TVOS","Metadata Page":""]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        screenAppearTiming = Date()
    }
    override func viewDidDisappear(_ animated: Bool) {
        if let toScreen = toScreenName {
            Utility.sharedInstance.handleScreenNavigation(screenName: MUSIC_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
            toScreenName = nil
        } else {
            let toScreen = self.tabBarController?.selectedViewController?.tabBarItem.title ?? ""
            Utility.sharedInstance.handleScreenNavigation(screenName: MUSIC_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeightForLandscape
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let dataArray = JCDataStore.sharedDataStore.musicData?.data {
            count = (dataArray[0].isCarousal ?? false) ? dataArray.count - 1 : dataArray.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        
        cell.itemFromViewController = VideoType.Music
        cell.cellDelgate = self
        cell.tag = indexPath.row
        guard let dataArray = JCDataStore.sharedDataStore.musicData?.data else {
            return cell
        }
        let index = (dataArray[0].isCarousal ?? false) ? indexPath.row + 1 : indexPath.row
        cell.tableCellCollectionView.tag = index
        cell.itemsArray = dataArray[index].items
        cell.itemArrayType = .item
        
        cell.categoryTitleLabel.text = dataArray[index].title ?? ""
        cell.tableCellCollectionView.reloadData()
        
        if(indexPath.row == dataArray.count - 2) {
            if(loadedPage < (JCDataStore.sharedDataStore.musicData?.totalPages)!) {
                callWebServiceForMusicData(page: loadedPage)
                //loadedPage += 1
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //For autorotate carousel
        if carousalView == nil {
            if let items = JCDataStore.sharedDataStore.musicData?.data?[0].items {
                carousalView = Utility.getHeaderForTableView(for: self, with: items)
            }
        }
        return carousalView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (JCDataStore.sharedDataStore.musicData?.data?[0].isCarousal ?? false), let carouselItems = JCDataStore.sharedDataStore.musicData?.data?[0].items, carouselItems.count > 0 {
            return 650
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Utility.getFooterHeight(JCDataStore.sharedDataStore.musicData, loadedPage: loadedPage)
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
    
    
    func callWebServiceForMusicData(page:Int)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        if isMusicDataBeingCalled {
            return
        }
        isMusicDataBeingCalled = true
        
        RJILApiManager.getBaseModel(pageNum: page, type: .music) {[unowned self] (isSuccess, erroMsg) in
            guard isSuccess else {
                self.isMusicDataBeingCalled = false
                return
            }
            //Success
            if(self.loadedPage == 0) {
                DispatchQueue.main.async {
                    self.loadedPage += 1
                    self.activityIndicator.isHidden = true
                    self.baseTableView.reloadData()
                    self.baseTableView.layoutIfNeeded()
                    self.isMusicDataBeingCalled = false
                }
            } else {
                DispatchQueue.main.async {
                    self.loadedPage += 1
                    self.activityIndicator.isHidden = true
                    self.baseTableView.reloadData()
                    self.baseTableView.layoutIfNeeded()
                    self.isMusicDataBeingCalled = false
                }
            }
        }
        /*
        let url = musicDataUrl.appending(String(page))
        let musicDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: musicDataRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                weakSelf?.isMusicDataBeingCalled = false
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateMusicData(dictionaryResponseData: responseData)
                return
            }
        }*/
    }
    
    func evaluateMusicData(dictionaryResponseData responseData:Data)
    {
        //Success
        if(loadedPage == 0)
        {
            JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Music)
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.loadedPage += 1
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
                weakSelf?.baseTableView.layoutIfNeeded()
                weakSelf?.isMusicDataBeingCalled = false
            }
        }
        else
        {
            JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Music)
            weak var weakSelf = self
            DispatchQueue.main.async {
                
                weakSelf?.loadedPage += 1
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
                weakSelf?.baseTableView.layoutIfNeeded()
                weakSelf?.isMusicDataBeingCalled = false
            }
        }
    }
    
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
        if let tappedItem = item as? Item{
            
            print(tappedItem)
            let categoryName = baseCell?.categoryTitleLabel.text ?? "Carousel"
            if tappedItem.app?.type == VideoType.Music.rawValue{
                print("At Music")
                checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
            }
            
            //Screenview event to Google Analytics
            let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: MUSIC_SCREEN, action: VIDEO_ACTION, label: tappedItem.name, customParameters: customParams)
        }
    }
    
    func didTapOnCarouselItem(_ item: Any?) {
        if let tappedItem = item as? Item {
            if tappedItem.app?.type == VideoType.Music.rawValue {
                print("At Music")
                checkLoginAndPlay(tappedItem, categoryName: "Carousel", categoryIndex: 0)
            }
            //Screenview event to Google Analytics
            let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: MUSIC_SCREEN, action: VIDEO_ACTION, label: tappedItem.name, customParameters: customParams)
        }
    }
    
    
    //For after login function
    fileprivate var itemAfterLogin: Item? = nil
    fileprivate var categoryIndexAfterLogin: Int? = nil
    fileprivate var categoryNameAfterLogin: String? = nil
    
    func checkLoginAndPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int) {
        //weak var weakSelf = self
        if(JCLoginManager.sharedInstance.isUserLoggedIn()) {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            prepareToPlay(itemToBePlayed, categoryName: categoryName, categoryIndex: categoryIndex)
        } else {
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
        toScreenName = PLAYER_SCREEN
        var moreArray: [Item]? = nil
        var isMoreDataAvailable = false
        if itemToBePlayed.isPlaylist ?? false{
            let recommendationArray = (JCDataStore.sharedDataStore.musicData?.data?[0].isCarousal ?? false) ? JCDataStore.sharedDataStore.musicData?.data?[categoryIndex + 1].items : JCDataStore.sharedDataStore.musicData?.data?[categoryIndex].items
            moreArray = Utility.sharedInstance.convertingItemArrayToMoreArray(recommendationArray ?? [Item]())
            if moreArray?.count ?? 0 > 0{
                isMoreDataAvailable = true
            }
        }
       
        if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt){
            if appType == .Clip || appType == .Music || appType == .Trailer{
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: isMoreDataAvailable, isEpisodeAvailable: false, recommendationArray: moreArray ?? false, fromScreen: MUSIC_SCREEN, fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }
    
    func presentLoginVC()
    {
        toScreenName = LOGIN_SCREEN
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }


}
