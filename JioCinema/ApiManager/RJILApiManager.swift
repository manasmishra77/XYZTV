//
//  RJILApiManager.swift
//  iosjiotv
//
//  Created by Kaustubh Kushte on 20/12/16.
//  Copyright © 2016 Reliance JIO. All rights reserved.
//

import UIKit

class RJILApiManager {
    
    //MARK:- Public
    
    var pendingTasks:[RJILPendingTask] = [RJILPendingTask]()
    
    var isRefreshingToken:Bool = false
    var urlString:String? = ""
    var errorMessage:String? = ""
    var httpStatusCode:Int?
    
    static let defaultManager = RJILApiManager()
    
    func setupAPICache(){
        // setting cache of size 500 MB
        let memoryCapacity = 500 * 1024 * 1024
        let diskCapacity = 500 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "urlCache")
        URLCache.shared = urlCache
    }
    func patch(request:URLRequest, completion:@escaping RequestCompletionBlock) {
        createDataTask(withRequest:request, httpMethod: "PATCH", completion: completion)
    }
    
    func post(request:URLRequest, completion:@escaping RequestCompletionBlock) {
        createDataTask(withRequest:request, httpMethod: "POST", completion: completion)
    }
    
    func put(request:URLRequest, completion:@escaping RequestCompletionBlock) {
        createDataTask(withRequest:request, httpMethod: "PUT", completion: completion)
    }
    
    func get(request:URLRequest, completion:@escaping RequestCompletionBlock) {
        createDataTask(withRequest:request, httpMethod: "GET", completion: completion)
    }
    
    
    /*
     devicetype    String deviceType (phone,tablet etc)
     
     os    String os of device (ios,android etc)
     
     deviceid    String device Id
     
     uniqueid    String UniqueId of user (Except for login)
     
     ssotoken    String AccessToken required to maintain user session(Valid for 24 hrs).
     
     usergroup    String Specifies the type of user
     */
    
    
    //TODO: similar AppUser class will be made?
    var commonHeaders:[String:String]{
        get {
            var _commonHeaders = [String:String]()
            _commonHeaders["os"] = "ios"
            _commonHeaders["deviceType"] = "stb"
            _commonHeaders[kAppKey] = kAppKeyValue
            _commonHeaders["deviceid"] = UIDevice.current.identifierForVendor?.uuidString //UniqueDeviceID
            _commonHeaders["x-multilang"] = "true"
            _commonHeaders["X-API-Key"] = "RJIL_JioCinema"
            _commonHeaders["app-name"] = "RJIL_JioCinema"
            
            if JCLoginManager.sharedInstance.isUserLoggedIn() {
                _commonHeaders["uniqueid"] = JCAppUser.shared.unique
                _commonHeaders["uniqueId"] = JCAppUser.shared.unique
                _commonHeaders["ua"] = "(\(UIDevice.current.model) ; OS \(UIDevice.current.systemVersion) )"
                _commonHeaders["accesstoken"] = JCAppUser.shared.ssoToken
                _commonHeaders["ssotoken"] = JCAppUser.shared.ssoToken
                _commonHeaders["lbcookie"] = JCAppUser.shared.lbCookie
                
                _commonHeaders["User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhoneOS 10_2 like Mac OS X) AppleWebKit/602.3.12 (KHTML, like Gecko) Mobile/14C89"
                if JCAppUser.shared.userGroup != "" {
                    _commonHeaders["usergroup"] = JCAppUser.shared.userGroup
                }
                
            }
            
            return _commonHeaders
        }
    }
    
    
    var otpHeaders:[String:String]{
        get{
            var _otpHeaders = [String:String]()
            _otpHeaders["X-API-Key"] = "l7xxe187b7105c2f4f6ab71c078bd5fc165c"
            _otpHeaders["app-name"] = "RJIL_JioCinema"
            _otpHeaders["Content-Type"] = "application/json"
            
            return _otpHeaders
        }
    }
    var checkVersionHeaders: [String:String]{
        get{
            var _checkVersionHeaders = [String:String]()
            //_checkVersionHeaders["appkey"] = kAppKeyValue
            _checkVersionHeaders["deviceId"] = UIDevice.current.identifierForVendor?.uuidString //UniqueDeviceID
            _checkVersionHeaders["appversion"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            _checkVersionHeaders["os"] = "ios"
            _checkVersionHeaders["devicetype"] = "stb"
            //_checkVersionHeaders["storetype"] = "0"
            
            
            return _checkVersionHeaders
        }
    }
    
    var subIdHeaders:[String:String]{
        get{
            var _subIdHeaders = [String:String]()
            _subIdHeaders[kAppKey] = kAppKeyValue
            _subIdHeaders["deviceid"] = UIDevice.current.identifierForVendor?.uuidString
            _subIdHeaders["Content-Type"] = "application/json"
            _subIdHeaders["lbCookie"] = JCAppUser.shared.lbCookie
            _subIdHeaders["ssoToken"] = JCAppUser.shared.ssoToken
            return _subIdHeaders
        }
    }
    
    var disneyHeaders: [String:String] {
        get{
            var headers = [String:String]()
            headers["Content-Type"] = "application/json"
            headers[kAppKey] = kAppKeyValue
            headers["cache-control"] = "no-cache"
            headers["x-disney"] = "true"
            headers["x-charcat"] = "true"
            headers["x-apisignatures"] = "5772987293"
            return headers
        }
    }
    
    static func parse(data:Data) -> [String:Any]? {
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
            
        } catch let error {
            print(String(data: data, encoding: .utf8) ?? "")
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    
    private func getRequest(forPath path:String) -> URLRequest?
    {
        //make macros here for prod/preprod etc
        
        //TODO:
        urlString = path.contains("http") ? path.removingWhitespaces() : basePath.appending("common/v3/") + path.removingWhitespaces()
        
        if let url = URL(string: urlString!) {
            return URLRequest(url: url)
        }
        return nil
        
    }
    
    func prepareRequest(path: String, headerType: RequestHeaderType = .baseCommon, params: Dictionary<String, Any>? = nil, encoding:JCParameterEncoding, headerParam :Dictionary<String, String>? = nil) -> URLRequest? {

        var request:URLRequest?
        
        if let params = params {
            switch encoding {
            case .JSON:
                //JSON
                request = getRequest(forPath: path)
                do{
                    let jsonData:Data = try JSONSerialization.data(withJSONObject: params, options: [])
                    request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request?.httpBody = jsonData
                }
                catch{
                    print(error)
                }
                break
            case .BODY:
                //POST BODY
                request = getRequest(forPath: path)
                var paramString: String = ""
                for (key, value) in params {
                    guard let escapedKey:String = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                        else { fatalError("Key should be of type string") }
                    var escapedValue:String?
                    if let valueAsString:String = value as? String {
                        escapedValue = valueAsString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                    }
                    else {
                        escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                    }
                    
                    paramString = paramString + escapedKey + "=" + escapedValue! + "&"
                }
                
                request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request?.httpBody = paramString.data(using: String.Encoding.utf8)
                break
            case .URL:
                //URL
                var paramString = ""
                for (key, value) in params {
                    let escapedKey = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                    let escapedValue = (value as AnyObject).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                    paramString += escapedKey! + "=" + escapedValue! + "&"
                }
                
                if paramString.last == "&"{
                    //paramString = paramString.substring(to: paramString.index(before: paramString.endIndex))
                    paramString = String(paramString.dropLast())
                }
                
                let pathWithParams = path + "?" + paramString
                request = getRequest(forPath: pathWithParams)
                break
            }
        }
        else {
            request = getRequest(forPath: path)
        }
        if let headerParam = headerParam {
            for (key, value) in headerParam {
                request?.setValue(key, forHTTPHeaderField: value)
            }
        }
        if path.contains(checkVersionUrl) {
            request?.allHTTPHeaderFields = checkVersionHeaders
        } else if (path.contains(loginViaSubIdUrl)) {
            request?.allHTTPHeaderFields = subIdHeaders
        } else if (path.contains(getOTPUrl) || path.contains(verifyOTPUrl)) {
            request?.allHTTPHeaderFields = otpHeaders
        } else {
            request?.allHTTPHeaderFields = commonHeaders
        }
        
        if headerType == .disneyCommon {
            request?.allHTTPHeaderFields = nil
            request?.allHTTPHeaderFields = disneyHeaders
        }
        
        return request
    }
    
    func downloadData(withURL urlString:String,completion:@escaping (_ urlString:String, _ responseData:Data?)->()){
        var dataDownloadTask: URLSessionDownloadTask!
        
        if let url = URL(string: urlString) {
            dataDownloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (location,response,error) in
                if location != nil {
                    do{
                        let responseData:Data = try Data(contentsOf: location!)
                        completion(urlString, responseData)
                    }
                    catch{
                        print(error)
                        completion(urlString, nil)
                    }
                }
            })
            
            dataDownloadTask.resume()
        }
    }
    
    //MARK:- Private Methods
    
    private var isTokenGettingRefreshed:Bool = false
    
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    func createDataTask(withRequest request:URLRequest,httpMethod method:String, completion:@escaping RequestCompletionBlock) {
        var originalRequest = request
        originalRequest.httpMethod = method
        originalRequest.timeoutInterval = 30.0
        
        
        //Create a datatask with new completion handler
        let dataTask = URLSession.shared.dataTask(with: originalRequest) {(data, response, error) in
            
            
            if let responseError = error {
                //TDDO: Manual Exception Handling
                completion(nil, nil, responseError)
                return
            }
            
            //This is a new completion handler
            //TODO: error domain
            guard let httpResponse:HTTPURLResponse = response as? HTTPURLResponse else {
                //TODO: Add Manual exception tracking, No Internet Connection
                var errorInfo:[String:String] = [String:String]()
                errorInfo[NSLocalizedDescriptionKey] = "Failed to get response from server."
                completion(nil, nil, NSError(domain: "some domain", code: 101, userInfo: errorInfo))
                return
                //Did not get response
                //fatalError("Could not get response")
            }
            
            //TODO: refreshing ssotoken
            self.httpStatusCode = httpResponse.statusCode
            if self.httpStatusCode == 419 {
                if JCAppUser.shared.mToken != ""{
                    
                    //Put the currentTask in queue
                    let currentTask:RJILPendingTask = RJILPendingTask()
                    currentTask.request = originalRequest
                    currentTask.completionHandler = completion
                    RJILApiManager.defaultManager.pendingTasks.append(currentTask)
                    if !RJILApiManager.defaultManager.isRefreshingToken{
                        
                        RJILApiManager.defaultManager.isRefreshingToken = true
                        //Do the refreshing-task work
                        let params = ["mtoken": JCAppUser.shared.mToken]
                        
                        let refreshingTokenRequest = RJILApiManager.defaultManager.prepareRequest(path: refreshTokenUrl, params: params, encoding: .JSON)
                        RJILApiManager.defaultManager.post(request: refreshingTokenRequest!, completion: { (data, response, error) in
                            guard error == nil else{
                                var errorInfo:[String:String] = [String:String]()
                                errorInfo[NSLocalizedDescriptionKey] = "Failed to get response from server."
                                completion(nil, nil, NSError(domain: "some domain", code: 143, userInfo: errorInfo))
                                return
                            }
                            if let responseData = data{
                                //parse response Data
                                let refreshTupple = RJILApiManager.defaultManager.parseRefreshTokenData(responseData)
                                if refreshTupple.0 == 200{
                                    JCAppUser.shared.ssoToken = refreshTupple.1
                                    for each in RJILApiManager.defaultManager.pendingTasks{
                                        each.request?.allHTTPHeaderFields = RJILApiManager.defaultManager.commonHeaders
                                        //completion(nil, nil, NSError(domain: "some domain", code: 143, userInfo: nil))
                                        self.createDataTask(withRequest: each.request!, httpMethod: (each.request?.httpMethod!)!, completion: each.completionHandler!)
                                    }
                                }
                                else{
                                    self.isRefreshingToken = false
                                    //LogOutUser and show login page
                                    completion(nil, nil, NSError(domain: "some domain", code: 143, userInfo: nil))
                                }
                            }
                            self.pendingTasks.removeAll()
                            self.isRefreshingToken = false
                        })
                        
                    }
                }
                else
                {
                    //Present Login Page
                    completion(nil, nil, NSError(domain: "some domain", code: 143, userInfo: nil))
                    
                }
            }
                //TODO: error domain
            else if self.httpStatusCode == 504{
                var errorInfo:[String:String] = [String:String]()
                self.errorMessage = "Server Timeout : Please try again in some time"
                errorInfo[NSLocalizedDescriptionKey] = self.errorMessage
                
                completion(nil, nil, NSError(domain: "some error domain", code: 504, userInfo: errorInfo))
            }
            else if self.httpStatusCode == 200 || self.httpStatusCode == 204 {//Success
                completion(data, response, error)
            }
            else {
                var errorInfo: [String:String] = [String:String]()
                let errorDescription = "Unexpected Response : HTTP Status Code :\(String(describing: self.httpStatusCode))"
                if let receivedData = data {
                    // let dict = RJILApiManager.parse(data: receivedData)
                    let responseString = String(data: receivedData, encoding:.utf8)
                    self.errorMessage = errorDescription + " " + responseString!
                }
                
                
                errorInfo[NSLocalizedDescriptionKey] = self.errorMessage
                completion(nil, nil, NSError(domain: "some error domain", code: self.httpStatusCode!, userInfo: errorInfo))
            }
            if self.httpStatusCode != 200
            {
                //TODO: after implementing analytics
                //RJILAppAnalytics.manager.trackAPIFailure(withErrorMessage: self.errorMessage!, andErrorCode: self.httpStatusCode!, forAPI: self.urlString!)
            }
        }
        
        dataTask.resume()
        
        
    }
    
    func parseRefreshTokenData(_ responseData: Data) -> (Int, String) {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
            if let responseDict = jsonDict as? [String: Any] {
                var refreshTupple = (0, "")
                refreshTupple.0 = responseDict["code"] as? Int ?? 0
                refreshTupple.1 = responseDict["ssotoken"] as? String ?? ""
                return refreshTupple
            }
            
        } catch {
            //print("Error deserializing JSON: \(error)")
        }
        return (0, "")
    }
    
    class func parseData<T: Codable>(_ data: Data?, modelType: T.Type) -> T? {
        guard let data = data else {
            return nil
        }
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            print(error)
        }
        return nil
    }
}
