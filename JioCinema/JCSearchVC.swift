//
//  JCSearchVC.swift
//  JioCinema
//
//  Created by SushantAlone on 10/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSearchVC: JCBaseVC, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, JCBaseTableViewCellDelegate, UITabBarControllerDelegate {

    var searchViewController:UISearchController? = nil
    
    //For Search from artist name
    fileprivate var metaDataItemId: String = ""
    fileprivate var metaDataAppType = VideoType.None
    fileprivate var metaDataFromScreen = ""
    fileprivate var metaDataCategoryName = ""
    fileprivate var metaDataCategoryIndex = 0
    fileprivate var metaDataTabBarIndex = 0
    fileprivate var isForArtistSearch = false
    fileprivate var isOnSearchScreen = true
    fileprivate var screenAppearTiming = Date()
    fileprivate var metaDataForArtist: Any? = nil
    
    fileprivate var searchModel:SearchDataModel?
    fileprivate var searchResultArray = [SearchedCategoryItem]()
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        baseTableView.delegate = self
        baseTableView.dataSource = self
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.sendSearchAnalyticsEvent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- UITableView Delegate

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.itemFromViewController = VideoType.Search

        cell.categoryTitleLabel.text = searchResultArray[indexPath.row].categoryName
        cell.cellDelgate = self
        cell.data = searchResultArray[indexPath.row].resultItems
        cell.tableCellCollectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340.0
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    //MARK:- JCBaseTableCell Delegate Methods
    func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int) {
        if let tappedItem = item as? Item{
            print(tappedItem)
            let categoryName = baseCell?.categoryTitleLabel.text ?? "Carousel"
            if tappedItem.app?.type == VideoType.Music.rawValue{
                print("At Music")
                checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
            }
            else if tappedItem.app?.type == VideoType.Movie.rawValue{
                print("At Movie")
                let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .Movie, fromScreen: HOME_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 5)
                self.present(metadataVC, animated: true, completion: nil)
            }
            else if tappedItem.app?.type == VideoType.TVShow.rawValue{
                print("At TvShow")
                if tappedItem.duration != nil, let drn = Float(tappedItem.duration!){
                    if drn > 0{
                        tappedItem.app?.type = VideoType.Episode.rawValue
                        checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
                    }else{
                        let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .TVShow, fromScreen: HOME_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 5)
                        self.present(metadataVC, animated: true, completion: nil)
                    }
                }else{
                    let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id!, appType: .TVShow, fromScreen: HOME_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 5)
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
        }
    }
    
    
    //MARK:- Handling after login
    fileprivate var itemAfterLogin: Item? = nil
    fileprivate var categoryIndexAfterLogin: Int? = nil
    fileprivate var categoryNameAfterLogin: String? = nil
    
    func playItemAfterLogin() {
        checkLoginAndPlay(itemAfterLogin!, categoryName: categoryNameAfterLogin!, categoryIndex: categoryIndexAfterLogin!)
        self.itemAfterLogin = nil
        self.categoryIndexAfterLogin = nil
        self.categoryNameAfterLogin = nil
    }
    
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
    
    
    func presentLoginVC()
    {
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }
    
    //MARK:- Preparing playerVC
    func prepareToPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int)
    {
        if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt){
            if appType == .Clip || appType == .Music || appType == .Trailer{
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: SEARCH_SCREEN, fromCategory: "", fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            }
            else if appType == .Episode{
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: SEARCH_SCREEN, fromCategory: "", fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 0
        {
            searchResultForkey(with: searchText)
        }
        else
        {
            DispatchQueue.main.async {
                self.searchResultArray.removeAll()
                self.baseTableView.reloadData()
            }
        }
    }
    
    //MARK:-  UISearchResultsUpdating Methods
    func updateSearchResults(for searchController: UISearchController) {
        searchResultForkey(with: searchController.searchBar.text!)
    }
    
    fileprivate func searchResultForkey(with key:String)
    {
        let url = preditiveSearchURL
        let params:[String:String]? = ["q": key]
        let searchRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakself = self
        
        RJILApiManager.defaultManager.post(request: searchRequest) { (data, response, error) in
            if error != nil
            {
                DispatchQueue.main.async {
                    weakself?.searchResultArray.removeAll()
                    weakself?.baseTableView.reloadData()
                }
                return
            }
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    self.searchModel = SearchDataModel(JSONString: responseString)
                    
                    let array = (self.searchModel?.searchData?.categoryItems) ?? [SearchedCategoryItem]()
                    if array.count > 0
                    {
                        DispatchQueue.main.async {
                            weakself?.searchResultArray = array
                            weakself?.baseTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
   
    //MARK:-  Analytics Event Methods
    func sendSearchAnalyticsEvent()
    {
        // For Internal Analytics Event
        let searchInternalEvent = JCAnalyticsEvent.sharedInstance.getSearchEventForInternalAnalytics(query: (self.searchViewController?.searchBar.text!)!, isvoice: "false", queryResultCount: String(self.searchResultArray.count))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: searchInternalEvent)
    }
    
    //MARK:- Artist search preparation methods
    func searchArtist(searchText: String, metaDataItemId: String, metaDataAppType: VideoType, metaDataFromScreen: String, metaDataCategoryName: String, metaDataCategoryIndex: Int, metaDataTabBarIndex: Int, metaData: Any) {
        isForArtistSearch = true
        searchViewController?.searchBar.text = searchText
        searchResultForkey(with: searchText)
        self.metaDataItemId = metaDataItemId
        self.metaDataAppType = metaDataAppType
        self.metaDataFromScreen = metaDataFromScreen
        self.metaDataCategoryName = metaDataCategoryName
        self.metaDataCategoryIndex = metaDataCategoryIndex
        self.metaDataTabBarIndex = metaDataTabBarIndex
        self.metaDataForArtist = metaData
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == UIPressType.menu, isForArtistSearch{
            isForArtistSearch = false
            let metaDataVC = Utility.sharedInstance.prepareMetadata(metaDataItemId, appType: metaDataAppType, fromScreen: metaDataFromScreen, categoryName: metaDataCategoryName, categoryIndex: metaDataCategoryIndex, tabBarIndex: metaDataTabBarIndex, shouldUseTabBarIndex: true, isMetaDataAvailable: true, metaData: metaDataForArtist!)
            self.present(metaDataVC, animated: true, completion: nil)
        }
       
    }
    
    //MARK:- Tabbarcontroller delegate methods
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        //ChangingTheAlpha when tab bar item selected
        if tabBarController.selectedIndex != 5{
            isForArtistSearch = false
            searchViewController?.searchBar.text = ""
            searchResultArray.removeAll()
            self.baseTableView.reloadData()
        }
        
      //Sending analytics event
        //When screen appears
        if tabBarController.selectedIndex == 5, isOnSearchScreen{
            isOnSearchScreen = true
            screenAppearTiming = Date()
        }
        else if tabBarController.selectedIndex != 5, isOnSearchScreen{
            isOnSearchScreen = false
            //Clevertap Navigation Event
            let eventProperties = ["Screen Name":"Search","Platform":"TVOS","Metadata Page":""]
            JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
            Utility.sharedInstance.handleScreenNavigation(screenName: SEARCH_SCREEN, toScreen: "", duration: Int(Date().timeIntervalSince(screenAppearTiming)))
        }
        
        
    }
    
}
