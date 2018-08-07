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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
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
        return 350
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (JCDataStore.sharedDataStore.musicData?.data) != nil
        {
            if(JCDataStore.sharedDataStore.musicData?.data?[0].isCarousal == true)
            {
                return (JCDataStore.sharedDataStore.musicData?.data?.count)! - 1
            }
            else
            {
                return (JCDataStore.sharedDataStore.musicData?.data?.count)!
            }
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.itemFromViewController = VideoType.Music
        cell.cellDelgate = self
        cell.tag = indexPath.row

        if(JCDataStore.sharedDataStore.musicData?.data?[0].isCarousal == true) {
            cell.tableCellCollectionView.tag = indexPath.row + 1
            cell.data = JCDataStore.sharedDataStore.musicData?.data?[indexPath.row + 1].items
            let categoryTitle = (JCDataStore.sharedDataStore.musicData?.data?[indexPath.row + 1].title ?? "")
            cell.categoryTitleLabel.text = categoryTitle
        } else {
            cell.tableCellCollectionView.tag = indexPath.row
            cell.data = JCDataStore.sharedDataStore.musicData?.data?[indexPath.row].items
            let categoryTitle = (JCDataStore.sharedDataStore.musicData?.data?[indexPath.row].title ?? "")
            cell.categoryTitleLabel.text = categoryTitle
        }
        
        cell.tableCellCollectionView.reloadData()
        
        if(indexPath.row == (JCDataStore.sharedDataStore.musicData?.data?.count)! - 2)
        {
            if(loadedPage < (JCDataStore.sharedDataStore.musicData?.totalPages)! - 1)
            {
                callWebServiceForMusicData(page: loadedPage + 1)
                loadedPage += 1
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (JCDataStore.sharedDataStore.musicData?.totalPages) == nil
        {
            return UIView.init()
        }
        else
        {
            if(loadedPage == (JCDataStore.sharedDataStore.musicData?.totalPages)! - 1)
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
    
    
    func callWebServiceForMusicData(page:Int)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        let url = musicDataUrl.appending(String(page))
        let musicDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: musicDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateMusicData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateMusicData(dictionaryResponseData responseData:Data)
    {
        //Success
        if(loadedPage == 0)
        {
            weak var weakSelf = self
            DispatchQueue.main.async {
                JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Music)
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
            }
        }
        else
        {
            weak var weakSelf = self
            DispatchQueue.main.async {
                JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Music)
                weakSelf?.baseTableView.reloadData()
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
                }else{
                    if let headerViewOfTableSection = carousalView {
                        headerViewOfTableSection.middleButton.alpha = 0.5
                    }
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
        if let tappedItem = item as? Item{
            
            if tappedItem.app?.type == VideoType.Music.rawValue{
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
        toScreenName = PLAYER_SCREEN
        var moreArray: [More]? = nil
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
