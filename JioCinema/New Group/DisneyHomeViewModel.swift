//
//  DisneyHomeViewModel.swift
//  JioCinema
//
//  Created by Manas Mishra on 22/10/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class DisneyHomeViewModel: BaseViewModel {
    
    fileprivate var baseModelIndex = 0
    fileprivate var resumeWatchModelIndex = 0
    fileprivate var characterModelIndex = 0
    fileprivate var homeTableIndexArray: [(DisneyHomeDataType, Int)] = []
    //Override BaseViewModel
    override func fetchData(completion: @escaping (Bool) -> ()) {
        viewResponseBlock = completion
        fetchAllDisneyHomeData()
    }
    override func getTableCellItems(for index: Int, completion: @escaping (Bool) -> ()) -> TableCellItemsTuple {
        return getHomeCellItems(for: index)
    }
    override func populateTableIndexArray() {
        self.populateHomeTableArray()
    }
    override var countOfTableView: Int {
        return homeTableIndexArray.count
    }
    override func heightOfTableHeader() -> CGFloat {
        return 750.0
    }
    override func itemCellLayoutType(index: Int) -> ItemCellLayoutType {
        let itemIndexTuple = homeTableIndexArray[index]
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data {
                let data = dataContainer[(itemIndexTuple.1)]
                let layout: ItemCellLayoutType = (data.items?[0].appType == .Movie) ? .potrait : .landscape
                return layout
            }
        case .reumeWatch:
            if (baseWatchListModel?.data?[itemIndexTuple.1]) != nil {
                
            }
        case .character:
            print("character")
        }
        return .landscape
    }
    
    
    // HOMEVC
    func getHomeCellItems(for index: Int) -> TableCellItemsTuple  {
        let itemIndexTuple = homeTableIndexArray[index]
        let layout = itemCellLayoutType(index: index)
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data {
                let data = dataContainer[itemIndexTuple.1]
                if itemIndexTuple.1 == dataContainer.count - 2 {
                     fetchBaseData()
                }
                return (title: data.title ?? "", items: data.items ?? [], cellType: .base, layout: layout)
            }
        case .reumeWatch:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                return (title: "Resume Watch List", items: dataContainer.items ?? [], cellType: .resumeWatchDisney, layout: layout)
            }
        case .character:
            if let dataContainer = JCDataStore.sharedDataStore.userRecommendationList?.data?[itemIndexTuple.1] {
                return (title: dataContainer.title ?? "", items: dataContainer.items ?? [], cellType: .base, layout: layout)
            }
        }
        return (title: "", items: [], cellType: .base, layout: .landscape)
    }
    
    func getDataForWatchListForDisneyMovieAndTv(_ type : BaseVCType) {
        RJILApiManager.getWatchListData(isDisney : true ,type: .disneyMovies, nil)
        RJILApiManager.getWatchListData(isDisney : true ,type: .disneyTVShow, nil)
    }
    func getDataForResumeWatch()  {
        if JCLoginManager.sharedInstance.isUserLoggedIn(){
            RJILApiManager.getResumeWatchData(vcType: .disneyHome, baseAPIReponseHandler)
        }
    }
    
    fileprivate func fetchAllDisneyHomeData() {
        fetchBaseData()
        RJILApiManager.getResumeWatchData(vcType: .disneyHome, baseAPIReponseHandler)
    }
    
    fileprivate func handleOnFailure(completion: @escaping (_ isSuccess: Bool) -> ()) {
        print("Api failed")
        completion(false)
    }
    fileprivate func populateHomeTableArray() {
        resetHomeVCTableIndexArray()
        appendInHomeTableIndex(from: baseDataModel?.data)
        insertInHomeTableIndex(from: baseWatchListModel?.data)
    }
    private func appendInHomeTableIndex(from baseContainer: [DataContainer]?) {
        guard let baseDataContainer = baseContainer else {return}
        let increaseBaseModelIndex = (baseDataContainer[0].isCarousal ?? false) ? 1 : 0
        baseModelIndex += increaseBaseModelIndex
        if increaseBaseModelIndex == 1 {
            for _ in 1..<baseDataContainer.count {
                homeTableIndexArray.append((.base, baseModelIndex))
                baseModelIndex += 1
            }
        } else {
            for _ in baseDataContainer {
                homeTableIndexArray.append((.base, baseModelIndex))
                baseModelIndex += 1
            }
        }
    }
    private func insertInHomeTableIndex(from watchListContainer: [DataContainer]?) {
        guard watchListContainer != nil else {return}
        homeTableIndexArray.insert((DisneyHomeDataType.reumeWatch, resumeWatchModelIndex), at: resumeWatchModelIndex)
    }
   
    
//    private func insertForHomeTableIndexRecommendation(from dataContainer: [DataContainer]?) {
//        guard let dataContainer = dataContainer else {return}
//        for each in dataContainer {
//            let pos = each.position ?? (4 + recommendationModelIndex)
//            insertInHomeTableIndexArray(at: pos, type: .recommendation, index: characterModelIndex)
//            characterModelIndex += 1
//        }
//    }
    private func insertInHomeTableIndexArray(at pos: Int, type: DisneyHomeDataType, index: Int) {
        if pos >= homeTableIndexArray.count {
            homeTableIndexArray.append((type, index))
        } else {
            homeTableIndexArray.insert((type, index), at: pos)
        }
    }
    private func resetHomeVCTableIndexArray() {
        homeTableIndexArray.removeAll()
        baseModelIndex = 0
        resumeWatchModelIndex = 0
        characterModelIndex = 0
    }
    
    enum DisneyHomeDataType {
        case base
        case reumeWatch
        case character
    }
}

//extension DisneyHomeViewModel: DisneyButtonTapDelegate {
//    func didTapOnCarouselItem(_ item: Any?) {
//        if let item = item {
//            delegate?.presentMetadataOfIcarousel(item)
//        }
//    }
//
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
