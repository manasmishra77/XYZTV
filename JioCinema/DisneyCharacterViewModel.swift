//
//  DisneyCharacterViewModel.swift
//  JioCinema
//
//  Created by Shweta Adagale on 22/02/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
protocol DisneyCharacterTableReloadDelegate {
    func tableReloadWhenDataFetched()
}
class DisneyCharacterViewModel: NSObject {
    var charHeroData : CharacterItemSuperModel?
    
    var delegate : DisneyCharacterTableReloadDelegate?
    var presentVCdelegate : BaseViewModelDelegate?

    
    fileprivate var itemAfterLogin: Item? = nil
    fileprivate var categoryIndexAfterLogin: Int? = nil
    fileprivate var categoryNameAfterLogin: String? = nil
    func getLayout(tabid: String) -> ItemCellLayoutType {
        if tabid == "0"{
            return .potrait
        } else if tabid == "6"{
            return .landscapeWithLabels
        } else {
            return .landscapeWithTitleOnly
        }
    }
    func countOfItems()-> Int{
        return charHeroData?.data?.count ?? 0
    }
    func heightOfRowAt(indexpath: IndexPath) -> CGFloat {
        if charHeroData?.data?[indexpath.row].tabId == "0" {
            return rowHeightForPotrait
        } else {
            return rowHeightForLandscape
        }
    }
    func getCellData(indexpath : IndexPath) -> BaseTableCellModel {
        var cellData = BaseTableCellModel(title: "" , items: nil, cellType: .disneyCommon, layoutType: .landscapeWithTitleOnly, sectionLanguage: .english, charItems: nil)
        if let charItem = charHeroData?.data {
            let layout = getLayout(tabid: charItem[indexpath.row].tabId ?? "1")
            cellData.title = charItem[indexpath.row].name
            cellData.items = charItem[indexpath.row].items
            cellData.layoutType = layout
        }
        return cellData
    }
    func callWebserviceForCharacterHeros(id : String?){
        guard let id = id else { return }
        let url = disneyCharacterherosDataUrl.appending(id)
        RJILApiManager.getReponse(path: url, postType: .GET, reponseModelType: CharacterItemSuperModel.self) {[weak self](response) in
            guard let self = self else {
                return
            }
            guard response.isSuccess else {
                return
            }
            let tempData = response.model
            self.charHeroData = tempData
            DispatchQueue.main.async {
                self.delegate?.tableReloadWhenDataFetched()
            }
        }
    }
    func checkLoginAndPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int) {
        if(JCLoginManager.sharedInstance.isUserLoggedIn()) {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            prepareToPlay(itemToBePlayed, categoryName: categoryName, categoryIndex: categoryIndex)
        } else {
            self.itemAfterLogin = itemToBePlayed
            self.categoryIndexAfterLogin = categoryIndex
            self.categoryNameAfterLogin = categoryName
            presentLoginVC()
        }
    }
    func presentLoginVC() {
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        presentVCdelegate?.presentVC(loginVC)
    }
    func prepareToPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int) {
        switch itemToBePlayed.appType {
        case .Clip, .Music, .Trailer:
            let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: itemToBePlayed.appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "",latestId: itemToBePlayed.latestId, isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: "DisneyCharacterScreen", fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "", isDisney: true, audioLanguage: itemToBePlayed.audioLanguage)
            presentVCdelegate?.presentVC(playerVC)
        case .Episode:
            let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: itemToBePlayed.appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "",latestId: itemToBePlayed.latestId, isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: "DisneyCharacterScreen", fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "", isDisney: true, audioLanguage: itemToBePlayed.audioLanguage)
            presentVCdelegate?.presentVC(playerVC)
        case .Movie:
            if itemToBePlayed.isPlaylist ?? false {
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: itemToBePlayed.appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false,playListId: itemToBePlayed.playlistId ?? "",latestId: itemToBePlayed.latestId, fromScreen: "DisneyCharacterScreen", fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "", isDisney: true, audioLanguage: itemToBePlayed.audioLanguage)
                presentVCdelegate?.presentVC(playerVC)
            } else {
                print("Play Movie")
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: itemToBePlayed.appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false,latestId: itemToBePlayed.latestId, fromScreen: "DisneyCharacterScreen", fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "", isDisney: true, audioLanguage: itemToBePlayed.audioLanguage)
                presentVCdelegate?.presentVC(playerVC)
            }
        default:
            print("No Item")
        }
        
    }
    func playItemAfterLogin() {
        checkLoginAndPlay(itemAfterLogin!, categoryName: categoryNameAfterLogin!, categoryIndex: categoryIndexAfterLogin!)
        self.itemAfterLogin = nil
        self.categoryIndexAfterLogin = nil
        self.categoryNameAfterLogin = nil
    }
    
}
extension DisneyCharacterViewModel {
    func itemCellTapped(_ selectedIndex: Int, _ item: Item) {

        switch item.appType {
        case .Movie , .TVShow:
            let metadataVC = Utility.sharedInstance.prepareMetadata(item.id ?? "", appType: item.appType, fromScreen: "DisneuCharacterScreen", categoryName: "", categoryIndex: selectedIndex, tabBarIndex: nil, shouldUseTabBarIndex: false, isMetaDataAvailable: false, metaData: nil, modelForPresentedVC: nil, isDisney: true, defaultAudioLanguage: item.audioLanguage)
            self.presentVCdelegate?.presentVC(metadataVC)
        
        case .Clip:
            checkLoginAndPlay(item, categoryName: "", categoryIndex: selectedIndex)
        default:
            return
        }

    }
    
    func didTapOnCharacterItem(_ baseCell: BaseTableViewCell?, _ charItem: DisneyCharacterItems) {
        return
    }
    
    
}
