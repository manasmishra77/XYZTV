//
//  BaseViewModel.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

typealias TableCellItemsTuple = (title: String, items: [Item], cellType: ItemCellType)

class BaseViewModel: NSObject ,JCCarouselCellDelegate{
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
            return JCDataStore.sharedDataStore.disneyData
        case .disneyTVShow:
            return JCDataStore.sharedDataStore.disneyData
        case .disneyMovies:
            return JCDataStore.sharedDataStore.disneyData
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
        default:
            return nil
        }
    }
//    if self.baseViewModel.vcType == .disneyHome{
//    let carouselViewForDisney = Bundle.main.loadNibNamed("CarouselViewForDisney", owner: self, options: nil)?.first as! CarouselViewForDisney
//
//    if carousalView == nil {
//    if let items = JCDataStore.sharedDataStore.disneyData?.data?[0].items{
//    carousalView = Utility.getHeaderForTableView(for: self, with: items)
//    carousalView?.frame = CGRect(x: 0, y: 0, width: 1920, height: 650)
//    }
//    }
//    carouselViewForDisney.viewForCarousel.addSubview(carousalView!)
//    return carouselViewForDisney
//    } else {
//    if carousalView == nil {
//    if let items = JCDataStore.sharedDataStore.disneyData?.data?[0].items {
//    carousalView = Utility.getHeaderForTableView(for: self, with: items)
//    }
//    }
//    return carousalView
//    }
    var carouselView : UIView? {
        switch vcType {
        case .disneyHome:
            let carouselViewForDisney = Bundle.main.loadNibNamed("CarouselViewForDisney", owner: self, options: nil)?.first as! CarouselViewForDisney
            
                if carousal == nil {
                if let items = JCDataStore.sharedDataStore.disneyData?.data?[0].items{
//                if let items = baseDataModel?.data?[0].items{
                carousal = Utility.getHeaderForTableView(for: self, with: items)
                carousal?.frame = CGRect(x: 0, y: 0, width: 1920, height: 650)
                }
                }
            carouselViewForDisney.viewForCarousel.addSubview(carousal!)
            carouselViewForDisney.delegate = self
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
        //getBaseWatchListData()
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
                let data = dataContainer[itemIndexTuple.1]
                if itemIndexTuple.1 == dataContainer.count - 2 {
                    // fetchHomeData()
                }
                return (title: data.title ?? "", items: data.items ?? [], cellType: .base)
            }
        case .watchlist:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                return (title: dataContainer.title ?? "", items: dataContainer.items ?? [], cellType: .base)
            }
        }
        return (title: "", items: [], cellType: .base)
    }
    
}

// MovieVC
fileprivate extension BaseViewModel {
    enum BaseDataType {
        case base
        case watchlist
    }
    fileprivate func getBaseWatchListData() {
        RJILApiManager.getWatchListData(type: vcType, baseAPIReponseHandler)
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
        case 2:
            print("2")
        case 3:
            print("3")
        default:
            return
        }
    }
    enum ButtonType : Int{
        case Movies = 1
        case TVShow = 2
        case Kids = 3
    }
}





















