//
//  APIManager+Player.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/28/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

extension RJILApiManager {
    
    class func getPlaybackRightsModel(contentId: String, completion: @escaping (Response<PlaybackRightsModel>) -> ()) -> URLSessionDataTask? {
        let url = playbackRightsURL + contentId
        let params = ["id": contentId, "showId": "", "uniqueId": JCAppUser.shared.unique, "deviceType": "stb"]
       let task = RJILApiManager.getReponse(path: url, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: true, isLoginRequired: true, reponseModelType: PlaybackRightsModel.self, completion: completion)
        return task
    }
}
