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
    fileprivate var isResumeWatchListUpdated = false

    var disneyButtonView : DisneyButtons?
    //Override BaseViewModel
    override init(_ vcType: BaseVCType) {
        super.init(vcType)
        NotificationCenter.default.addObserver(self, selector: #selector(onCallDisneyResumeWatchUpdate(_:)), name: AppNotification.reloadResumeWatchForDisney, object: nil)
    }
    override func fetchData(isFromDeepLinking: Bool = false, completion: @escaping (Bool) -> ()) {
        viewResponseBlock = completion
        fetchAllDisneyHomeData()
    }
    
    override func getTableCellItems(for index: Int, completion: @escaping (Bool) -> ()) -> BaseTableCellModel {
        return getHomeCellItems(for: index)
    }
    override func populateTableIndexArray() {
        self.populateHomeTableArray()
    }
    override var countOfTableView: Int {
        return homeTableIndexArray.count
    }

    override func itemCellLayoutType(index: Int) -> ItemCellLayoutType {
        let itemIndexTuple = homeTableIndexArray[index]
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data {
                let data = dataContainer[(itemIndexTuple.1)]
                let layout: ItemCellLayoutType = getLayoutOfCellForItemType(data.items?.first, data.characterItems?.first)
                return layout
            }
        case .reumeWatch:
            if (baseWatchListModel?.data?[itemIndexTuple.1]) != nil {
                return .landscapeForResume
            }
        case .character:
            print("character")
            return .potrait
        }
        return .landscapeWithLabels
    }
    override func getDataContainer(_ index: Int) -> DataContainer? {
        let itemIndexTuple = homeTableIndexArray[index]
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data?[itemIndexTuple.1] {
                return dataContainer
            }
        case .reumeWatch:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                return dataContainer
            }
        case .character:
//            if let dataContainer = baseDataModel?.data?[itemIndexTuple.1].
            break
        }
        return nil
    }
    override func reloadTableView() {
        populateHomeTableArray()
        viewResponseBlock?(true)
    }
    override func getUpdatedWatchListFor(vcType: BaseVCType) {
        if vcType == .disneyMovies {
            RJILApiManager.getWatchListData(isDisney: true, type: .disneyMovies, nil)
        } else if vcType == .disneyTVShow {
            RJILApiManager.getWatchListData(isDisney : true ,type: .disneyTVShow, nil)
        }
    }
    
    //Used when logging in
    override func fetchAfterLoginUserDataWithoutCompletion() {
        RJILApiManager.getResumeWatchData(vcType: .disneyHome, nil)
        RJILApiManager.getWatchListData(isDisney: true, type: .disneyMovies, nil)
        RJILApiManager.getWatchListData(isDisney : true ,type: .disneyTVShow, nil)
        isResumeWatchListUpdated = true
    }
    override func heightOfTableHeader(section: Int) -> CGFloat {
        if section == 0 {
            if let data = baseDataModel?.data, data.count > 0, data[0].isCarousal == true {
                return heightOfCarouselSection
            }
            return 0
        } else {
            return 200
        }
    }
    override func buttonView() -> DisneyButtons? {
                if disneyButtonView == nil {
                    //disneyButtonView?.delegate = self
                    disneyButtonView = Utility.getXib("DisneyButtons", type: DisneyButtons.self, owner: self)
                    disneyButtonView?.delegate = self
                    return disneyButtonView
                }
                return disneyButtonView
    }

    // HOMEVC
    override var isToReloadTableViewAfterLoginStatusChange: Bool {
        let isResumeWatchListAvailabaleInDataStore = (self.baseWatchListModel != nil)
        var reloadTable = false
        //When Resume watch get updated
        if isResumeWatchListUpdated {
            isResumeWatchListUpdated = false
            reloadTable = true
            return reloadTable
        } else {
            //After login cases
            var resumeWatchListStatusInHomeTableArray = false
            if homeTableIndexArray.count > 0 {
                resumeWatchListStatusInHomeTableArray = (homeTableIndexArray[resumeWatchModelIndex].0 == .reumeWatch)
            }
            if isResumeWatchListAvailabaleInDataStore, !resumeWatchListStatusInHomeTableArray {
                reloadTable = true
            } else if !isResumeWatchListAvailabaleInDataStore, resumeWatchListStatusInHomeTableArray {
                reloadTable = true
            }
            return reloadTable
        }
    }
    
    //notification listener
    //Used when resume watchlist get updated 
    @objc func onCallDisneyResumeWatchUpdate(_ notification:Notification) {
        self.fetchDisneyResumeDataWithoutCompletion()
        self.isResumeWatchListUpdated = true
    }
    
    func getHomeCellItems(for index: Int) -> BaseTableCellModel  {
        let itemIndexTuple = homeTableIndexArray[index]
        let layout = itemCellLayoutType(index: index)
        var baseTableCellModel = BaseTableCellModel(title: "", items: [], cellType: .base, layoutType: layout, sectionLanguage: .english, charItems: nil)
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainerArr = baseDataModel?.data {
                let data = dataContainerArr[itemIndexTuple.1]
                if itemIndexTuple.1 == dataContainerArr.count - 2 {
                     fetchBaseData()
                }
                baseTableCellModel.title = data.title
                baseTableCellModel.items = data.items
                baseTableCellModel.cellType = .disneyCommon
                baseTableCellModel.sectionLanguage = data.categoryLanguage
                baseTableCellModel.charItems = data.characterItems
                return baseTableCellModel
            }
        case .reumeWatch:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                baseTableCellModel.title = dataContainer.title
                baseTableCellModel.items = dataContainer.items
                baseTableCellModel.cellType = .resumeWatchDisney
                baseTableCellModel.sectionLanguage = .english
                baseTableCellModel.charItems = dataContainer.characterItems
                return baseTableCellModel
            }
        case .character:
            if let dataContainer = JCDataStore.sharedDataStore.userRecommendationList?.data?[itemIndexTuple.1] {
                baseTableCellModel.title = dataContainer.title
                baseTableCellModel.items = dataContainer.items
                baseTableCellModel.cellType = .disneyCommon
                baseTableCellModel.sectionLanguage = .english
                baseTableCellModel.charItems = dataContainer.characterItems
                return baseTableCellModel
            }
        }
        return baseTableCellModel
    }
    
    //Used when logging in
    func fetchDisneyResumeDataWithoutCompletion() {
        RJILApiManager.getResumeWatchData(vcType: .disneyHome, nil)
    }
    
    func getDataForWatchListForDisneyMovieAndTv(_ type : BaseVCType) {
        RJILApiManager.getWatchListData(isDisney: true, type: .disneyMovies, nil)
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
        getDataForWatchListForDisneyMovieAndTv(vcType)
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
         guard baseModelIndex > 0 else {return}
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

extension DisneyHomeViewModel : DisneyButtonsTapedDelegate {
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
    
    
}
