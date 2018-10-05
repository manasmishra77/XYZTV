//
//  BaseViewModel.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

typealias TableCellItemsTuple = (title: String, items: [Item], cellType: ItemCellType)

protocol BaseViewModelDelegate {
    func presentVC(_ vc: UIViewController)
    func presentMetadataOfIcarousel(_ itemId : Any)
}

class BaseViewModel: NSObject  {
    var isDisneyWatchlistAvailable = false
    var carousal : InfinityScrollView?
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
        switch vcType {
        case .disneyHome:
            let carouselViewForDisney = Bundle.main.loadNibNamed("CarouselViewForDisney", owner: self, options: nil)?.first as! CarouselViewForDisney
            
            if carousal == nil {
                if let items = JCDataStore.sharedDataStore.disneyData?.data?[0].items{
                    carousal = Utility.getHeaderForTableView(for: self, with: items)
                    
                }
            }
            if let carousal = carousal {
                carousal.frame = CGRect(x: 0, y: 0, width: 1920, height: 650)
                carouselViewForDisney.addSubview(carousal)
                carouselViewForDisney.delegate = self
            }
            return carouselViewForDisney
        default:
            if carousal == nil {
                if let items = baseDataModel?.data?[0].items {
                    carousal = Utility.getHeaderForTableView(for: self, with: items)
                }
            }
            return carousal
        }
    }
    
    init(_ vcType: BaseVCType) {
        self.vcType = vcType
    }
    var delegate: BaseViewModelDelegate?
    let vcType: BaseVCType
    var pageNumber = 0 // Reference for Downloading base page
    var errorMsg: String?
    
    var totalPage: Int {// Reference for Downloading base page
        return baseDataModel?.totalPages ?? 0
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
    
    fileprivate var baseTableIndexArray: [(BaseDataType, Int)] = []
    fileprivate var baseModelIndex = 0
    fileprivate var baseWatchListIndex = 0
    
    func fetchData(completion: @escaping (_ isSuccess: Bool) -> ()) {
        viewResponseBlock = completion
        fetchBaseData()
        print(ButtonType.Movies.rawValue)
        getBaseWatchListData()
    }
    func getDataForWatchList() {
         RJILApiManager.getWatchListData(isDisney : true ,type: .disneyMovies, nil)
         RJILApiManager.getWatchListData(isDisney : true ,type: .disneyTVShow, nil)
    }
    func fetchBaseData() {
        RJILApiManager.getBaseModel(pageNum: pageNumber, type: vcType) {[unowned self] (isSuccess, errMsg) in
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
    
    func populateTableIndexArray() {
        populateBaseTableArray()
    }
    
    func getTableCellItems(for index: Int, completion: @escaping (_ isSuccess: Bool) -> ()) -> TableCellItemsTuple {
        viewResponseBlock = completion
        let itemIndexTuple = baseTableIndexArray[index]
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data {
                let data = dataContainer[(itemIndexTuple.1)]
                if itemIndexTuple.1 == dataContainer.count - 2 {
                    // fetchHomeData()
                }
                return (title: data.title ?? "", items: data.items ?? [], cellType: .base)
            }
        case .watchlist:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                return (title: dataContainer.title ?? "Watch List", items: dataContainer.items ?? [], cellType: .base)
            }
        }
        return (title: "", items: [], cellType: .base)
    }
//    func callWebServiceForDisneyWatchlist()
//    {
//        RJILApiManager.getWatchListData(isDisney : false, type: .tv) {[unowned self] (isSuccess, errorMsg) in
//            guard isSuccess else {return}
//            if (JCDataStore.sharedDataStore.tvWatchList?.data?[0].items?.count)! > 0 {
//                self.isDisneyWatchlistAvailable = true
//                self.changingDataSourceForBaseTableView()
//                DispatchQueue.main.async {
//                    JCDataStore.sharedDataStore.disneyMovieWatchList?.data?[0].title = "Watch List"
////                    if baseTableView != nil{
////                        baseTableView.reloadData()
////                        baseTableView.layoutIfNeeded()
////                    }
//                }
//            }
//        }
//    }
//    func changingDataSourceForBaseTableView(){
//        //dataItemsForTableview.removeAll()
//        if let disneyData = JCDataStore.sharedDataStore.disneyData?.data {
//            if !JCLoginManager.sharedInstance.isUserLoggedIn() {
//                isDisneyWatchlistAvailable = false
//            }
////            dataItemsForTableview = tvData
//            if baseDataModel?.data?[0].isCarousal ?? false {
////                dataItemsForTableview.remove(at: 0)
//            }
//            if isDisneyWatchlistAvailable {
//                if let watchListData = JCDataStore.sharedDataStore.disneyTVWatchList?.data?[0], (watchListData.items?.count ?? 0) > 0 {
// //                   dataItemsForTableview.insert(watchListData, at: 0)
////                }
////                if let watchListData = JCDataStore.sharedDataStore.disneyMovieWatchList?.data?[0], (watchListData.items?.count ?? 0) > 0 {
////                    dataItemsForTableview.insert(watchListData, at: 0)
//                }
//            }
//        }
//    }
}

// MovieVC
fileprivate extension BaseViewModel {
    enum BaseDataType {
        case base
        case watchlist
    }
    fileprivate func getBaseWatchListData() {
        if vcType == .disneyMovies || vcType == .disneyTVShow {return}
        RJILApiManager.getWatchListData(isDisney : true ,type: vcType, baseAPIReponseHandler)
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
        baseTableIndexArray.insert((BaseDataType.watchlist, baseWatchListIndex), at: baseWatchListIndex)
    }
    
    private func resetBaseTableIndexArray() {
        baseTableIndexArray.removeAll()
        baseModelIndex = 0
        baseWatchListIndex = 0
    }
}
extension BaseViewModel: DisneyButtonTapDelegate {
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

extension BaseViewModel: JCCarouselCellDelegate {
    func didTapOnCarouselItem(_ item: Any?) {
        if let item = item {
            delegate?.presentMetadataOfIcarousel(item)
        }
    }
}
















