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

let screenHeight:CGFloat = UIScreen.main.bounds.height
let screenWidth:CGFloat = UIScreen.main.bounds.width
let isNetworkAvailable = Utility.sharedInstance.isNetworkAvailable
let networkErrorMessage = "No network available"

//var collectionIndex = -1
//var selectedItemFromViewController:VideoType = VideoType.Home
//var categoryTitle = ""
//var referenceFromPlayerVC = ""


//BasePath
let prodBase = "https://prod.media.jio.com/apis/"
let qaBase = "https://qa.media.jio.com/mdp_qa/apis/"

let basePath = prodBase

//Config
let configUrl = "getconfig/geturl/39ee6ded40812c593ed8"

//Login
let loginUrl = "login/login"
let loginViaSubIdUrl = "common/v3/login/loginviasubid"

//NetworkCheckURl (ZLA)
let networkCheckUrl = "http://api.media.jio.com/apis/jionetwork/v2/testip/"
let zlaUserDataUrl = "http://api.ril.com/v2/users/me"

//OTP
let getOTPUrl = "https://api.jio.com/jsclient/v3/dip/user/otp/send"
let verifyOTPUrl = "https://api.jio.com/jsclient/v3/dip/user/otp/verify"

//https://qa.media.jio.com/mdp_qa/apis/06758e99be484fca56fb/v3/home/getget/1/0

//HomeDataUrls
let homeDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/1/")
let moviesDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/6/")
let musicDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/33/")
let tvDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/9/")
let clipsDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/35/")
let playbackRightsURL = basePath.appending("common/v3/playbackrights/get/")
let playbackDataURL = basePath.appending("common/v3/playlistdata/get/")
let metadataUrl = basePath.appending("common/v3/metamore/get/")
let moviesWatchListUrl = basePath.appending("common/v3/metalist/get/12")
let tvWatchListUrl = basePath.appending("common/v3/metalist/get/13")
let addToWatchListUrl = basePath.appending("common/v3/list/add")
let removeFromWatchListUrl = basePath.appending("common/v3/list/deletecontent")
let resumeWatchGetUrl = basePath.appending("06758e99be484fca56fb/v3/resumewatch/get")
let preditiveSearchURL = basePath.appending("common/v3/search/search")
let addToResumeWatchlistUrl = basePath.appending("06758e99be484fca56fb/v3/resumewatch/add")
let removeFromResumeWatchlistUrl = basePath.appending("common/v3/list/deletecontent")
let languageListUrl = basePath.appending("common/v3/conflist/get/39ee6ded40812c593ed8/25")
let genreListUrl = basePath.appending("common/v3/conflist/get/39ee6ded40812c593ed8/29")
let langGenreDataUrl = basePath.appending("common/v3/langgenre/get/")
let checkVersionUrl = basePath.appending("common/v3/checkversion/checkversion")
let userRecommendationURL = basePath.appending("common/v3.1/userrecommendation/get")
let refreshTokenUrl = basePath.appending("common/v3/accesstoken/get")

//Completion Blocks
typealias RequestCompletionBlock = (Data?, URLResponse?, Error?) -> ()

typealias LoaderCompletionBlock = (() -> ())

typealias NetworkCheckCompletionBlock = (Bool) -> ()

//Keys
let kAppKey = "appkey"

//Values
let kAppKeyValue = "06758e99be484fca56fb"

var playerVC_Global: UIViewController?

//StoryBoard Ids
let loginVCStoryBoardId = "kLoginVC"
let signInOptionsStoryBoardId = "kSignInOptionsVC"
let otpVCStoryBoardId = "kOTPVC"
let tabBarStoryBoardId = "kTabBarController"
let playerVCStoryBoardId = "kPlayerVC"
let metadataVCStoryBoardId = "kMetadataVC"
let settingsVCStoryBoardId = "kSettingsVC"
let settingsDetailVCStoryBoardId = "kSettingsDetailVC"
let resumeWatchingVCStoryBoardId = "kResumeWatchingVC"
let languageGenreStoryBoardId = "kLanguageGenreVC"
let languageGenreSelectionStoryBoardId = "kLanguageGenreSelectionVC"

//Nib Identifiers
let baseTableViewCellReuseIdentifier = "kBaseTableViewCell"
let baseCollectionViewCellReuseIdentifier = "kBaseCollectionViewCell"
let baseHeaderTableViewCellIdentifier = "kBaseTableViewHeaderCell"
let baseFooterTableViewCellIdentifier = "kBaseTableViewFooterCell"
let metadataHeaderTableViewCellIdentifier = "kMetadataHeaderViewCell"
let seasonCollectionViewCellIdentifier = "kSeasonCollectionViewCell"
let yearCellIdentifier = "kYearCell"
let monthCellIdentifier = "kMonthCell"
let resumeWatchCellIdentifier = "kResumeWatchCell"
let itemCellIdentifier = "kJCItemCell"
let artistImageCellIdentifier = "kJCArtistImageCell"
let languageGenreSelectionCellIdentifier = "kLanguageGenreSelectionPrototypeCell"

//Constant Values
let heightOfCarouselSection = 600
let savedUserKey = "User"
let isUserLoggedInKey = "isUserLoggedIn"
let cellTapNotificationName = Notification.Name("didClickOnCellNotification")
let playerDismissNotificationName = Notification.Name("playerDismissed")
let watchNowNotificationName = Notification.Name("didClickOnWatchNowNotification")
let metadataCellTapNotificationName = Notification.Name("didClickOnMetadataCell")
let showLoginFromMetadataNotificationName = Notification.Name("showLoginFromMetadata")
let loginSuccessNotificationName = Notification.Name("loginSuccessful")
let readyToPlayNotificationName = Notification.Name("readyToPlay")
let openSearchVCNotificationName = Notification.Name("openSearchVC")
let isAutoPlayOnKey = "isAutoPlayOn"


//Google Analytics
let googleAnalyticsTId = "UA-106863966-14"   //propertyId    Dev:"UA-106863966-2", Prod:"UA-106863966-1"
let googleAnalyticsEndPoint = "https://www.google-analytics.com/collect?"

//App Delegate
let appDelegate = UIApplication.shared.delegate as? AppDelegate


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


//Screen Name
let HOME_SCREEN = "Home Screen"
let MOVIE_SCREEN = "Movie Screen"
let TV_SCREEN = "TV Screen"
let MUSIC_SCREEN = "Music Screen"
let CLIP_SCREEN = "Clip Screen"
let SEARCH_SCREEN = "Search Screen"
let METADATA_SCREEN = "Metadata Screen"
let PLAYER_SCREEN = "Player Screen"
let LANGUAGE_SCREEN = "Language Screen"
let GENRE_SCREEN = "Genre Screen"

//Category Name
let RECOMMENDATION = "Recommendation"
let MORELIKE = "More Like"
let WATCH_NOW_BUTTON = "Watch-now button"

let ADD_TO_WATCHLIST = "Add to watchlist"
let REMOVE_FROM_WATCHLIST = "Remove from watchlist"


//MARK:- Google Analytics Constants

//Event Category
let LOGIN_EVENT = "Login"
let HOME_SCREEN_EVENT = "Home Screen"
//Event Action
let SUCCESS_ACTION = "Success"
let FAILURE_ACTION = "Failure"
//Event Comment
let LOGGEDIN_SUCCESSFUL = "Logged in successfully"


