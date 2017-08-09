//
//  RJILImageDownloader.swift
//  JioTV
//
//  Created by Techjini on 05/01/17.
//  Copyright © 2017 Techjini. All rights reserved.
//

import Foundation
import UIKit

class RJILImageDownloader {
    
    // MARK: - Shared Instance
    
    static let shared:RJILImageDownloader = RJILImageDownloader()
    
    // MARK: - Private Properties
    
    private var currentDownloads:[String] = []
    private var downloadQueue:OperationQueue = OperationQueue()
    private var downloadRWQueue:DispatchQueue = DispatchQueue(label: "com.app.downloadsRW",
                                                              qos: .background,
                                                              target: nil)
    
    private var imageCache = NSCache<NSString,UIImage>()
    
    // MARK: - Initializer
    
    init(){
        downloadQueue.maxConcurrentOperationCount = 5
    }
    
    // MARK: - Private Functions
    
    private func cacheImage(image:UIImage,url:String) {
        
        RJILImageDownloader.shared.imageCache.setObject(image, forKey: NSString(string: url))
    }

    private func addToCurrentDownloads(_ urlString:String) {
        self.downloadRWQueue.async(flags:.barrier){
            self.currentDownloads.append(urlString)
        }
    }
    
    private func removeFromCurrentDownloads(_ urlString:String) {
        self.downloadRWQueue.async(flags:.barrier){
            if let index = self.currentDownloads.index(of: urlString) {
                self.currentDownloads.remove(at: index)
            }
        }
    }
    
    // MARK: - Public Functions
    
    public func loadCachedImage(url:String) -> UIImage? {

        //print(url)
        
        if let image = RJILImageDownloader.shared.imageCache.object(forKey: NSString(string: url)) {
            return image
        }
        
        return nil
    }
    
    public func flushImageCache() {
        self.imageCache.removeAllObjects()
    }
    
    static func image(forURLString urlString:String, shouldCache:Bool, completion:@escaping(UIImage?,String)->Void){
        let downloader = RJILImageDownloader()
        downloader._getImage(forURLString: urlString, shouldCache: shouldCache, completion: completion)
    }
    
    public func _getImage(forURLString urlString:String, shouldCache:Bool, completion:@escaping(UIImage?,String)->Void){
        
        
        if shouldCache {
            //Check if image available in cache
            if let cachedImage = loadCachedImage(url: urlString){
                completion(cachedImage,urlString)
            }
        }
        
        //Not Cached download if required
        
        if currentDownloads.contains(urlString){
            return
        }
        
        weak var weakSelf = self
        
        self.addToCurrentDownloads(urlString)
        
        if let url = URL(string: urlString) {
            
            RJILApiManager.defaultManager.get(request: URLRequest(url: url)){(data, response, error) in
                
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        if shouldCache == true {
                            self.cacheImage(image: image, url: urlString)
                        }
                        weakSelf?.removeFromCurrentDownloads(urlString)
                        completion(image,urlString)
                    }else {
                        weakSelf?.removeFromCurrentDownloads(urlString)
                        completion(nil,urlString)
                    }
                }else {
                    //print("Failed to download image " + urlString)
                    weakSelf?.removeFromCurrentDownloads(urlString)
                    completion(nil,urlString)
                }
            }
        }
    }
    
    public func downloadImage(urlString:String, shouldCache:Bool, completion:@escaping(UIImage?)->Void){
      
        if currentDownloads.contains(urlString){
            return
        }
        
        
        weak var weakSelf = self
                self.addToCurrentDownloads(urlString)

        if let url = URL(string: urlString) {
            
            RJILApiManager.defaultManager.get(request: URLRequest(url: url)){(data, response, error) in
                
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        if shouldCache == true {
                            self.cacheImage(image: image, url: urlString)
                        }
                        weakSelf?.removeFromCurrentDownloads(urlString)
                        completion(image)
                    }else {
                        weakSelf?.removeFromCurrentDownloads(urlString)
                        completion(nil)
                    }
                }else {
                    weakSelf?.removeFromCurrentDownloads(urlString)
                    completion(nil)
                }
            }
        }
        
        
       
    }
}
