//
//  JCAppConstants.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 10/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

public enum JCParameterEncoding
{
    case JSON
    case URL
    case BODY
}

//BasePath
let base = "https://prod.media.jio.com/apis/"
let basePathForProd = "https://prod.media.jio.com/apis/common/v3/"
let basePathForQA = "https://qa.media.jio.com/mdp_qa/apis/common/v3/"

//Config
let configUrl = "getconfig/geturl/39ee6ded40812c593ed8"

//Login
let loginUrl = "login/login"
let loginViaSubIdUrl = "login/loginviasubid"

//NetworkCheckURl (ZLA)
let networkCheckUrl = "http://api.media.jio.com/apis/jionetwork/v2/testip/"
let zlaUserDataUrl = "http://api.ril.com/v2/users/me"

//OTP
let getOTPUrl = "https://api.jio.com/jsclient/v3/dip/user/otp/send"
let verifyOTPUrl = "https://api.jio.com/jsclient/v3/dip/user/otp/verify"

//HomeDataUrls
let homeDataUrl = (base.appending(kAppKeyValue)).appending("/v3/home/get/1/")
let moviesDataUrl = (base.appending(kAppKeyValue)).appending("/v3/home/get/6/")
let musicDataUrl = (base.appending(kAppKeyValue)).appending("/v3/home/get/33/")
let tvDataUrl = (base.appending(kAppKeyValue)).appending("/v3/home/get/9/")
let clipsDataUrl = (base.appending(kAppKeyValue)).appending("/v3/home/get/35/")
let playbackRightsURL = basePathForProd.appending("playbackrights/get/")

//Completion Blocks
typealias RequestCompletionBlock = (Data?, URLResponse?, Error?) -> ()

typealias LoaderCompletionBlock = (() -> ())

typealias NetworkCheckCompletionBlock = (Bool) -> ()

//Keys
let kAppKey = "appkey"

//Values
let kAppKeyValue = "06758e99be484fca56fb"

//StoryBoard Ids
let loginVCStoryBoardId = "kLoginVC"
let signInOptionsStoryBoardId = "kSignInOptionsVC"
let otpVCStoryBoardId = "kOTPVC"
let tabBarStoryBoardId = "kTabBarController"
let playerVCStoryBoardId = "kPlayerVC"
let metadataVCStoryBoardId = "kMetadataVC"

//Nib Identifiers
let baseTableViewCellReuseIdentifier = "kBaseTableViewCell"
let baseCollectionViewCellReuseIdentifier = "kBaseCollectionViewCell"
let baseHeaderTableViewCellIdentifier = "kBaseTableViewHeaderCell"
let baseFooterTableViewCellIdentifier = "kBaseTableViewFooterCell"

//Constant Values
let heightOfCarouselSection = 600
let savedUserKey = "User"
let isUserLoggedInKey = "isUserLoggedIn"
let cellTapNotificationName = Notification.Name("didClickOnCellNotification")
let loginSuccessNotificationName = Notification.Name("loginSuccessful")
let readyToPlayNotificationName = Notification.Name("readyToPlay")


//OTP verification constants
let identifierKey = "identifier"
let otpIdentifierKey = "otpIdentifier"
let actionKey = "action"
let actionValue = "otpbasedauthn"
let otpKey = "otp"
let upgradeAuthKey = "upgradeAuth"
let returnSessionDetailsKey = "returnSessionDetails"
let upgradAuthValue = "Y"
let returnSessionDetailsValue = "T"

let subscriberIdKey = "subscriberId"


