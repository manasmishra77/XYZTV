//
//  APIManager+Base.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit


struct Response<T> {
    var model: T?
    var isSuccess: Bool = false
    var errorMsg: String?
}

enum RequestType: String {
    case POST
    case GET
    case PUT
}
struct NoModel: Codable {
    
}


extension RJILApiManager {
    class func getBaseModel(pageNum: Int ,type: BaseVCType, completion: @escaping APISuccessBlock) {
        let path = getPathForVC(type) + "\(pageNum)"
        let isPageNum0 = (pageNum == 0)
        RJILApiManager.getReponse(path: path, postType: .GET, paramEncoding: .URL, shouldShowIndicator: isPageNum0, reponseModelType: BaseDataModel.self) { (response) in
            if response.isSuccess {
                RJILApiManager.populateDataStore(type, isPageNum0: isPageNum0, model: response.model!)
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
        }
    }
    class func getWatchListData(type: BaseVCType, _ completion: @escaping APISuccessBlock) {
        let path = (type == .movie) ? moviesWatchListUrl : tvWatchListUrl
        let params = ["uniqueId": JCAppUser.shared.unique]
        RJILApiManager.getReponse(path: path, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: false, reponseModelType: BaseDataModel.self) {(response) in
            if response.isSuccess {
                if (type == .movie) {
                    JCDataStore.sharedDataStore.moviesWatchList = response.model
                } else {
                    JCDataStore.sharedDataStore.tvWatchList = response.model
                }
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
            
        }
    }
    
    
    
    class func getResumeWatchData(vcType: BaseVCType = .home,_ completion: @escaping APISuccessBlock) {
        let path = (vcType == .home) ? resumeWatchGetUrl : disneyResumeWatchListUrl
        let params = ["uniqueId": JCAppUser.shared.unique]
        RJILApiManager.getReponse(path: path, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: false, reponseModelType: BaseDataModel.self) {(response) in
            if response.isSuccess {
                if vcType == .home {
                    JCDataStore.sharedDataStore.resumeWatchList = response.model
                    JCDataStore.sharedDataStore.resumeWatchList?.data?[0].title = "Resume Watching"
                } else {
                    JCDataStore.sharedDataStore.disneyResumeWatchList = response.model
                    JCDataStore.sharedDataStore.disneyResumeWatchList?.data?[0].title = "Resume Watching"
                }
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
            
        }
    }
    
    class func getLanGenreData(isLang: Bool, _ completion: @escaping APISuccessBlock) {
        let path = isLang ? languageListUrl : genreListUrl
        RJILApiManager.getReponse(path: path, params: nil, postType: .GET, paramEncoding: .URL, shouldShowIndicator: false, reponseModelType: BaseDataModel.self) {(response) in
            if response.isSuccess {
                if isLang {
                    JCDataStore.sharedDataStore.languageData = response.model
                    JCDataStore.sharedDataStore.languageData?.data?[0].title = "Languages"
                } else {
                    JCDataStore.sharedDataStore.genreData = response.model
                    JCDataStore.sharedDataStore.languageData?.data?[0].title = "Genres"
                }
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
        }
        
    }
    class func getRecommendationData(_ completion: @escaping APISuccessBlock) {
        let path = userRecommendationURL
        let params = ["uniqueId": JCAppUser.shared.unique, "jioId": JCAppUser.shared.uid]
        RJILApiManager.getReponse(path: path, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: false, reponseModelType: BaseDataModel.self) {(response) in
            if response.isSuccess {
                JCDataStore.sharedDataStore.userRecommendationList = response.model
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
        }
    }
    
    
    private class func getPathForVC(_ type: BaseVCType) -> String {
        switch type {
        case .home:
            return homeDataUrl
        case .movie:
            return moviesDataUrl
        case .tv:
            return tvDataUrl
        case .music:
            return musicDataUrl
        case .clip:
            return clipsDataUrl
        case .search:
            return homeDataUrl
        case .disney:
            return disneyHomeDataUrl
        }
    }
    private class func populateDataStore(_ vcType: BaseVCType, isPageNum0: Bool, model: BaseDataModel) {
        if isPageNum0 {
            RJILApiManager.setDataStore(vcType, model: model)
        } else {
            if let dataContainerArr = model.data {
                for each in dataContainerArr {
                    appendInDataStore(vcType, model: each)
                }
            }
        }
    }
    
    private class func setDataStore(_ vcType: BaseVCType, model: BaseDataModel) {
        switch vcType {
        case .home:
            JCDataStore.sharedDataStore.homeData = model
        case .movie:
            JCDataStore.sharedDataStore.moviesData = model
        case .tv:
            JCDataStore.sharedDataStore.tvData = model
        case .music:
            JCDataStore.sharedDataStore.musicData = model
        case .clip:
            JCDataStore.sharedDataStore.clipsData = model
        case .search:
            JCDataStore.sharedDataStore.searchData = model
        case .disney:
            JCDataStore.sharedDataStore.disneyData = model
        }
    }
    
    private class func appendInDataStore(_ vcType: BaseVCType, model: DataContainer) {
        switch vcType {
        case .home:
            JCDataStore.sharedDataStore.homeData?.data?.append(model)
        case .movie:
            JCDataStore.sharedDataStore.moviesData?.data?.append(model)
        case .tv:
            JCDataStore.sharedDataStore.tvData?.data?.append(model)
        case .music:
            JCDataStore.sharedDataStore.musicData?.data?.append(model)
        case .clip:
            JCDataStore.sharedDataStore.clipsData?.data?.append(model)
        case .search:
            JCDataStore.sharedDataStore.searchData?.data?.append(model)
        case .disney:
            JCDataStore.sharedDataStore.disneyData?.data?.append(model)
        }
    }
}















