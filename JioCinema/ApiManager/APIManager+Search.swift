//
//  APIManager+Search.swift
//  JioCinema
//
//  Created by Manas Mishra on 04/09/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

extension RJILApiManager {
    class func getSearchData(key: String, _ completion: @escaping APISuccessBlock) -> URLSessionDataTask? {
        let path = preditiveSearchURL
        let params = ["q": key]
       let task = RJILApiManager.getReponse(path: path, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: true, reponseModelType: BaseDataModel.self) {(response) in
            if response.isSuccess {
                JCDataStore.sharedDataStore.searchData = response.model
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
        }
        return task
    }
    class func getTrendingResult(completion: @escaping (_ response: Response<JCTrendingSearchTextSuperModel>) -> ()) -> URLSessionDataTask? {
        let path = TrendingSearchTextURL
        let task = RJILApiManager.getReponse(path: path, postType: .GET, reponseModelType: JCTrendingSearchTextSuperModel.self, completion: completion)
        return task
    }
}


