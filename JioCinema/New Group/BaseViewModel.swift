//
//  BaseViewModel.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

typealias TableCellItemsTuple = (title: String, items: [Item], cellType: ItemCellType, layout: ItemCellLayoutType)

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
        if carousal == nil {
            if let items = baseDataModel?.data?[0].items {
                carousal = Utility.getHeaderForTableView(for: self, with: items)
                
                DispatchQueue.main.async {
                    if self.vcType == .disneyHome {
                        self.carousal?.viewOfButtons.isHidden = false
                        self.carousal?.disneyViewHeight.constant = 130
                    }
                    else {
                        self.carousal?.viewOfButtons.isHidden = true
                        self.carousal?.disneyViewHeight.constant = 0
                    }
                }
                

            }
        }
        return carousal
    }
    
    init(_ vcType: BaseVCType) {
        self.vcType = vcType
        super.init()
        if self.vcType == .disneyHome {
            NotificationCenter.default.addObserver(self, selector: #selector(onCallDisneyResumeWatch(_:)), name: reloadDisneyResumeWatch, object: nil)
        }    }
   
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
        if vcType == .disneyMovies || vcType == .disneyTVShow {
            populateBaseTableArray()
            viewResponseBlock?(true)
        }
    }
    
    fileprivate var baseTableIndexArray: [(BaseDataType, Int)] = []
    fileprivate var baseModelIndex = 0
    fileprivate var baseWatchListIndex = 0
    
    @objc func fetchData(completion: @escaping (_ isSuccess: Bool) -> ()) {
        viewResponseBlock = completion
        fetchBaseData()
        print(ButtonType.Movies.rawValue)
        getBaseWatchListData()
    }
    func getDataForWatchList(_ type : BaseVCType) {
         RJILApiManager.getWatchListData(isDisney : true ,type: .disneyMovies, nil)
         RJILApiManager.getWatchListData(isDisney : true ,type: .disneyTVShow, nil)
    }
    func fetchBaseData() {
        guard pageNumber < totalPage else {return}
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
    
    func heightOfTableHeader()-> CGFloat {
        return vcType == .disneyHome ? 780 : 650
    }
    
    func heightOfTableRow(_ index: Int) -> CGFloat {
        let layout = itemCellLayoutType(index: index)
        let height: CGFloat = (layout == .potrait) ? rowHeightForPotrait : rowHeightForLandscape
        return height
    }
    
    func populateTableIndexArray() {
        populateBaseTableArray()
    }
    
    func itemCellLayoutType(index: Int) -> ItemCellLayoutType {
        let itemIndexTuple = baseTableIndexArray[index]
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data {
                let data = dataContainer[(itemIndexTuple.1)]
                let layout: ItemCellLayoutType = (data.items?[0].appType == .Movie) ? .potrait : .landscape
                return layout
            }
        case .watchlist:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                var layout: ItemCellLayoutType = (dataContainer.items?[0].appType == .Movie) ? .potrait : .landscape
                layout = (vcType == .disneyHome) ? .landscape : layout
                return layout
            }
        }
        return .landscape
    }
    
    
    func getTableCellItems(for index: Int, completion: @escaping (_ isSuccess: Bool) -> ()) -> TableCellItemsTuple {
        viewResponseBlock = completion
        let itemIndexTuple = baseTableIndexArray[index]
        let layout = itemCellLayoutType(index: index)
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data {
                let data = dataContainer[(itemIndexTuple.1)]
                if itemIndexTuple.1 == dataContainer.count - 1 {
                    fetchBaseData()
                }
                return (title: data.title ?? "", items: data.items ?? [], cellType: .base, layout: layout)
            }
        case .watchlist:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                let cellType: ItemCellType = (vcType == .disneyHome) ? .resumeWatchDisney : .base
                return (title: dataContainer.title ?? "Watch List", items: dataContainer.items ?? [], cellType: cellType, layout: layout)
            }
        }
        return (title: "", items: [], cellType: .base, layout: .landscape)
    }
    
    //notification listener
    @objc func onCallDisneyResumeWatch(_ notification:Notification) {
        self.getBaseWatchListData()
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
//extension BaseViewModel: DisneyButtonTapDelegate {
//    func presentVCOnButtonTap(tag: Int) {
//        switch tag {
//        case 1:
//            let disneyMovies = BaseViewController(.disneyMovies)
//            delegate?.presentVC(disneyMovies)
//        case 2:
//            let disneyTVShow = BaseViewController(.disneyTVShow)
//            delegate?.presentVC(disneyTVShow)
//        case 3:
//            let disneyKids = BaseViewController(.disneyKids)
//            delegate?.presentVC(disneyKids)
//        default:
//            return
//        }
//    }
//    enum ButtonType : Int {
//        case Movies = 1
//        case TVShow = 2
//        case Kids = 3
//    }
//}

extension BaseViewModel: JCCarouselCellDelegate {
    func didTapOnCarouselItem(_ item: Any?) {
        if let item = item {
            delegate?.presentMetadataOfIcarousel(item)
        }
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
















