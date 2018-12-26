//
//  BaseViewModel.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

typealias TableCellItemsTuple = (title: String, items: [Item], cellType: ItemCellType, layout: ItemCellLayoutType, sectionLanguage: AudioLanguage)


protocol BaseViewModelDelegate {
    func presentVC(_ vc: UIViewController)
    func presentMetadataOfIcarousel(_ itemId : Any)
}

class BaseViewModel: NSObject  {
    var isDisneyWatchlistAvailable = false
    var carousal : ViewForCarousel?
    var baseDataModel: BaseDataModel? {
        switch vcType {
        case .home:
            return JCDataStore.sharedDataStore.homeData
        case .movie:
            return JCDataStore.sharedDataStore.moviesData
        case .tv:
            return JCDataStore.sharedDataStore.tvData
        case .music:
            return JCDataStore.sharedDataStore.musicData
        case .clip:
            return JCDataStore.sharedDataStore.clipsData
        case .search:
            return JCDataStore.sharedDataStore.clipsData
        case .disneyHome:
            return JCDataStore.sharedDataStore.disneyData
        case .disneyKids:
            return JCDataStore.sharedDataStore.disneyKidsData
        case .disneyTVShow:
            return JCDataStore.sharedDataStore.disneyTVShowData
        case .disneyMovies:
            return JCDataStore.sharedDataStore.disneyMoviesData
        }
    }
    var baseWatchListModel: BaseDataModel? {
        switch vcType {
        case .home:
            return JCDataStore.sharedDataStore.resumeWatchList
        case .movie:
            return JCDataStore.sharedDataStore.moviesWatchList
        case .tv:
            return JCDataStore.sharedDataStore.tvWatchList
        case .disneyHome:
            return JCDataStore.sharedDataStore.disneyResumeWatchList
        case .disneyMovies:
            return JCDataStore.sharedDataStore.disneyMovieWatchList
        case .disneyTVShow:
            return JCDataStore.sharedDataStore.disneyTVWatchList
        default:
            return nil
        }
    }

    var carouselView : UIView? {
        if carousal == nil {
            if let items = baseDataModel?.data?[0].items{
                let frameOfView =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 650)
                carousal = ViewForCarousel.instantiate(count: items.count, isCircular: true, sepration: 20, visiblePercentageOfPeekingCell: 0.2, hasFooter: false, frameOfView: frameOfView, backGroundColor: .clear, autoScroll: true, setImage: self)
            }
//            if let items = baseDataModel?.data?[0].items {
//                var isDisney = false
//                if vcType == .disneyHome || vcType == .disneyKids || vcType == .disneyTVShow || vcType == .disneyMovies{
//                isDisney = true
//                }
//
//                carousal = Utility.getHeaderForTableView(for: self, with: items, isDisney: isDisney)
//
//                DispatchQueue.main.async {
//                    if self.vcType == .disneyHome {
//                        self.carousal?.viewOfButtons.isHidden = false
//                        self.carousal?.disneyViewHeight.constant = 200
//                    }
//                    else {
//                        self.carousal?.viewOfButtons.isHidden = true
//                        self.carousal?.disneyViewHeight.constant = 0
//                    }
//                }
//
//
//            }
        }
        return carousal
    }
    
    init(_ vcType: BaseVCType) {
        self.vcType = vcType
        super.init()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
   
    var delegate: BaseViewModelDelegate?
    let vcType: BaseVCType
    var pageNumber = 0 // Reference for Downloading base page
    var errorMsg: String?
    
    var totalPage: Int {// Reference for Downloading base page
        return baseDataModel?.totalPages ?? 1
    }
    var viewResponseBlock: ((_ isSuccess: Bool) -> ())? = nil
    lazy var baseAPIReponseHandler = {(_ isSuccess: Bool, error: String?) in
        guard isSuccess else {
            //Handle when APi fails
            return
        }
        self.populateTableIndexArray()
        self.viewResponseBlock?(isSuccess)
    }
    
    var countOfTableView: Int {
        return baseTableIndexArray.count
    }
    
    func reloadTableView() {
        populateBaseTableArray()
        viewResponseBlock?(true)
    }
    
    var isToReloadTableViewAfterLoginStatusChange: Bool {
        let isWatchListAvailabaleInDataStore = (self.baseWatchListModel != nil)
        var watchListStatusInBaseTableArray = false
        if baseTableIndexArray.count > 0 {
            watchListStatusInBaseTableArray = (baseTableIndexArray[baseWatchListIndex].0 == .watchlist)
        }
        var reloadTable = false
        if isWatchListUpdated {
            reloadTable = true
            isWatchListUpdated = false
        } else {
            if isWatchListAvailabaleInDataStore, !watchListStatusInBaseTableArray {
                reloadTable = true
            } else if !isWatchListAvailabaleInDataStore, watchListStatusInBaseTableArray {
                reloadTable = true
            } 
        }
        return reloadTable
    }
    
    // may be used to get updated watchlist after adding or removing in watchlist
    func getUpdatedWatchListFor(vcType: BaseVCType) {
       fetchAfterLoginUserDataWithoutCompletion()        
    }
    //Used when logging in
    func fetchAfterLoginUserDataWithoutCompletion() {
        RJILApiManager.getWatchListData(isDisney: vcType.isDisney, type: vcType, nil)
        isWatchListUpdated = true
    }
    
    //For after login function
    fileprivate var itemAfterLogin: Item? = nil
    fileprivate var categoryIndexAfterLogin: Int? = nil
    fileprivate var categoryNameAfterLogin: String? = nil
    
    fileprivate var baseTableIndexArray: [(BaseDataType, Int)] = []
    fileprivate var baseModelIndex = 0
    fileprivate var baseWatchListIndex = 0
    fileprivate var isWatchListUpdated = false
    
    @objc func fetchData(completion: @escaping (_ isSuccess: Bool) -> ()) {
        viewResponseBlock = completion
        fetchBaseData()
        getBaseWatchListData()
    }
    

    func fetchBaseData() {
        guard pageNumber < totalPage else {return}
        RJILApiManager.getBaseModel(pageNum: pageNumber, type: vcType) {[weak self] (isSuccess, errMsg) in
            guard let self = self else {return}
            guard isSuccess else {
                self.errorMsg = errMsg
                self.viewResponseBlock?(isSuccess)
                return
            }
            self.pageNumber += 1
            self.populateTableIndexArray()
            self.viewResponseBlock?(isSuccess)
        }
    }
    
    func heightOfTableHeader(section : Int) -> CGFloat {
//        if let data = baseDataModel?.data, data.count > 0, data[0].isCarousal == true {
//            return (vcType == .disneyHome) ? 850 : 650
//        }
//        return 0
        if section == 0 {
            if let data = baseDataModel?.data, data.count > 0, data[0].isCarousal == true {
                return 650
            }
            return 0
        } else {
            return 0
        }
    }
    func buttonView() -> DisneyButtons? {
        return nil
    }
    func leadingConstraintBaseTable() -> CGFloat {
        switch vcType {
        case .disneyMovies, .disneyKids, .disneyTVShow:
            return 0
        default:
            return 0//80
        }
    }
    
    func heightOfTableRow(_ index: IndexPath) -> CGFloat {
        if index.section == 0 {
            return 0
        } else {
        let layout = itemCellLayoutType(index: index.row)
        let height: CGFloat = ((layout == .potrait) || (layout == .potraitWithLabelAlwaysShow)) ? rowHeightForPotrait : rowHeightForLandscape
        return height
        }
    }
    
    func populateTableIndexArray() {
        populateBaseTableArray()
    }
    func getLayoutOfCellForItemType(_ item : Item?) -> ItemCellLayoutType {
        if let appType = item?.appType {
            switch appType {
            case .Episode, .Clip, .Music, .Search:
                return .landscapeWithLabelsAlwaysShow
            case .Language, .Genre:
                return .landscapeForLangGenre
            case .Movie:
                return .potrait
            default:
                return .landscapeWithTitleOnly
            }
        }
        return .landscapeWithTitleOnly
    }
    func itemCellLayoutType(index: Int) -> ItemCellLayoutType {
        let itemIndexTuple = baseTableIndexArray[index]
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data {
                let data = dataContainer[(itemIndexTuple.1)]
                var _: ItemCellLayoutType = data.layoutType
                return getLayoutOfCellForItemType(data.items?.first)
            }
        case .watchlist:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                var layout: ItemCellLayoutType = dataContainer.layoutType
                layout = .landscapeWithLabelsAlwaysShow
                if (vcType == .disneyMovies) || (vcType == .movie) {
                    layout = .potraitWithLabelAlwaysShow
                }
                return layout
            }
        }
        return .landscapeWithTitleOnly
    }
    
    
    
    func getTableCellItems(for index: Int, completion: @escaping (_ isSuccess: Bool) -> ()) -> TableCellItemsTuple {
        viewResponseBlock = completion
        let itemIndexTuple = baseTableIndexArray[index]
        let layout = itemCellLayoutType(index: index)
        var cellType: ItemCellType = .base
        if vcType.isDisney {
            cellType = .disneyCommon
        }
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainerArr = baseDataModel?.data, let dataContainer = getDataContainer(index) {
                if itemIndexTuple.1 == dataContainerArr.count - 1 {
                    fetchBaseData()
                }
                return (title: dataContainer.title ?? "", items: dataContainer.items ?? [], cellType: cellType, layout: layout, sectionLanguage: dataContainer.categoryLanguage)
            }
        case .watchlist:
            if let dataContainer = getDataContainer(index) {
                return (title: dataContainer.title ?? "Watch List", items: dataContainer.items ?? [], cellType: cellType, layout: layout, sectionLanguage: .english)
            }
        }
        return (title: "", items: [], cellType: .base, layout: .landscapeWithTitleOnly, sectionLanguage: .english)
    }
    
    func getDataContainer(_ index: Int) -> DataContainer? {
        let itemIndexTuple = baseTableIndexArray[index]
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data?[itemIndexTuple.1] {
                return dataContainer
            }
        case .watchlist:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                return dataContainer
            }
        }
        return nil
    }
    
    
    //Used for DisneyMovieVC and DisneyTVVC
    func changeWatchListUpdatedVariableSatus(_ status: Bool) {
        self.isWatchListUpdated = status
    }
    
    
}

// MovieVC
fileprivate extension BaseViewModel {
    enum BaseDataType {
        case base
        case watchlist
    }
    fileprivate func getBaseWatchListData() {
        if vcType == .tv || vcType == .movie {
            RJILApiManager.getWatchListData(isDisney : vcType.isDisney ,type: vcType, baseAPIReponseHandler)
        }
    }
    
    fileprivate func populateBaseTableArray() {
        resetBaseTableIndexArray()
        appendInBaseTableIndex(from: baseDataModel?.data)
        insertInBaseTableIndex(from: baseWatchListModel?.data)
    }
    private func appendInBaseTableIndex(from baseContainer: [DataContainer]?) {
        guard let baseDataContainer = baseContainer else {return}
        let increaseBaseModelIndex = (baseDataContainer[0].isCarousal ?? false) ? 1 : 0
        baseModelIndex += increaseBaseModelIndex
        for _ in increaseBaseModelIndex..<baseDataContainer.count {
            baseTableIndexArray.append((BaseDataType.base, baseModelIndex))
            baseModelIndex += 1
        }
    }
    private func insertInBaseTableIndex(from watchListContainer: [DataContainer]?) {
        guard watchListContainer != nil else {return}
        guard baseModelIndex > 0 else {return}
        baseTableIndexArray.insert((BaseDataType.watchlist, baseWatchListIndex), at: baseWatchListIndex)
    }
    
    private func resetBaseTableIndexArray() {
        baseTableIndexArray.removeAll()
        baseModelIndex = 0
        baseWatchListIndex = 0
    }
}

extension BaseViewModel: JCCarouselCellDelegate {
    func didTapOnCarouselItem(_ item: Any?) {
        guard let item = item as? Item else {return}
        self.itemCellTapped(item, selectedIndexPath: nil)
    }
    
    func presentVCOnButtonTap(tag: Int) {
        switch tag {
        case 1:
            let disneyMovies = BaseViewController(.disneyMovies)
            delegate?.presentVC(disneyMovies)
        case 2:
            let disneyTVShow = BaseViewController(.disneyTVShow)
            delegate?.presentVC(disneyTVShow)
        case 3:
            let disneyKids = BaseViewController(.disneyKids)
            delegate?.presentVC(disneyKids)
        default:
            return
        }
    }
    enum ButtonType : Int {
        case Movies = 1
        case TVShow = 2
        case Kids = 3
    }
}

extension BaseViewModel {
    func itemCellTapped(_ item: Item, selectedIndexPath: IndexPath?) {
        // Selected indexpath is for tableview cell
        let indexFromArray = selectedIndexPath?.row ?? 0
        let dataContainer = getDataContainer(indexFromArray)
        let categoryName = dataContainer?.title ?? "Carousal"
        
        switch item.appType {
        case .Movie:
            if let duration = item.duration, duration > 0 {
                checkLoginAndPlay(item, categoryName: categoryName, categoryIndex: indexFromArray)
            } else {
                let metadataVC = Utility.sharedInstance.prepareMetadata(item.id!, appType: item.appType, fromScreen: vcType.name, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: vcType.tabBarIndex, shouldUseTabBarIndex: false, isMetaDataAvailable: false, metaData: nil, modelForPresentedVC: nil, isDisney: vcType.isDisney, defaultAudioLanguage: item.audioLanguage)
                delegate?.presentVC(metadataVC)
            }
        case .Music, .Episode, .Clip, .Trailer:
            checkLoginAndPlay(item, categoryName: categoryName, categoryIndex: indexFromArray)
        case .TVShow:
            print("At TvShow")
            if let duration = item.duration, duration > 0 {
                var newItem = item
                newItem.app?.type = 7
                checkLoginAndPlay(newItem, categoryName: categoryName, categoryIndex: indexFromArray)
            } else {
                let metadataVC = Utility.sharedInstance.prepareMetadata(item.id ?? "", appType: item.appType, fromScreen: vcType.name, categoryName: categoryName, categoryIndex: indexFromArray, tabBarIndex: vcType.tabBarIndex, shouldUseTabBarIndex: false, isMetaDataAvailable: false, metaData: nil, modelForPresentedVC: nil, isDisney: vcType.isDisney, defaultAudioLanguage: item.audioLanguage)
                delegate?.presentVC(metadataVC)
            }
        case .Language,.Genre:
            let languageGenreVC = self.presentLanguageGenreController(item: item , audioLanguage: item.audioLanguage.name)
            delegate?.presentVC(languageGenreVC)
        default:
            print("Default")
        }
        
    }
    
    func presentLanguageGenreController(item: Item, audioLanguage : String) -> UIViewController{
        let languageGenreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreStoryBoardId) as! JCLanguageGenreVC
        languageGenreVC.item = item
        languageGenreVC.defaultLanguage = AudioLanguage(rawValue: audioLanguage)
        return languageGenreVC
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
    
    func playItemAfterLogin() {
        checkLoginAndPlay(itemAfterLogin!, categoryName: categoryNameAfterLogin!, categoryIndex: categoryIndexAfterLogin!)
        self.itemAfterLogin = nil
        self.categoryIndexAfterLogin = nil
        self.categoryNameAfterLogin = nil
    }
    
    func prepareToPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int) {
        switch itemToBePlayed.appType {
        case .Clip, .Music, .Trailer:
            let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: itemToBePlayed.appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: vcType.name, fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "", isDisney: vcType.isDisney, audioLanguage: itemToBePlayed.audioLanguage)
            delegate?.presentVC(playerVC)
        case .Episode:
            let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: itemToBePlayed.appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: vcType.name, fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "", isDisney: vcType.isDisney, audioLanguage: itemToBePlayed.audioLanguage)
            delegate?.presentVC(playerVC)
        case .Movie:
            print("Play Movie")
            let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: itemToBePlayed.appType, fromScreen: vcType.name, fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "", isDisney: vcType.isDisney, audioLanguage: itemToBePlayed.audioLanguage)
            delegate?.presentVC(playerVC)
        default:
            print("No Item")
        }
    }
    
    func presentLoginVC() {
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        delegate?.presentVC(loginVC)
    }
}
extension BaseViewModel : CarousalImageDelegate {
    func setImageFor(_ imageView: UIImageView, for index: Int) {
        if let urlString = baseDataModel?.data?[0].items?[index].imageUrlForCarousel{
            let url = URL(string: urlString)
            imageView.sd_setImage(with: url)
        }
        
    }
    
}















