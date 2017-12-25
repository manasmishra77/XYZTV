//
//  JCClipsVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCClipsVC: JCBaseVC, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, JCBaseTableViewCellDelegate, JCCarouselCellDelegate
{
    var loadedPage = 0
    fileprivate var screenAppearTiming = Date()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        callWebServiceForClipsData(page: loadedPage)
        
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        screenAppearTiming = Date()

        self.tabBarController?.delegate = self
        if JCDataStore.sharedDataStore.clipsData?.data == nil
        {
            callWebServiceForClipsData(page: loadedPage)
        }
        
        //Clevertap Navigation Event
        let eventProperties = ["Screen Name":"Clips","Platform":"TVOS","Metadata Page":""]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        Utility.sharedInstance.handleScreenNavigation(screenName: CLIP_SCREEN, toScreen: "", duration: Int(Date().timeIntervalSince(screenAppearTiming)))
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
        if (JCDataStore.sharedDataStore.clipsData?.data) != nil
        {
            if(JCDataStore.sharedDataStore.clipsData?.data?[0].isCarousal == true)
            {
                return (JCDataStore.sharedDataStore.clipsData?.data?.count)! - 1
            }
            else
            {
                return (JCDataStore.sharedDataStore.clipsData?.data?.count)!
            }
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        
        cell.itemFromViewController = VideoType.Clip
        cell.cellDelgate = self

        if(JCDataStore.sharedDataStore.clipsData?.data?[0].isCarousal == true)
        {
            cell.tableCellCollectionView.tag = indexPath.row + 1

            cell.data = JCDataStore.sharedDataStore.clipsData?.data?[indexPath.row + 1].items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.clipsData?.data?[indexPath.row + 1].title
        }
        else
        {
            cell.tableCellCollectionView.tag = indexPath.row

            cell.data = JCDataStore.sharedDataStore.clipsData?.data?[indexPath.row].items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.clipsData?.data?[indexPath.row].title
        }
        
        cell.tableCellCollectionView.reloadData()
        
        if(indexPath.row == (JCDataStore.sharedDataStore.clipsData?.data?.count)! - 2)
        {
            if(loadedPage < (JCDataStore.sharedDataStore.clipsData?.totalPages)! - 1)
            {
                callWebServiceForClipsData(page: loadedPage + 1)
                loadedPage += 1
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(JCDataStore.sharedDataStore.clipsData?.data?[0].isCarousal == true)
        {
            
            //For autorotate carousel
            let carouselViews = Bundle.main.loadNibNamed("kInfinityScrollView", owner: self, options: nil)
            let carouselView = carouselViews?.first as! InfinityScrollView
            if let carouselItems = JCDataStore.sharedDataStore.clipsData?.data?[0].items, carouselItems.count > 0{
                carouselView.carouselArray = carouselItems
                carouselView.loadViews()
                carouselView.carouselDelegate = self
                uiviewCarousel = carouselView
                return carouselView
            }else{
                return UIView()
            }
        }
        else
        {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if(JCDataStore.sharedDataStore.clipsData?.data?[0].isCarousal == true)
        {
            return CGFloat(heightOfCarouselSection)
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (JCDataStore.sharedDataStore.clipsData?.totalPages) == nil
        {
            return UIView()
        }
        else
        {
            if(loadedPage == (JCDataStore.sharedDataStore.clipsData?.totalPages)! - 1)
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
    
    
    func callWebServiceForClipsData(page: Int)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        let url = clipsDataUrl.appending(String(page))
        let clipsDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: clipsDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateClipsData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateClipsData(dictionaryResponseData responseData:Data)
    {
        //Success
        
        if(loadedPage == 0)
        {
            JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Clips)
            weak var weakSelf = self
            DispatchQueue.main.async {
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
            }
        }
        else
        {
            JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Clips)
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.baseTableView.reloadData()
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
        //Making tab bar delegate searchvc
        if let searchNavVC = tabBarController.selectedViewController as? UINavigationController, let svc = searchNavVC.viewControllers[0] as? UISearchContainerViewController{
                if let searchVc = svc.searchController.searchResultsController as? JCSearchVC{
                    tabBarController.delegate = searchVc
            }
        }
    }
    
    //MARK:- JCBaseTableCell Delegate Methods
    func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int) {
        if let tappedItem = item as? Item{
            
            //Screenview event to Google Analytics
            JCAnalyticsManager.sharedInstance.event(category: "Clips Screen", action: "Video Play", label: tappedItem.name, customParameters: nil)
            
            print(tappedItem)
            
            if tappedItem.app?.type == VideoType.Clip.rawValue{
                print("At Clip")
                checkLoginAndPlay(tappedItem, categoryName: (baseCell?.categoryTitleLabel.text!)!, categoryIndex: indexFromArray)
            }
        }
    }
    
    func didTapOnCarouselItem(_ item: Any?) {
        if let tappedItem = item as? Item{
            
            //Screenview event to Google Analytics
            JCAnalyticsManager.sharedInstance.event(category: "Clips Screen", action: "Video Play", label: tappedItem.name, customParameters: nil)
            
             if tappedItem.app?.type == VideoType.Clip.rawValue{
                print("At Clip")
                checkLoginAndPlay(tappedItem, categoryName: "Carousel", categoryIndex: 0)
            }
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
        if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt){
            if appType == .Clip || appType == .Music || appType == .Trailer{
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: CLIP_SCREEN, fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "" )
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }

    func presentLoginVC()
    {
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }
    
  
    
}
