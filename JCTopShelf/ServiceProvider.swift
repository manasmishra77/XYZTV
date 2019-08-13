//
//  ServiceProvider.swift
//  JCTopShelf
//
//  Created by manas on 22/01/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//


import Foundation
import TVServices



class ServiceProvider: NSObject, TVTopShelfProvider {
    
    let headingText = "JioCinema recommends"
    
    override init() {
        super.init()
    }
    
    // MARK: - TVTopShelfProvider protocol
    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .sectioned
    }
    var topShelfItems: [TVContentItem] {
        var topShelfItemArray = [TVContentItem]()
        
        let headingIdentifier = TVContentIdentifier(identifier: headingText, container: nil)
        let headingSection = TVContentItem(contentIdentifier: headingIdentifier)
        headingSection.title = headingText
        
        if let shelfModelArray = self.webServiceCallForTopShelfItems() {
            for eachShelfModel in shelfModelArray {
                 let tvContentIdentifier = TVContentIdentifier(identifier: eachShelfModel.name ?? "", container: nil)
                    let topShelfItem = TVContentItem(contentIdentifier: tvContentIdentifier)
                    topShelfItem.imageURL = URL(string: eachShelfModel.imageUrlLandscapContent)
                    if let displayUrl = self.urlFor(item: eachShelfModel){
                        topShelfItem.displayURL = displayUrl
                    }
                    topShelfItem.imageShape = .HDTV
                    topShelfItemArray.append(topShelfItem)
            }
        }
        headingSection.topShelfItems = topShelfItemArray
        return [headingSection]
        
    }
    
    private func urlFor(item: VODTopShelfModel) -> URL? {
        var components = URLComponents()
        components.scheme = "jCApp"
         //Don't change the sequence
        let itemIdQueryItem = URLQueryItem(name: "contentId", value: item.id)
        let latestIdQueryItem = URLQueryItem(name: "latestId", value: item.latestId)
        let isPlaylistQueryItem = URLQueryItem(name: "isPlaylist", value: "\(item.isPlaylist ?? false)")
        let playlistIdQueryItem = URLQueryItem(name: "playlistId", value: item.playlistId)
        let videoTypeQueryItem = URLQueryItem(name: "videoType", value: "\(item.app?.type ?? 0)")
        let tvStillImageQueryItem = URLQueryItem(name: "tvStillImageUrl", value: item.tvStill ?? "")
        components.queryItems = [itemIdQueryItem, latestIdQueryItem, isPlaylistQueryItem, playlistIdQueryItem, videoTypeQueryItem, tvStillImageQueryItem]
        return components.url
    }
    
    private func webServiceCallForTopShelfItems() -> [VODTopShelfModel]? {
        let dispatchGroup = DispatchGroup()
        var shelfModelArray: [VODTopShelfModel]? = nil
        dispatchGroup.enter()
        TopShelfConnectionManager.getTopShelfs { (isSuccess, items) in
            if isSuccess, let topShelfItems = items {
                shelfModelArray = topShelfItems
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        return shelfModelArray
    }
}
























