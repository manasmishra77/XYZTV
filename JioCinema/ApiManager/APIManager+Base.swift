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
        let postType: RequestType = (type == .home) ? .GET : .POST
        let isPageNum0 = (pageNum == 0)
        var headerType = RequestHeaderType.baseCommon
        var body: [String: String]? = nil
        if type == .disneyHome || type == .disneyKids || type == .disneyMovies || type == .disneyTVShow {
            headerType = .disneyCommon
            body = [:]
            body?["apikey"] = "l7xx56d0dec5d8b54fb4b8b4690698da302f"
        }

        RJILApiManager.getReponse(path: path, headerType: headerType, params: body, postType: postType, paramEncoding: .JSON, shouldShowIndicator: isPageNum0, reponseModelType: BaseDataModel.self) { (response) in
            if response.isSuccess {
                let newModel = RJILApiManager.clearingEmptyItems(response.model!)
                RJILApiManager.populateDataStore(type, isPageNum0: isPageNum0, model: newModel)
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
        }
    }
    class func getWatchListData(isDisney : Bool, type: BaseVCType, _ completion: APISuccessBlock?) {
        var path : String = ""
        if isDisney {
            if type == .disneyHome {
                RJILApiManager.getResumeWatchData(vcType: .disneyHome, completion!)
                return
            } else {
                path = (type == .disneyMovies) ? disneyMoviesWatchListUrl : disneyTvWatchListUrl
            }
        } else {
            path = (type == .movie) ? moviesWatchListUrl : tvWatchListUrl
        }
        let params = ["uniqueId": JCAppUser.shared.unique]
        RJILApiManager.getReponse(path: path, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: false, reponseModelType: BaseDataModel.self) {(response) in
            if response.isSuccess {
                if let dataContainer = response.model?.data?.first, (dataContainer.items?.count ?? 0) > 0 {
                    if isDisney {
                        if (type == .disneyMovies) {
                            JCDataStore.sharedDataStore.disneyMovieWatchList = response.model
                        } else {
                            JCDataStore.sharedDataStore.disneyTVWatchList = response.model
                        }
                    } else {
                        if (type == .movie) {
                            JCDataStore.sharedDataStore.moviesWatchList = response.model
                        } else {
                            JCDataStore.sharedDataStore.tvWatchList = response.model
                        }
                    }
                    completion?(true, nil)
                } else {
                    if isDisney {
                        if (type == .disneyMovies) {
                            JCDataStore.sharedDataStore.disneyMovieWatchList = nil
                        } else {
                            JCDataStore.sharedDataStore.disneyTVWatchList = nil
                        }
                    } else {
                        if (type == .movie) {
                            JCDataStore.sharedDataStore.moviesWatchList = nil
                        } else {
                            JCDataStore.sharedDataStore.tvWatchList = nil
                        }
                    }
                    completion?(true, "List is empty!!")
                }
            } else {
                completion?(false, response.errorMsg)
            }
            
        }
    }
    
    private class func clearingEmptyItems(_ model: BaseDataModel) -> BaseDataModel {
        var newModel = model
        newModel.data?.removeAll()
        for each in (model.data ?? []) {
            if (each.items?.count ?? 0 > 0) || (each.characterItems?.count ?? 0 > 0) {
                newModel.data?.append(each)
            }

        }
        return newModel
    }
    
    class func getResumeWatchData(vcType: BaseVCType = .home,_ completion: APISuccessBlock?) {
        let path = resumeWatchGetUrl
        let listId = (vcType == .home) ? 10 : 30
        let header = (vcType == .home) ? RequestHeaderType.baseCommon : RequestHeaderType.disneyCommon
        let params = ["uniqueId": JCAppUser.shared.unique, "listId": listId] as [String : Any]
        RJILApiManager.getReponse(path: path, headerType: header, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: false, reponseModelType: BaseDataModel.self) {(response) in
            if response.isSuccess {
                if let dataContainer = response.model?.data?.first, (dataContainer.items?.count ?? 0) > 0 {
                    if vcType == .home {
                        JCDataStore.sharedDataStore.resumeWatchList = response.model
                        JCDataStore.sharedDataStore.resumeWatchList?.data?[0].title = "Resume Watching"
                    } else {
                        JCDataStore.sharedDataStore.disneyResumeWatchList = response.model
                        JCDataStore.sharedDataStore.disneyResumeWatchList?.data?[0].title = "Resume Watching"
                    }
                    completion?(true, nil)
                } else {
                    if vcType == .home {
                        JCDataStore.sharedDataStore.resumeWatchList = nil
                    } else {
                        JCDataStore.sharedDataStore.disneyResumeWatchList = nil
                    }
                    completion?(true, "List is empty!!")
                }
            } else {
                completion?(false, response.errorMsg)
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
                    JCDataStore.sharedDataStore.genreData?.data?[0].title = "Genres"
                }
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
        }
        
    }
    class func getRecommendationData(_ completion: APISuccessBlock?) {
        let path = userRecommendationURL
        let params = ["uniqueId": JCAppUser.shared.unique, "jioId": JCAppUser.shared.uid]
        RJILApiManager.getReponse(path: path, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: false, reponseModelType: BaseDataModel.self) {(response) in
            if response.isSuccess {
                JCDataStore.sharedDataStore.userRecommendationList = response.model
                completion?(true, nil)
            } else {
                completion?(false, response.errorMsg)
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
        case .disneyHome:
            return disneyHomeDataUrl
        case .disneyKids:
            return disneyKidsDataUrl
        case .disneyMovies:
            return disneyMoviesDataUrl
        case .disneyTVShow:
            return disneyTVShowDataUrl
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
        case .disneyHome:
            JCDataStore.sharedDataStore.disneyData = model
        case .disneyMovies:
            JCDataStore.sharedDataStore.disneyMoviesData = model
        case .disneyKids:
            JCDataStore.sharedDataStore.disneyKidsData = model
        case .disneyTVShow:
            JCDataStore.sharedDataStore.disneyTVShowData = model
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
        case .disneyHome:
            JCDataStore.sharedDataStore.disneyData?.data?.append(model)
        case .disneyMovies:
            JCDataStore.sharedDataStore.disneyMoviesData?.data?.append(model)
        case .disneyKids:
            JCDataStore.sharedDataStore.disneyKidsData?.data?.append(model)
        case .disneyTVShow:
                JCDataStore.sharedDataStore.disneyTVShowData?.data?.append(model)
        }
    }
}

//extension RJILApiManager {
//
//    //Parse to fix datatype
//    func parseToFixDataType<T>(data: Any, dataTypes: [FixDataType], requireModelType: T.Type) -> T? {
//        for eachType in dataTypes {
//            
//            do {
//                let stringValue = try values.decodeIfPresent(String.self, forKey: .contentId)
//                self.contentId = stringValue
//            } catch {
//                let intValue = try values.decodeIfPresent(Int.self, forKey: .contentId)
//                self.contentId  = "\(intValue ?? -1)"
//            }
//        }
//        <#function body#>
//    }
//
//    enum FixDataType {
//        case integer
//        case float
//        case double
//        case string
//        case bool
//    }
//}















