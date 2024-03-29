//
//  JCSearchVC.swift
//  JioCinema
//
//  Created by SushantAlone on 10/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSearchResultViewController: JCBaseVC, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, JCBaseTableViewCellDelegate, UITabBarControllerDelegate {
    
    weak var searchViewController: UISearchController? = nil
        var myPreferdFocusedView : UIView?
    
    
    //For Search from artist name
    fileprivate var metaDataItemId: String = ""
    fileprivate var metaDataAppType = VideoType.None
    fileprivate var metaDataFromScreen = ""
    fileprivate var metaDataCategoryName = ""
    fileprivate var metaDataCategoryIndex = 0
    fileprivate var metaDataTabBarIndex = 0
    fileprivate var isForArtistSearch = false
    fileprivate var screenAppearTiming = Date()
    fileprivate var metaDataForArtist: Any? = nil
    fileprivate var languageModelForArtistSearch: Any?
    fileprivate var baseVCModelForArtistSearch: Item? // used for DisneyTVVC, DisneyMovie and DisneyKid //if the VC is presented on the TabbarVc
    fileprivate var vcTypeForMetadataArtist: VCTypeForArtist?
    
    fileprivate var isComminFromSelectingRecommend = false
    
    fileprivate var searchModel: SearchDataModel?
    fileprivate var searchResultArray = [SearchedCategoryItem]() {
        didSet {
            handleWhenSearchResultArrayChanges()
        }
    }
    
    var trendingSearchResultViewModel: JCTrendingSearchResultViewModel?
    
    var isSearchTextIsGettingCalled: Bool = false
    weak var timerForSearch: Timer?
    var searchText: String = ""
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let cellNib = UINib(nibName: "BaseTableViewCell", bundle: nil)
        baseTableView.register(cellNib, forCellReuseIdentifier: "BaseTableViewCell")
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.searchRecommendationTableView.register(UINib(nibName: "JCSearchRecommendationTableViewCell", bundle: nil), forCellReuseIdentifier: SearchRecommendationCellIdentifier)
        
        baseTableView.delegate = self
        baseTableView.dataSource = self
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
        
        //Search Trending ViewModel Intialization
        trendingSearchResultViewModel = JCTrendingSearchResultViewModel(self)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewIsAppearing() {
        sendEventToAnalytics(true)
        if isForArtistSearch {
            
        } else if isComminFromSelectingRecommend {
            isComminFromSelectingRecommend = false
        } else {
            trendingSearchResultViewModel?.callWebServiceForTrendingResult()
        }
    }
    
    func viewIsDisappearing() {
        sendEventToAnalytics(false)
    }
    
    func viewDidDisappearedCalled() {
        if isComminFromSelectingRecommend {return}
        resetSearchScreen()
    }
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath) as? BaseTableViewCell else {
            return UITableViewCell()
        }
        let cellData = getCellItems(indexPath.row)
        cell.configureView(cellData, delegate: self)
        return cell
    }
    
    func getCellItems(_ index: Int) -> BaseTableCellModel {
        var baseTableCellModel : BaseTableCellModel = BaseTableCellModel(title: "", items: [], cellType: .base, layoutType: .landscapeWithTitleOnly, sectionLanguage: .english, charItems: nil)
        if let items = searchResultArray[index].resultItems {
            baseTableCellModel.title = (searchResultArray[index].categoryName ?? "") + "(\(items.count))"
            baseTableCellModel.cellType = .search
            baseTableCellModel.layoutType = getLayoutOfCellForItemType(items.first)
            if searchResultArray[index].categoryLayout == 100 {
                baseTableCellModel.layoutType = .landscapeWithLabels
            }
            baseTableCellModel.items = items
            baseTableCellModel.charItems = nil
            baseTableCellModel.sectionLanguage = .english
            return baseTableCellModel
        }
        return baseTableCellModel
    }
    
    func getLayoutOfCellForItemType(_ item : Item?) -> ItemCellLayoutType {
        if let appType = item?.appType {
            switch appType {
            case .Episode, .Clip, .Music, .Search:
                return .landscapeWithLabelsAlwaysShow
//            case .Movie:
//                return .potrait
            case .Movie:
                return .landscapeWithTitleOnly
            default:
                return .landscapeWithTitleOnly
            }
        }
        return .landscapeWithTitleOnly
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if searchResultArray[indexPath.row].categoryLayout == 100 {
//            return rowHeightForLandscape
//        } else if let appType = searchResultArray[indexPath.row].resultItems?.first?.appType, appType == .Movie {
//            return rowHeightForPotrait
//        }
        if let appType = searchResultArray[indexPath.row].resultItems?.first?.appType, appType == .Movie {
            return rowHeightForLandscapeTitleOnly
        }
        return rowHeightForLandscapeWithLabels
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    //MARK:- JCBaseTableCell Delegate Methods
    func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int) {
        if let item = item as? Item {
            var tappedItem = item
            isComminFromSelectingRecommend = true
            //Screenview event to Google Analytics
            let customParams: [String: String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: SEARCH_SCREEN, action: VIDEO_ACTION, label: tappedItem.name, customParameters: customParams)
            
            print(tappedItem)
            let categoryName = baseCell?.categoryTitleLabel.text ?? "Carousel"
            if let itemType = VideoType(rawValue: tappedItem.app?.type ?? -111) {
                switch itemType {
                case .Movie:
                    print("At Movie")
                    let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id ?? "", appType: .Movie, fromScreen: SEARCH_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 5, defaultAudioLanguage: item.audioLanguage, currentItem: tappedItem)
                    
                    self.present(metadataVC, animated: true, completion: nil)
                case .TVShow:
                    print("At TvShow")
                    let drn = Float(tappedItem.duration ?? 0)
                    if drn > 0 {
                        tappedItem.app?.type = VideoType.Episode.rawValue
                        checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
                    } else {
                        let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id ?? "", appType: .TVShow, fromScreen: SEARCH_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 5, defaultAudioLanguage: item.audioLanguage)
                        self.present(metadataVC, animated: true, completion: nil)
                    }
                case .Music, .Episode, .Clip, .Trailer:
                    checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
                default:
                    break
                }
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
    
    
    func presentLoginVC() {
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }
    
    //MARK:- Preparing playerVC
    func prepareToPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int) {
        if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt){
            if appType == .Clip || appType == .Music || appType == .Trailer {
//                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", latestId: itemToBePlayed.latestId, isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: SEARCH_SCREEN, fromCategory: "", fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "", audioLanguage: itemToBePlayed.audioLanguage)
                let playerVC = Utility.sharedInstance.prepareCustomPlayerVC(item: itemToBePlayed, fromScreen: SEARCH_SCREEN, fromCategory: "", fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            }
            else if appType == .Episode {
//                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", latestId: itemToBePlayed.latestId, isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: SEARCH_SCREEN, fromCategory: "", fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "", audioLanguage: itemToBePlayed.audioLanguage)
                let playerVC = Utility.sharedInstance.prepareCustomPlayerVC(item: itemToBePlayed, fromScreen: SEARCH_SCREEN, fromCategory: "", fromCategoryIndex: 0, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.timerForSearch?.invalidate()
        self.timerForSearch = nil
        self.timerForSearch = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {[weak self] (timer) in
            guard let self = self else {return}
            if searchText.count > 0 {
                self.searchResultForkey(with: searchText)
            } else {
                self.searchResultArray.removeAll()
                self.baseTableView.reloadData()
            }
        }
    }
    
    func resetSearch() {
        self.searchResultArray.removeAll()
        self.baseTableView.reloadData()
    }
    
    //MARK:-  UISearchResultsUpdating Methods
    func updateSearchResults(for searchController: UISearchController) {
        searchResultForkey(with: searchController.searchBar.text ?? "")
    }
    
    func searchResultForkey(with key: String) {
        
        if key == "" {
            self.searchViewController?.searchBar.text = ""
        } else {
            self.searchViewController?.searchBar.text = key
        }
        guard !isSearchTextIsGettingCalled else {
            return
        }
        self.searchText = self.searchViewController?.searchBar.text ?? ""
        self.callSearchServiceAPI(with: self.searchText)

        self.timerForSearch?.invalidate()
        self.timerForSearch = nil
       
        /*
         RJILApiManager.getSearchData(key: key, <#T##completion: APISuccessBlock##APISuccessBlock##(Bool, String?) -> ()#>)
         let searchRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
         weak var weakself = self
         
         RJILApiManager.defaultManager.post(request: searchRequest) { (data, response, error) in
         if error != nil {
         DispatchQueue.main.async {
         weakself?.searchResultArray.removeAll()
         weakself?.baseTableView.reloadData()
         }
         return
         }
         if let responseData = data {
         if let responseString = String(data: responseData, encoding: .utf8) {
         weakself?.searchModel = SearchDataModel(JSONString: responseString)
         
         if let array = (weakself?.searchModel?.searchData?.categoryItems), array.count > 0 {
         DispatchQueue.main.async {
         weakself?.searchResultArray = array
         weakself?.baseTableView.reloadData()
         }
         }
         }
         }
         }*/
    }
    
    func callSearchServiceAPI(with text: String) {
        let url = preditiveSearchURL
        let params: [String: String]? = ["q": text]
        self.isSearchTextIsGettingCalled = true
        RJILApiManager.getReponse(path: url, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: true, reponseModelType: SearchDataModel.self) {[weak self](response) in
            guard let self = self else {return}
            self.isSearchTextIsGettingCalled = false
            guard response.isSuccess else {
                DispatchQueue.main.async {
                    self.searchResultArray.removeAll()
                    self.baseTableView.reloadData()
                }
                return
            }
            if self.searchText == "aaa" {
                self.searchModel = nil
            } else {
            self.searchModel = response.model
            }
            if let array = (self.searchModel?.searchData?.categoryItems), array.count > 0 {
                DispatchQueue.main.async {
                    self.searchResultArray = array
                    self.baseTableView.reloadData()
                    
                }
            }
            
        }
    }
    
    //MARK:- Analytics Event Methods
    func sendSearchAnalyticsEvent() {
        // For Internal Analytics Event
        let searchInternalEvent = JCAnalyticsEvent.sharedInstance.getSearchEventForInternalAnalytics(query: (self.searchViewController?.searchBar.text ?? ""), isvoice: "false", queryResultCount: String(self.searchResultArray.count))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: searchInternalEvent)
    }
    
    //MARK:- Artist search preparation methods
    func searchArtist(searchText: String, metaDataItemId: String, metaDataAppType: VideoType, metaDataFromScreen: String, metaDataCategoryName: String, metaDataCategoryIndex: Int, metaDataTabBarIndex: Int, metaData: Any, languageModel: Any? = nil, baseVCModel: Item? = nil, vcTypeForMetadata: VCTypeForArtist? = nil) {
        isForArtistSearch = true
        searchViewController?.searchBar.text = searchText
        searchResultForkey(with: searchText)
        baseTableView.contentOffset = CGPoint(x: 0, y: 0)
//        self.metaDataItemId = metaDataItemId
//        self.metaDataAppType = metaDataAppType
//        self.metaDataFromScreen = metaDataFromScreen
//        self.metaDataCategoryName = metaDataCategoryName
//        self.metaDataCategoryIndex = metaDataCategoryIndex
//        self.metaDataTabBarIndex = metaDataTabBarIndex
//        self.metaDataForArtist = metaData
//        self.languageModelForArtistSearch = languageModel
//        self.baseVCModelForArtistSearch = baseVCModel
//        self.vcTypeForMetadataArtist = vcTypeForMetadata
//        self.isComminFromSelectingRecommend = false
    }
    
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        if presses.first?.type == UIPressType.menu, isForArtistSearch {
//            isForArtistSearch = false
//            if vcTypeForMetadataArtist == .languageGenre {
//                if let languageModel = languageModelForArtistSearch as? Item {
//                    let metaDataVC = Utility.sharedInstance.prepareMetadata(metaDataItemId, appType: metaDataAppType, fromScreen: metaDataFromScreen, categoryName: metaDataCategoryName, categoryIndex: metaDataCategoryIndex, tabBarIndex: metaDataTabBarIndex, shouldUseTabBarIndex: true, isMetaDataAvailable: true, metaData: metaDataForArtist!, modelForPresentedVC: languageModel, vcTypeForArtist: vcTypeForMetadataArtist)
//                    self.resetLanguageScreenRelatedVars()
//                    self.present(metaDataVC, animated: true, completion: nil)
//                }
//            } else if vcTypeForMetadataArtist == .disneyTV || vcTypeForMetadataArtist == .disneyMovie || vcTypeForMetadataArtist == .disneyKids {
//                let metaDataVC = Utility.sharedInstance.prepareMetadata(metaDataItemId, appType: metaDataAppType, fromScreen: metaDataFromScreen, categoryName: metaDataCategoryName, categoryIndex: metaDataCategoryIndex, tabBarIndex: metaDataTabBarIndex, shouldUseTabBarIndex: true, isMetaDataAvailable: true, metaData: metaDataForArtist!, modelForPresentedVC: nil, vcTypeForArtist: vcTypeForMetadataArtist)
//                self.resetLanguageScreenRelatedVars()
//                self.present(metaDataVC, animated: true, completion: nil)
//            } else {
//                let metaDataVC = Utility.sharedInstance.prepareMetadata(metaDataItemId, appType: metaDataAppType, fromScreen: metaDataFromScreen, categoryName: metaDataCategoryName, categoryIndex: metaDataCategoryIndex, tabBarIndex: metaDataTabBarIndex, shouldUseTabBarIndex: true, isMetaDataAvailable: true, metaData: metaDataForArtist!, vcTypeForArtist: vcTypeForMetadataArtist)
//                self.resetMetdataScreenRelatedVars()
//                self.present(metaDataVC, animated: true, completion: nil)
//            }
//        }
//    }
    
    fileprivate func resetMetdataScreenRelatedVars() {
        metaDataForArtist = nil
        isForArtistSearch = false
    }
    fileprivate func resetLanguageScreenRelatedVars() {
        languageModelForArtistSearch = nil
        baseVCModelForArtistSearch = nil
        vcTypeForMetadataArtist = nil
        resetMetdataScreenRelatedVars()
    }
    
    fileprivate func resetSearchScreen() {
        searchViewController?.searchBar.text = ""
        searchResultArray.removeAll()
        resetLanguageScreenRelatedVars()
        self.baseTableView.reloadData()
        if let viewModel =  trendingSearchResultViewModel {
            viewModel.tuggleSearchViewsAndSearchRecommViews(toShowSearchRecommView: false)
        }
    }
    
    func handleWhenSearchResultArrayChanges() {
        if let viewModel =  trendingSearchResultViewModel {
            viewModel.tuggleSearchViewsAndSearchRecommViews(toShowSearchRecommView: (searchResultArray.count < 1))
        }
    }
    
    //MARK:- Tabbarcontroller delegate methods
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex != 5 {
            isForArtistSearch = false
        }
    }
    
    fileprivate func sendEventToAnalytics(_ isAppearing: Bool) {
        if isAppearing {
            screenAppearTiming = Date()
        } else {
            //Clevertap Navigation Event
            let eventProperties = ["Screen Name": "Search","Platform": "TVOS", "Metadata Page": ""]
            JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
            Utility.sharedInstance.handleScreenNavigation(screenName: SEARCH_SCREEN, toScreen: "", duration: Int(Date().timeIntervalSince(screenAppearTiming)))
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferedView = myPreferdFocusedView {
            return [preferedView]
        }
        return []
    }
    
}

extension JCSearchResultViewController: BaseTableViewCellDelegate {
    func didTapOnCharacterItem(_ baseCell: BaseTableViewCell?, _ charItem: DisneyCharacterItems) {
        return
    }
    
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item) {
        let selectedIndexPath: IndexPath? = (baseCell != nil) ? self.baseTableView.indexPath(for: baseCell!) : nil
        let indexFromArray = selectedIndexPath?.row ?? -1
            var tappedItem = item
            isComminFromSelectingRecommend = true
            //Screenview event to Google Analytics
            let customParams: [String: String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: SEARCH_SCREEN, action: VIDEO_ACTION, label: tappedItem.name, customParameters: customParams)
            
            print(tappedItem)
            let categoryName = baseCell?.categoryTitleLabel.text ?? "Carousel"
            if let itemType = VideoType(rawValue: tappedItem.app?.type ?? -111) {
                switch itemType {
                case .Movie:
                    print("At Movie")
                    let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id ?? "", appType: .Movie, fromScreen: SEARCH_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 5, currentItem: tappedItem)
                    self.present(metadataVC, animated: true, completion: nil)
                case .TVShow:
                    print("At TvShow")
                    let drn = Float(tappedItem.duration ?? 0)
                    if drn > 0 {
                        tappedItem.app?.type = VideoType.Episode.rawValue
                        checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
                    } else {
                        let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id ?? "", appType: .TVShow, fromScreen: SEARCH_SCREEN, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: 5, currentItem: tappedItem)
                        self.present(metadataVC, animated: true, completion: nil)
                    }
                case .Music, .Episode, .Clip, .Trailer:
                    checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexFromArray)
                default:
                    break
                }
            }

    }
    
    
}
