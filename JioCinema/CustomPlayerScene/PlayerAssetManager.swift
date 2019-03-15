//
//  PlayerAssetManager.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/29/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import AVKit

private func globalNotificationQueue() -> DispatchQueue {
    var globalQueue: DispatchQueue? = nil
    var getQueueOnce: Int = 0
    if (getQueueOnce == 0) {
        globalQueue = DispatchQueue(label: "tester notify queue")
    }
    getQueueOnce = 1
    return globalQueue!
}

protocol PlayerAssetManagerDelegate: NSObjectProtocol {
    func setAVAssetInPlayerItem(asset: AVURLAsset)
}

class PlayerAssetManager: NSObject {
    var asset: AVURLAsset?
    var delegate: PlayerAssetManagerDelegate?
    let PLAYABLE_KEY = "playable"
    var isFps = false
    var playbackDataModel: PlaybackRightsModel?
    let URL_SCHEME_NAME = "skd"
    let URL_GET_KEY =  "http://prod.media.jio.com/apis/06758e99be484fca56fb/v3/fps/getkey"
    let URL_GET_CERT = "http://prod.media.jio.com/apis/06758e99be484fca56fb/v3/fps/getcert"
    
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    
    init(playBackModel: PlaybackRightsModel, isFps: Bool, listener: NSObject) {
        super.init()
        delegate = listener as? PlayerAssetManagerDelegate
        self.isFps = isFps
        if (isFps) {
        let urlString = playBackModel.url ?? playBackModel.aesUrl
        asset = AVURLAsset(url: URL(string: urlString!)!)
            asset?.resourceLoader.setDelegate(self, queue: globalNotificationQueue())
            let requestedKeys: [Any] = [PLAYABLE_KEY]
            // Tells the asset to load the values of any of the specified keys that are not already loaded.
            asset?.loadValuesAsynchronously(forKeys: requestedKeys as? [String] ?? [String](), completionHandler: {() -> Void in
                DispatchQueue.main.async(execute: {() -> Void in
                    /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                    self.prepare(toPlay: self.asset!, withKeys: PlayerAssetManager.assetKeysRequiredToPlay)
                })
            })
        }
        else {
            handleAESStreamingUrl(videoUrl: playBackModel.aesUrl!)
        }
    }
    
    func handleAESStreamingUrl(videoUrl: String) {
        if JCDataStore.sharedDataStore.cdnEncryptionFlag {
            let videoUrl = URL(string: videoUrl)
            if let absoluteUrlString = videoUrl?.absoluteString {
                let changedUrl = absoluteUrlString.replacingOccurrences(of: (videoUrl?.scheme ?? ""), with: "fakeHttp")
                let headerValues = ["ssotoken" : JCAppUser.shared.ssoToken]
                let header = ["AVURLAssetHTTPHeaderFieldsKey": headerValues]
                guard let assetUrl = URL(string: absoluteUrlString) else {
                    return
                }
                asset = AVURLAsset(url: assetUrl, options: header)
                asset?.resourceLoader.setDelegate(self, queue: DispatchQueue(label: "testVideo-delegateQueue"))
            }
        } else {
            guard let assetUrl = URL(string: videoUrl) else { return }
            asset = AVURLAsset(url: assetUrl)
        }
// //vinit_comment        guard let asset = asset else {
//            return
//        }
        delegate?.setAVAssetInPlayerItem(asset: asset!)
    }
    
    func prepare(toPlay asset: AVURLAsset, withKeys requestedKeys: [String]) {
        
        for key in PlayerAssetManager.assetKeysRequiredToPlay {
            var error: NSError?
            if asset.statusOfValue(forKey: key, error: &error) == .failed {
                let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
                let _ = String.localizedStringWithFormat(stringFormat, key)
                return
            }
        }
        // We can't play this asset.
        if !asset.isPlayable {
            let _ = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
            return
        }
        delegate?.setAVAssetInPlayerItem(asset: asset)
    }
}

extension PlayerAssetManager: AVAssetResourceLoaderDelegate {
    //MARK:- Token Encryption Methods
    
    func MD5Hash(string:String) -> String {
        let stringData = string.data(using: .utf8)
        let MD5Data = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = MD5Data.withUnsafeBytes({ MD5Bytes in
            stringData?.withUnsafeBytes({ stringBytes in
                CC_MD5(stringBytes, CC_LONG(stringData?.count ?? 0), UnsafeMutablePointer<UInt8>(mutating: MD5Bytes))
            })
        })
        print("MD5Hex: \(MD5Data.map {String(format: "%02hhx", $0)}.joined())")
        return MD5Data.base64EncodedString()
    }
    
    
    func getJCTKeyValue(with expiryTime:String) -> String
    {
        let jctToken = self.MD5Hash(string: (JCDataStore.sharedDataStore.secretCdnTokenKey ?? "") + self.getSTKeyValue() + expiryTime)
        return filterMD5HashedStringFromSpecialCharacters(md5String:jctToken)
    }
    
    func getSTKeyValue() -> String {
        let stKeyValue = (JCDataStore.sharedDataStore.secretCdnTokenKey ?? "") + JCAppUser.shared.ssoToken
        let md5StValue = self.MD5Hash(string: stKeyValue)
        let stKey = self.filterMD5HashedStringFromSpecialCharacters(md5String: md5StValue)
        return stKey
    }
    
    func filterMD5HashedStringFromSpecialCharacters(md5String:String) -> String
    {
        var filteredMD5 = md5String
        filteredMD5 = filteredMD5.replacingOccurrences(of: "=", with: "")
        filteredMD5 = filteredMD5.replacingOccurrences(of: "+", with: "-")
        filteredMD5 = filteredMD5.replacingOccurrences(of: "/", with: "_")
        return filteredMD5
    }
    
    func getExpireTime() -> String {
        let deviceTime = Date()
        let currentTimeInSeconds: Int = Int(ceil(deviceTime.timeIntervalSince1970)) + (JCDataStore.sharedDataStore.cdnUrlExpiryDuration ?? 0)
        return "\(currentTimeInSeconds)"
    }
    func generateRedirectURL(sourceURL: String)-> URLRequest? {
        if let url = URL(string: sourceURL) {
            let redirect = URLRequest(url: url)
            return redirect
        }
        return nil
    }
    
    func getContentKeyAndLeaseExpiryfromKeyServerModule(withRequest requestBytes: Data, contentIdentifierHost assetStr: String, leaseExpiryDuration expiryDuration: TimeInterval, error errorOut: Error?,completionHandler: @escaping(Data?)->Void)
    {
        let dict: [AnyHashable: Any] = [
            "spc" : requestBytes.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
            "id" : "whaterver",
            "leaseExpiryDuration" : Double(expiryDuration)
        ]
        
        var jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
        
        guard let url = URL(string: URL_GET_KEY) else {
            return
        }
        let req = NSMutableURLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("\(UInt((jsonData?.count ?? 0)))", forHTTPHeaderField: "Content-Length")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(JCAppUser.shared.ssoToken, forHTTPHeaderField: "ssotoken")
        req.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: req as URLRequest, completionHandler: {data, response, error -> Void in
            //print("error: \(error!)")
            if error != nil {
                //                DispatchQueue.main.async {
                //                    weakSelf?.handleAPIFailure("Unable to show content!")
                //                }
                return
            }
            if (data != nil), let decodedData = Data(base64Encoded: data!, options: []) {
                completionHandler(decodedData)
            } else {
                completionHandler(data)
            }
        })
        task.resume()
    }
    
    func getAppCertificateData(completionHandler: @escaping (Data?)->Void) {
        guard let url = URL(string: URL_GET_CERT) else {
            return
        }
        let req = NSMutableURLRequest(url: url)
        req.setValue(JCAppUser.shared.ssoToken, forHTTPHeaderField: "ssotoken")
        let session = URLSession.shared
        let task = session.dataTask(with: req as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                return
            }
            
            //print("data: \(data)")
            if (data != nil), let decodedData = Data(base64Encoded: data!, options: []) {
                completionHandler(decodedData)
            } else {
                completionHandler(data)
            }
        })
        task.resume()
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if isFps {
            let dataRequest: AVAssetResourceLoadingDataRequest? = loadingRequest.dataRequest
            let url: URL? = loadingRequest.request.url
            let error: Error? = nil
            // Must be a non-standard URI scheme for AVFoundation to invoke your AVAssetResourceLoader delegate
            // for help in loading it.
            if let urlScheme = url?.scheme, (urlScheme !=  URL_SCHEME_NAME) {
                return false
            }
            let assetStr: String = url?.host ?? ""
            var requestBytes: Data?
            let assetId = NSData(bytes: assetStr.cString(using: String.Encoding.utf8), length: assetStr.lengthOfBytes(using: String.Encoding.utf8)) as Data
            self.getAppCertificateData { (certificate) in
                do {
                    requestBytes = try loadingRequest.streamingContentKeyRequestData(forApp: certificate ?? Data(), contentIdentifier: assetId, options: nil)
                    let expiryDuration = 0.0
                    self.getContentKeyAndLeaseExpiryfromKeyServerModule(withRequest: requestBytes ?? Data(), contentIdentifierHost: assetStr, leaseExpiryDuration: expiryDuration, error: error, completionHandler: { (responseData) in
                        if let responseData = responseData {
                            dataRequest?.respond(with: responseData)
                            if expiryDuration != 0.0 {
                                let infoRequest: AVAssetResourceLoadingContentInformationRequest? = loadingRequest.contentInformationRequest
                                if (infoRequest != nil) {
                                    infoRequest?.renewalDate = Date(timeIntervalSinceNow: expiryDuration)
                                    infoRequest?.contentType = "application/octet-stream"
                                    infoRequest?.contentLength = Int64(responseData.count)
                                    infoRequest?.isByteRangeAccessSupported = false
                                }
                            }
                            loadingRequest.finishLoading()
                        } else {
                            loadingRequest.finishLoading()
                        }
                    })
                }
                catch {
                    print(error)
                }
            }
            return true
        }
        
        var urlString = loadingRequest.request.url?.absoluteString ?? ""
        let contentRequest = loadingRequest.contentInformationRequest
        let dataRequest = loadingRequest.dataRequest
        //Check if the it is a content request or data request, we have to check for data request and do the m3u8 file manipulation
        
        if (contentRequest != nil) {
            contentRequest?.isByteRangeAccessSupported = true
        }
        if (dataRequest != nil) {
            //this is data request so processing the url. change the scheme to http
            
            if (urlString.contains("fakeHttp")), (urlString.contains("token")) {
                urlString = urlString.replacingOccurrences(of: "fakeHttp", with: "http")
                guard let url = URL(string: urlString) else {
                    return false
                }
                do {
                    let data = try Data(contentsOf: url)
                    dataRequest?.respond(with: data)
                    loadingRequest.finishLoading()
                    
                } catch {
                    return false
                }
                return true
            }
            if (urlString.contains(".m3u8"))
            {
                let expiryTime:String = self.getExpireTime()
                urlString = urlString.replacingOccurrences(of: "fakeHttp", with: "http")
                let punctuation = (urlString.contains(".m3u8?")) ? "&" : "?"
                let stkeyValue = self.getSTKeyValue()
                let urlString = urlString + "\(punctuation)jct=\(self.getJCTKeyValue(with: expiryTime))&pxe=\(expiryTime)&st=\(stkeyValue)"
                guard let url = URL(string: urlString) else {
                    return false
                }
                print("printing value of url \(urlString)")
                do {
                    let data = try Data(contentsOf: url)
                    dataRequest?.respond(with: data)
                    loadingRequest.finishLoading()
                    
                } catch {
                    return false
                }
                return true
            }
            if(urlString.contains(".ts")) {
                urlString = urlString.replacingOccurrences(of: "fakeHttp", with: "http")
                if let redirect = self.generateRedirectURL(sourceURL: urlString), let url = URL(string: urlString) {
                    //Step 9 and 10:-
                    loadingRequest.redirect = redirect
                    let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)
                    loadingRequest.response = response
                    loadingRequest.finishLoading()
                    return true
                }
                return false
            }
            return false
        }
        return true
    }
    
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool
    {
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
//vinit_commented        if appType == .Movie || appType == .Episode {
            return self.resourceLoader(resourceLoader, shouldWaitForLoadingOfRequestedResource: renewalRequest)
//        }
        return true
    }
}
