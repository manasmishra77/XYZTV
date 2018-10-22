//
//  CommonHomeViewModel.swift
//  JioCinema
//
//  Created by Manas Mishra on 22/10/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

/*
class CommonHomeViewModel: BaseViewModel {
    
    fileprivate var baseModelIndex = 0
    fileprivate var resumeWatchModelIndex = 0
    fileprivate var recommendationModelIndex = 0
    fileprivate var langModelIndex = 0
    fileprivate var genreModelIndex = 0
    fileprivate var homeTableIndexArray: [(HomeDataType, Int)] = []
    //Override BaseViewModel
    override func fetchData(completion: @escaping (Bool) -> ()) {
        viewResponseBlock = completion
        fetchAllHomeData()
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
    
    
    // HOMEVC
    func getHomeCellItems(for index: Int) -> TableCellItemsTuple  {
        let itemIndexTuple = homeTableIndexArray[index]
        switch itemIndexTuple.0 {
        case .base:
            if let dataContainer = baseDataModel?.data {
                let data = dataContainer[itemIndexTuple.1]
                if itemIndexTuple.1 == dataContainer.count - 2 {
                    // fetchHomeData()
                }
                return (title: data.title ?? "", items: data.items ?? [], cellType: .base)
            }
        case .reumeWatch:
            if let dataContainer = baseWatchListModel?.data?[itemIndexTuple.1] {
                return (title: dataContainer.title ?? "", items: dataContainer.items ?? [], cellType: .resumeWatch)
            }
        case .recommendation:
            if let dataContainer = JCDataStore.sharedDataStore.userRecommendationList?.data?[itemIndexTuple.1] {
                return (title: dataContainer.title ?? "", items: dataContainer.items ?? [], cellType: .base)
            }
        case .language:
            if let dataContainer = JCDataStore.sharedDataStore.languageData?.data?[itemIndexTuple.1] {
                return (title: dataContainer.title ?? "", items: dataContainer.items ?? [], cellType: .base)
            }
        case .genre:
            if let dataContainer = JCDataStore.sharedDataStore.genreData?.data?[itemIndexTuple.1] {
                return (title: dataContainer.title ?? "", items: dataContainer.items ?? [], cellType: .base)
            }
        }
        return (title: "", items: [], cellType: .base)
    }
    
    fileprivate func fetchAllHomeData() {
        fetchBaseData()
        RJILApiManager.getResumeWatchData(baseAPIReponseHandler)
        RJILApiManager.getRecommendationData(baseAPIReponseHandler)
        RJILApiManager.getLanGenreData(isLang: true, baseAPIReponseHandler)
        RJILApiManager.getLanGenreData(isLang: false, baseAPIReponseHandler)
    }
    
    fileprivate func handleOnFailure(completion: @escaping (_ isSuccess: Bool) -> ()) {
        print("Api failed")
        completion(false)
    }
    fileprivate func populateHomeTableArray() {
        resetHomeVCTableIndexArray()
        appendInHomeTableIndex(from: baseDataModel?.data)
        insertInHomeTableIndex(from: baseWatchListModel?.data)
        insertInHomeTableIndexLangGenre(type: .language, from: JCDataStore.sharedDataStore.languageData?.data)
        insertInHomeTableIndexLangGenre(type: .genre, from: JCDataStore.sharedDataStore.genreData?.data)
        insertForHomeTableIndexRecommendation(from: JCDataStore.sharedDataStore.userRecommendationList?.data)
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
        homeTableIndexArray.insert((HomeDataType.reumeWatch, resumeWatchModelIndex), at: resumeWatchModelIndex)
    }
    private func insertInHomeTableIndexLangGenre(type: HomeDataType, from dataContainer: [DataContainer]?) {
        guard dataContainer != nil else {return}
        var pos = 4
        if type == .language {
            pos = (JCDataStore.sharedDataStore.configData?.configDataUrls?.languagePosition) ?? 4
        } else {
            pos = (JCDataStore.sharedDataStore.configData?.configDataUrls?.genrePosition) ?? 6
        }
        insertInHomeTableIndexArray(at: pos, type: type, index: 0)
    }
    private func insertForHomeTableIndexRecommendation(from dataContainer: [DataContainer]?) {
        guard let dataContainer = dataContainer else {return}
        for each in dataContainer {
            let pos = each.position ?? (4 + recommendationModelIndex)
            insertInHomeTableIndexArray(at: pos, type: .recommendation, index: recommendationModelIndex)
            recommendationModelIndex += 1
        }
    }
    private func insertInHomeTableIndexArray(at pos: Int, type: HomeDataType, index: Int) {
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
        recommendationModelIndex = 0
        langModelIndex = 0
        genreModelIndex = 0
    }
    
    enum HomeDataType {
        case base
        case reumeWatch
        case recommendation
        case language
        case genre
    }
}

*/
