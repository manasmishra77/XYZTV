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
    
    override init() {
        super.init()
    }
    
    // MARK: - TVTopShelfProvider protocol
    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .inset
    }
    var topShelfItems: [TVContentItem] {
        var topShelfItemArray = [TVContentItem]()
        if let shelfModelArray = self.webServiceCallForTopShelfItems() {
            for eachShelfModel in shelfModelArray {
                 let tvContentIdentifier = TVContentIdentifier(identifier: eachShelfModel.name ?? "", container: nil)
                    let topShelfItem = TVContentItem(contentIdentifier: tvContentIdentifier)
                    topShelfItem.imageURL = URL(string: eachShelfModel.imageUrlForCarousel)
                    if let displayUrl = self.urlFor(item: eachShelfModel){
                        topShelfItem.displayURL = displayUrl
                    }
                    topShelfItem.imageShape = .HDTV
                    topShelfItemArray.append(topShelfItem)
            }
        }
        return topShelfItemArray
    }
    
    private func urlFor(item: VODTopShelfModel) -> URL? {
        var components = URLComponents()
        components.scheme = "jCApp"
        let itemIdQueryItem = URLQueryItem(name: "contentId", value: item.id)
        let latestIdQueryItem = URLQueryItem(name: "latestId", value: item.latestId)
        let isPlaylistQueryItem = URLQueryItem(name: "isPlaylist", value: "\(item.isPlaylist ?? false)")
        let playlistIdQueryItem = URLQueryItem(name: "playlistId", value: item.playlistId)
        let videoTypeQueryItem = URLQueryItem(name: "videoType", value: "\(item.app?.type ?? 0)")
        components.queryItems = [itemIdQueryItem, latestIdQueryItem, isPlaylistQueryItem, playlistIdQueryItem, videoTypeQueryItem]
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
























