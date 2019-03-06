 //
//  APIManager+Common.swift
//  JioCinema
//
//  Created by Manas Mishra on 23/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

typealias APISuccessBlock = (_ isSuccess: Bool, _ errorMsg: String?) -> ()

extension RJILApiManager {
    
    enum RequestHeaderType {
        case disneyCommon
        case baseCommon
    }
    
    class func getReponse<T: Codable>(path: String, shouldCheckNetWork: Bool = true, headerType: RequestHeaderType = .baseCommon, params: [String: Any]? = nil, postType: RequestType, paramEncoding: JCParameterEncoding = .URL, shouldShowIndicator: Bool = false, isLoginRequired: Bool = false, reponseModelType: T.Type, completion: @escaping (_ response: Response<T>) -> ()) {
        
//        guard !isLoginRequired, JCLoginManager.sharedInstance.isUserLoggedIn() else {
//            let response = Response<T>(model: nil, isSuccess: false, errorMsg: "Not Logged in")
//            completion(response)
//            return
//        }
        if shouldCheckNetWork {
            // Used only for getconfig and check version
            guard Utility.sharedInstance.isNetworkAvailable else {
//                let response = Response<T>(model: nil, isSuccess: false, errorMsg: "No Network")
                let response = Response<T>(model: nil, isSuccess: false, errorMsg: "No Network", code: CommonResponseCode.noNetwork.rawValue)

                completion(response)
                return
            }
        }
        
        guard let request = RJILApiManager.defaultManager.prepareRequest(path: path, headerType: headerType, params: params, encoding: paramEncoding) else {
//            let response = Response<T>(model: nil, isSuccess: false, errorMsg: "Request Couldn't be formed")
            let response = Response<T>(model: nil, isSuccess: false, errorMsg: "Request Couldn't be formed", code: CommonResponseCode.requestColdnotFormed.rawValue)

            completion(response)
            return
        }
        RJILApiManager.defaultManager.createDataTask(withRequest: request, httpMethod: postType.rawValue) { (data, response, error) in
            if let error = error as NSError? {
//                let response = Response<T>(model: nil, isSuccess: false, errorMsg: error.localizedDescription)
//                completion(response)
//                return
                if error.code == CommonResponseCode.refreshSSOFailed.rawValue {
                    let response = Response<T>(model: nil, isSuccess: false, errorMsg: error.localizedDescription, code: error.code)
                    JCLoginManager.sharedInstance.logoutUser()
                    completion(response)
                } else {
                    let response = Response<T>(model: nil, isSuccess: false, errorMsg: error.localizedDescription, code: error.code)
                    completion(response)
                    return
                }
                
            }
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    if let responseModel = RJILApiManager.parseData(data, modelType: reponseModelType) {
                        let response = Response<T>(model: responseModel, isSuccess: true, errorMsg: nil, code: CommonResponseCode.success.rawValue)
                        completion(response)
                    } else {
                        //                        var response = Response<T>(model: nil, isSuccess: false, errorMsg: "Couldn't parse")
                        var response = Response<T>(model: nil, isSuccess: false, errorMsg: "Couldn't parse", code: CommonResponseCode.parsingEror.rawValue)
                        if reponseModelType == NoModel.self {
                                                        response = Response<T>(model: nil, isSuccess: true, errorMsg: "No respnse!", code: httpResponse.statusCode)
                        }
                        completion(response)
                    }
                default:
                    let response = Response<T>(model: nil, isSuccess: false, errorMsg: "Something missing", code: CommonResponseCode.commonFailure.rawValue)
                    completion(response)
                }
                return
            } else {
//                let response = Response<T>(model: nil, isSuccess: false, errorMsg: "Response is missing")
                let response = Response<T>(model: nil, isSuccess: false, errorMsg: "Response is missing", code: CommonResponseCode.noResponse.rawValue)

                completion(response)
            }
        }
        
    }
    
}

//Config Data calls
extension RJILApiManager {
    class func getConfigData(completion: @escaping APISuccessBlock) {
        let params = [kAppKey: kAppKeyValue]
        let path = basePath + configUrl
        RJILApiManager.getReponse(path: path, shouldCheckNetWork: false, params: params, postType: .GET, paramEncoding: .URL, shouldShowIndicator: true, reponseModelType: ConfigData.self) { (response) in
            if response.isSuccess {
               JCDataStore.setConfigData(with: response.model!)
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
        }
    }
}

//MARK:- Version check and update
extension RJILApiManager {
    class func callWebServiceToCheckVersion(completion: @escaping (Response<CheckVersionModel>) -> ()) {
        RJILApiManager.getReponse(path: checkVersionUrl, shouldCheckNetWork: false, postType: .GET, reponseModelType: CheckVersionModel.self, completion: completion)
    }
}

//MARK:- Sign in  API Call
extension RJILApiManager {
    //via jioid
    class func signInViaJioId(id: String, password: String, completion: @escaping APISuccessBlock) {
        let params: [String:String] = ["os": "Android", "username": id, "password": password, "deviceId": "12345"]
        RJILApiManager.getReponse(path: loginUrl, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: true, reponseModelType: SignInSuperModel.self) { (response) in
            if response.isSuccess {
                if let signInModel = response.model?.result {
                    JCAppUser.shared.lbCookie = signInModel.lbCookie ?? ""
                    JCAppUser.shared.ssoLevel = ""
                    JCAppUser.shared.ssoToken = signInModel.ssoToken ?? ""
                    JCAppUser.shared.commonName = signInModel.displayName ?? ""
                    JCAppUser.shared.preferredLocale = ""
                    JCAppUser.shared.subscriberId = signInModel.subscriberId ?? ""
                    JCAppUser.shared.mail = signInModel.mail ?? ""
                    JCAppUser.shared.profileId = signInModel.profileId ?? ""
                    JCAppUser.shared.uid = signInModel.uId ?? ""
                    JCAppUser.shared.unique = signInModel.uniqueId ?? ""
                    JCAppUser.shared.mToken = signInModel.mToken ?? ""
                    JCAppUser.shared.userGroup = response.model?.userGrp ?? ""
                    completion(true, nil)
                } else {
                    completion(false, "Error in login")
                }
            } else {
                completion(false, response.errorMsg)
            }
        }
        
    }
    //VIA OTP
    class func getOTP(number: String, completion: @escaping APISuccessBlock) {
        let params = [identifierKey:"+91" + number, otpIdentifierKey: "+91" + number, actionKey: actionValue]
        RJILApiManager.getReponse(path: getOTPUrl, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: true, reponseModelType: NoModel.self) { (response) in
            if response.isSuccess {
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }
        }
    }
    class func verifyOTP(number: String, otp: String, completion: @escaping APISuccessBlock) {
         let params = [identifierKey: number, otpKey:otp, upgradeAuthKey:upgradAuthValue, returnSessionDetailsKey:returnSessionDetailsValue]
        RJILApiManager.getReponse(path: verifyOTPUrl, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: true, reponseModelType: OTPModel.self) { (response) in
            if response.isSuccess {
                    JCAppUser.shared.lbCookie = response.model?.lbCookie ?? ""
                    JCAppUser.shared.ssoToken = response.model?.ssoToken ?? ""
                    JCAppUser.shared.uid = response.model?.sessionAttribute?.user?.uid ?? ""
                    JCAppUser.shared.profileId = response.model?.sessionAttribute?.profile?.profileId ?? ""
                    RJILApiManager.loginViaSubId(subId: response.model?.sessionAttribute?.user?.subscriberId ?? "", completion: completion)
                } else {
                    completion(false, response.errorMsg)
                }
        }
    }
    
    
    class func loginViaSubId(subId: String, completion: @escaping APISuccessBlock) {
        let params = [subscriberIdKey: subId]
        let url = basePath + loginViaSubIdUrl
        RJILApiManager.getReponse(path: url, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: true, reponseModelType: SignInModel.self) { (response) in
            if response.isSuccess {
                JCAppUser.shared.lbCookie = response.model?.lbCookie ?? ""
                JCAppUser.shared.ssoToken = response.model?.ssoToken ?? ""
                JCAppUser.shared.commonName = response.model?.name ?? ""
                JCAppUser.shared.subscriberId = response.model?.subscriberId ?? ""
                JCAppUser.shared.unique = response.model?.uniqueId ?? ""
                JCAppUser.shared.mToken = response.model?.mToken ?? ""
                JCAppUser.shared.userGroup = response.model?.userGrp ?? ""
                JCAppUser.shared.uid = response.model?.username ?? ""
                completion(true, nil)
            } else {
                completion(false, response.errorMsg)
            }

        }
    }
}

//MARK:- Parental Control API Call
extension RJILApiManager {
    //Get Unique code to reset pin or see pin status
    class func getUniqueCodeForResetParentalPin(completion: @escaping (_ uniqueCode: String?) -> ()) -> () {
        RJILApiManager.getReponse(path: SetParentalPinUrl, postType: .POST, reponseModelType: [String: Int].self) { (response) in
            guard response.isSuccess else {return}
            guard let uniqueCode = response.model?["uniqueCode"] else {return}
            completion("\(uniqueCode)")
        }
    }
    //Getting parental pin model from server
    class func getParentalPinForContentFromServer(completion: @escaping (_ pinModel: ParentalPinModel) -> ()) -> () {
        RJILApiManager.getReponse(path: GetParentalPinDetailUrl, postType: .POST, reponseModelType: ParentalPinModel.self) { (response) in
            guard response.isSuccess else {return}
            completion(response.model!)
        }
    }
    
}


















