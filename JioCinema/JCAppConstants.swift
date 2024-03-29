//
//  JCAppConstants.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 10/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

public enum JCParameterEncoding {
    case JSON
    case URL
    case BODY
}

let screenHeight:CGFloat = UIScreen.main.bounds.height
let screenWidth:CGFloat = UIScreen.main.bounds.width
let isNetworkAvailable = Utility.sharedInstance.isNetworkAvailable
let networkErrorMessage = "Please check your device's network and retry!"


//BasePath
let prodBase = "https://prod.media.jio.com/apis/"
let qaBase = "https://qa.media.jio.com/mdp_qa/apis/"

let basePath = prodBase
//let basePath = qaBase

//Config
let common = "common/v3/"
let configUrl = "common/v3.1/" + "getconfig/geturl/39ee6ded40812c593ed8"

//Login
let loginUrl = "login/login"
let loginViaSubIdUrl = "common/v3/login/loginviasubid"

//NetworkCheckURl (ZLA)
let networkCheckUrl = "http://api.media.jio.com/apis/jionetwork/v2/testip/"
let zlaUserDataUrl = "http://api.ril.com/v2/users/me"

//OTP
let getOTPUrl = "https://api.jio.com/jsclient/v3/dip/user/otp/send"
let verifyOTPUrl = "https://api.jio.com/jsclient/v3/dip/user/otp/verify"

//Player Thumbnail Url
let thumbnailBaseUrl = "http://jioimages.cdn.jio.com/content/entry/"

//https://qa.media.jio.com/mdp_qa/apis/06758e99be484fca56fb/v3/home/getget/1/0

//HomeDataUrls
let homeDataUrl = basePath + kAppKeyValue + "/v3.1/tvhome/getget/70/"//(basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/1/")//basePath + kAppKeyValue + "/v3.1/tvhome/getget/" //
let moviesDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/6/")
let musicDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/33/")
let tvDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/9/")
let clipsDataUrl = (basePath.appending(kAppKeyValue)).appending("/v3.1/home/get/35/")
let playbackRightsURL = basePath.appending("common/v3/playbackrights/get/")
let playbackDataURL = basePath.appending("common/v3/playlistdata/get/")
let metadataUrl = basePath.appending("common/v3/metamore/get/")
let playBackForPlayList = basePath.appending("common/v3/playlistdata/get/")
//From DisneyBranch
let moviesWatchListUrl = basePath.appending("common/v3/metalist/get/12")
let tvWatchListUrl = basePath.appending("common/v3/metalist/get/13")
let disneyTvWatchListUrl = basePath.appending("common/v3/metalist/get/33")
let disneyMoviesWatchListUrl = basePath.appending("common/v3/metalist/get/32")
/*
 From Head
=======
//let moviesWatchListUrl = basePath.appending("common/v3/metalist/get/12")
let moviesWatchListUrl = basePath.appending("06758e99be484fca56fb/v3/resumewatch/get")
//let tvWatchListUrl = basePath.appending("common/v3/metalist/get/13")
let tvWatchListUrl = basePath.appending("06758e99be484fca56fb/v3/resumewatch/get")
>>>>>>> f26263aad65500d2e66524c9400fd33523e786da
 */
let addToWatchListUrl = basePath.appending("common/v3/list/add")
let removeFromWatchListUrl = basePath.appending("common/v3/list/deletecontent")
let resumeWatchGetUrl = basePath.appending("06758e99be484fca56fb/v3/resumewatch/get")
let preditiveSearchURL = basePath.appending("common/v3.1/search/search")
let addToResumeWatchlistUrl = basePath.appending("06758e99be484fca56fb/v3/resumewatch/add")
let removeFromResumeWatchlistUrl = basePath.appending("common/v3/list/deletecontent")
let languageListUrl = basePath.appending("common/v3/conflist/get/39ee6ded40812c593ed8/25")
let genreListUrl = basePath.appending("common/v3/conflist/get/39ee6ded40812c593ed8/29")
let langGenreDataUrl = basePath.appending("common/v3/langgenre/get/")
let checkVersionUrl = basePath.appending("common/v3/checkversion/checkversion")
let userRecommendationURL = basePath.appending("common/v3.1/userrecommendation/get")
let refreshTokenUrl = basePath.appending("common/v3/accesstoken/get")   
let TrendingSearchTextURL = basePath + "common/v3/getpopular/getpopular​"
let SetParentalPinUrl = basePath + kAppKeyValue + "/v3.1/preferences/generatecode"
let GetParentalPinDetailUrl = basePath + kAppKeyValue + "/v3.1/preferences/get"
let disneyHomeDataUrl = basePath + kAppKeyValue + "/v3/disneyhome/get/60/"
let disneyMoviesDataUrl = basePath + kAppKeyValue + "/v3/disneyhome/get/62/"
let disneyTVShowDataUrl = basePath + kAppKeyValue + "/v3/disneyhome/get/64/"
let disneyKidsDataUrl = basePath + kAppKeyValue + "/v3/disneyhome/get/68/"
//"http://10.130.9.92:8000/apis/06758e99be484fca56fb/v3/disneyhome/get/60/0"
let disneyResumeWatchListUrl = basePath + kAppKeyValue + "/v3/resumewatch/get"
let disneyCharacterherosDataUrl = basePath + "common/v3.1/character/get/"

//Player aseet urls
let URL_SCHEME_NAME = "skd"
let URL_GET_KEY =  "http://prod.media.jio.com/apis/06758e99be484fca56fb/v3/fps/getkey"
let URL_GET_CERT = "http://prod.media.jio.com/apis/06758e99be484fca56fb/v3/fps/getcert"

let PLAYABLE_KEY = "playable"
let STATUS_KEY = "status"
let AVPLAYER_BUFFER_KEEP_UP = "playbackLikelyToKeepUp"
let AVPLAYER_BUFFER_EMPTY = "playbackBufferEmpty"



//Completion Blocks
typealias RequestCompletionBlock = (Data?, URLResponse?, Error?) -> ()

typealias LoaderCompletionBlock = (() -> ())

typealias NetworkCheckCompletionBlock = (Bool) -> ()

//Keys
let kAppKey = "appkey"

//Values
let kAppKeyValue = "06758e99be484fca56fb"
let apIKey = "l7xxe187b7105c2f4f6ab71c078bd5fc165c"

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
let artistImageCellIdentifier = "kJCArtistImageCell"
let languageGenreSelectionCellIdentifier = "kLanguageGenreSelectionPrototypeCell"
let SettingCellIdentifier = "kSettingsTableViewCell"
let SearchRecommendationCellIdentifier = "SearchRecommendationCellIdentifier"
let EnterParentalPinViewIdentifier = "EnterParentalPinView"
let BaseItemCellNibIdentifier = "ItemCollectionViewCell"
let BaseTableCellNibIdentifier = "BaseTableViewCell"
let BaseViewControllerNibIdentifier = "BaseViewController"


//Constant Values
let heightOfCarouselSection : CGFloat = 0//670
let savedUserKey = "User"
let isUserLoggedInKey = "isUserLoggedIn"
let WatchlistUpdatedNotificationName = Notification.Name("WatchlistUpdated")
let didSetDisneyTVWatchlist = Notification.Name("didSetDisneyTVWatchList")
let didSetDisneyMovieWatchlist = Notification.Name("didSetDisneyMoviesWatchList")

let isAutoPlayOnKey = "isAutoPlayOn"
let isParentalControlShown = "isParentalControlShown"
let isRememberMySettingsSelectedKey = "isRememberMySettingsSelected"

struct AppNotification {
    static let reloadResumeWatch = Notification.Name("resumeWatchReload")
    static let reloadResumeWatchForDisney = Notification.Name("ReloadDisneyResumeWatch")
    static let serchViewUnloading = Notification.Name("SearchViewUnloading")
}
struct ViewColor {
    static let disneyBackground: UIColor = #colorLiteral(red: 0.02352941176, green: 0.1294117647, blue: 0.2470588235, alpha: 1)
    static let commonBackground: UIColor = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1137254902, alpha: 1)//#colorLiteral(red: 0.1068576351, green: 0.1179018542, blue: 0.1013216153, alpha: 1)
    
    static let disneyLeftMenuBackground: UIColor = #colorLiteral(red: 0.008938653395, green: 0.1776166856, blue: 0.3151244521, alpha: 0.7)//#colorLiteral(red: 0.008938653395, green: 0.1776166856, blue: 0.3151244521, alpha: 1)
    static let cinemaLeftMenuBackground: UIColor = #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09411764706, alpha: 0.7)//#colorLiteral(red: 0.6285945773, green: 0.09878890961, blue: 0.2734127343, alpha: 1)

    
//    Cinema Left Menu Background Color  : #8D0536
    
    static let searchBackGround: UIColor = .black
    static let clearBackGround: UIColor = .clear
    static let disneyButtonColor: UIColor = UIColor(red: 15.0/255.0, green: 112.0/255.0, blue: 215.0/255.0, alpha: 1.0)
    static let selectionBarOnLeftNavigationColor: UIColor = #colorLiteral(red: 0.5529411765, green: 0.01960784314, blue: 0.2117647059, alpha: 1)//#colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1)
    static let selectionBarOnLeftNavigationColorForDisney: UIColor = #colorLiteral(red: 0.2585663795, green: 0.7333371639, blue: 0.7917140722, alpha: 1)

}


//Google Analytics
let googleAnalyticsTId = "UA-106863966-14"   //propertyId    Dev:"UA-106863966-2", Prod:"UA-106863966-1"
let googleAnalyticsEndPoint = "https://www.google-analytics.com/collect?"




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
let DISNEY_SCREEN = "Disney Screen"
let TV_SCREEN = "TV Screen"
let MUSIC_SCREEN = "Music Screen"
let CLIP_SCREEN = "Clip Screen"
let SEARCH_SCREEN = "Search Screen"
let METADATA_SCREEN = "Metadata Screen"
let PLAYER_SCREEN = "Player Screen"
let LANGUAGE_SCREEN = "Language Screen"
let GENRE_SCREEN = "Genre Screen"
let LOGIN_SCREEN = "Login Screen"
let TVOS_HOME_SCREEN = "tvOS Home Screen"

//Category Name
let RECOMMENDATION = "Recommendation"
let MORELIKE = "More Like"
let WATCH_NOW_BUTTON = "Watch-now button"
let TVOS_HOME_SCREEN_CAROUSEL = "tvOS Home Screen Carousel"

let ADD_TO_WATCHLIST = "Add To Watchlist"
let REMOVE_FROM_WATCHLIST = "Remove From Watchlist"

let SHOW_MORE = "Show More"
let SHOW_LESS = "Show Less"


//MARK:- Tablecell Row height
//height of category title in table view including top & bottom constraint
let CategoryTitleHeight: CGFloat = 85 + 20
let bottomConstraintOfCollectionView: CGFloat = 10

//Heights in
let imageTopConstraints: CGFloat = 15
let imageViewHeight: CGFloat = 209 + imageTopConstraints
let itemTitleHeight: CGFloat = 56 //(12+36+8)
let itemSubtitleHeight: CGFloat = 35 //(29+6)

//item height including title , subtitle & top-bottom constraints between them
let itemHeightForPortrait: CGFloat = 312 + imageTopConstraints //312//450
let itemHeightForLandscape: CGFloat = imageViewHeight //280.36//360
let itemHeightForLandscapeForTitleOnly = itemHeightForLandscape + itemTitleHeight
let itemHeightForLandscapeForTitleAndSubtitle = itemHeightForLandscapeForTitleOnly + itemSubtitleHeight
let itemWidthForPortrait: CGFloat = 234//270
let itemWidthForLadscape: CGFloat = 373//480

let rowHeightForPotrait: CGFloat = itemHeightForPortrait + CategoryTitleHeight + bottomConstraintOfCollectionView//+ 14//561
let rowHeightForLandscape: CGFloat = itemHeightForLandscape + CategoryTitleHeight + bottomConstraintOfCollectionView//+ 14//397
let rowHeightForLandscapeTitleOnly: CGFloat = itemHeightForLandscapeForTitleOnly + CategoryTitleHeight + bottomConstraintOfCollectionView//+ 14//397
let rowHeightForLandscapeWithLabels: CGFloat = itemHeightForLandscapeForTitleAndSubtitle + CategoryTitleHeight + bottomConstraintOfCollectionView//+ 14//397
let widthToHeightPropertionForPotrat: CGFloat = 277/475
let widthToHeightPropertionForLandScape: CGFloat = 365/311
let widthToHeightPropertionForPotratOLD: CGFloat = 0.65
let widthToHeightPropertionForLandScapeOLD: CGFloat = 1.27



struct SideNavigationConstants {
    static let expandedWidth: CGFloat = 340//400
    static let collapsedWidth: CGFloat = 105//132
}

struct LanguageGenreScene {
    static let heightToWidthRatioOfItemCellForPotrait: CGFloat = 1.54
    static let heightToWidthRatioOfItemCellForLandscape: CGFloat = 0.78
    static var landscapeRowHeight: CGFloat {
        let height: CGFloat = 306 + 30//rowHeightForLandscape
        return height
    }
    static var potraitRowHeight: CGFloat {
        let height: CGFloat = 470 + 30 //rowHeightForPotrait
        return height
    }
    static var landscapeCellSize: CGSize {
        let height = itemHeightForLandscape//landscapeRowHeight - 40
        let width =  itemWidthForLadscape//(height / heightToWidthRatioOfItemCellForLandscape)
        return CGSize(width: width, height: height)
    }
    
    static var landscapeCellSizeForLanguageGenereResults: CGSize {
        let height = itemHeightForLandscapeForTitleAndSubtitle//landscapeRowHeight - 40
        let width =  itemWidthForLadscape//(height / heightToWidthRatioOfItemCellForLandscape)
        return CGSize(width: width, height: height)
    }
    static var potraitCellSize: CGSize {
        let height = itemHeightForPortrait//potraitRowHeight - 40
        let width = itemWidthForPortrait//(height / heightToWidthRatioOfItemCellForPotrait)
        return CGSize(width: width, height: height)
    }
    
}

var rowHeightForPotraitForLanguageGenreScreen: CGFloat {
    return rowHeightForPotrait
}
var rowHeightForLandscapeForLanguageGenreScreen: CGFloat {
    return rowHeightForLandscape
}
struct PlayerSliderConstants {
    static let widthOfProgressBar: CGFloat = 1720
    static let widthOfSlider: CGFloat = 30
}
struct PlayerRecommendationSize {
    static let heightToWidthRatioOfItemCellForPotrait: CGFloat = 1.54
    static let heightToWidthRatioOfItemCellForLandscape: CGFloat = 0.78
    static var landscapeRowHeight: CGFloat {
        let height: CGFloat =  itemHeightForLandscapeForTitleAndSubtitle// 306 + 30//rowHeightForLandscape
        return height
    }
    static var potraitRowHeight: CGFloat {
        let height: CGFloat = rowHeightForPotrait//470 + 30 //rowHeightForPotrait
        return height
    }
    static var landscapeCellSize: CGSize {
        let height = itemHeightForLandscapeForTitleOnly//landscapeRowHeight - 40
        let width = itemWidthForLadscape//(height / heightToWidthRatioOfItemCellForLandscape)
        return CGSize(width: width, height: height)
    }
    static var potraitCellSize: CGSize {
        let height = itemHeightForPortrait - 90//potraitRowHeight - 40
        let width = itemWidthForPortrait//(height / heightToWidthRatioOfItemCellForPotrait)
        return CGSize(width: width, height: height)
    }
    
    static func bottomConstarint(_ appType: VideoType) -> CGFloat {
//        if appType == .Movie {
//            return -(rowHeightForPotrait - 60)
//        } else {
            return -(rowHeightForLandscape - 60)
//        }
        
    }
}


//MARK:- Google Analytics Constants

//Event Category
let LOGIN_EVENT = "Login"
let PLAYER_OPTIONS = "Player Options"


//Event Action
let SUCCESS_ACTION = "Success"
let FAILURE_ACTION = "Failure"
let VIDEO_ACTION = "Video Play"
let VIDEO_START_EVENT = "Video Start"
let VIDEO_END_EVENT = "Video End"

//Event Comment
let LOGGEDIN_SUCCESSFUL = "Logged in successfully"
let ContentNotAvailable_msg = "#51 This content is unavailable."


//Settings Text
var IsAutoPlayOn: Bool {
    get {
        return UserDefaults.standard.bool(forKey: isAutoPlayOnKey)
    }
    set {
        UserDefaults.standard.setValue(newValue, forKeyPath: isAutoPlayOnKey)
    }
}

var IsParentalControlOn = true


let AutoPlayHeading = "AutoPlay"
let Subtitleheading = "Subtitle"
let ParentalHeading = "Parental Control"
let ValidPinAlertMsg = "Please enter valid Parental PIN"
let ParentalControlAlertMsg = "Now set Parental Controls based on maturity rating"
let FAQText = "1. What is JioCinema? \n\nJioCinema is an app that offers you a huge collection of movies across languages and genres. It also features TV shows, music videos, short clips and trailers. All you need to do is just demand and watch your favourite film, TV show or trailer. \n\n2. Do I need to be connected to the internet to use JioCinema? \n\nYes, while the app player automatically adjusts itself to your available internet speed, you can experience it best with an internet speed of 2 Mbps or above. \n\n3. What are the key features of JioCinema? \n\nJioCinema enables you to view your favourite movies, TV shows, trailers and videos. Few of our unique features are: \n\n1. Resume Watching - Watch movies and TV Shows across any of your devices from where you last paused on any other device. \n2. Watch List Feature - Add your favourite TV shows and movies to your watch list and view them anytime as per your convenience. \n3. Auto Play TV Series - If you are watching a TV show, the next episode of the show starts automatically when the current one ends. There is no need for you to search for the next episode and then hit play. \n\n4. How can I watch a movie or TV show on JioCinema? \n\nClick on any Movie or TV Show available on the Home or other screens of the app. If you have a particular movie in mind, go to Search and type the movie title; or search by your favourite actor, genre etc. \n\n5. How can I view movies and TV shows of my favourite actor or director? \n\nYou can view search by your favourite tite,actor,director and tags related to a movie(e.g Chulbul Pandey) by clicking on. You can also voice search any content. You can also view content by star cast/director from the Movie Detail page - by selecting on the thumbnail of your favourite actor/director. \n\n6. Can I look up a TV show episode by month or year? \n\nYes. These filters are present on TV Show detail page. For TV Shows, which are not released season-wise, you can search for an episode using the 'Month' and 'Year' filters. For shows, which are released seasons-wise, you can search for an episode using the 'Season' filter. \n\n7. How many videos can I add to 'My Watchlist'? \n\n'My Watchlist' is your personalised movie and TV show queue on JioCinema. You can add any number of movies and TV shows to My Watchlist - and access them across devices. \n\n8. How often do you update content on JioCinema? \n\nWe constantly keep updating our content, adding new and latest Movies, TV shows, Music Videos and trailers to our library. \n\n9. How do I report an issue or provide feedback on JioCinema? \n\nYou can write to us and provide us feedback at jiocinema@jio.com. The feedback section is accessible from the ‘Settings’ Section. \n\n10. Where do I find out recently viewed movies/TV shows? \n\nAny movie or TV episode that you have not watched completely gets added in your 'Resume Watching' section. You can find 'Resume Watching' section on your Home screen. Your 'Resume Watching' section syncs across devices for same user credentials. \n\nI am not able to open the app. What should I do? \n\nEnsure you have the latest version of the app installed on your device. Check for network connectivity. If the above steps do not solve the issue, please write a mail to jiocinema@jio.com and report the issue. \n\n12. Can I share content on social pages? \n\nThe feature is not enabled on the app at present. \n\n13. Can I download a movie/TV show? \n\nNo. Currently we don't support download. \n\n14. Can I suggest a movie/TV show if that is not currently available with JioCinema? \n\nYes definitely. Please suggest content that you would like to watch on JioCinema through Feedback. Feedback can be accessed from the settings Section \n\n15. I receive 'Network is not available' message when I try to open JioCinema app. \n\nYou can check the following options: \n\n1. Please ensure your device internet has minimum of 2 Mbps speed. \n2. Pause all activities which consume lot of bandwidth (e.g. downloading content, video-chatting). \n\nIf the above steps do not solve the issue, please write a mail to jiocinema@jio.com and report the issue. \n\n16. How do I find out if the latest version of the app is installed in my device? Will it update automatically? \n\nJioCinema does not update automatically but whenever a new update is available, it will be communicated to you for update via Popup or regular app update option (when available) \n\n17. Can I have the interface page in my regional language? \n\nCurrently, we do not offer this function. \n\n18. Video is pixelated/freezing/breaking. How do I solve this issue? \n\nYou can check the following options: \n\n1. Please ensure your device internet has minimum of 2 Mbps speed. \n\n2. Pause all activities which consume lot of bandwidth (e.g. downloading content, video-chatting). \n\nIf the above steps do not solve the issue, please write a mail to jiocinema@jio.com and log the issue. \n\n19. I just bought a new device. How do I check if it is compatible with JioCinema services? \n\nJioCinema is compatible with Apple TV (4th Generation) with OS version 9.2"

let PrivacyPolicyText = "PRIVACY POLICY \nReliance Jio Digital Services Private Limited (\"Reliance Jio\") is committed to protecting the privacy of the users (\"you\" / \"your\" / \"yourself\") of its website / software applications offered by Reliance Jio (collectively, \"Applications\") and has provided this privacy policy (\"Policy\") to familiarize you with the manner in which Reliance Jio uses and discloses your information collected through the Applications.This Policy forms part and parcel of the End User License Agreement (\"EULA\"). Capitalized terms which have been used here but are undefined shall have the same meaning as attributed to them in the EULA. The terms of the Policy provided herein govern your use of any and all of the Applications and the information accessible on or from these Applications. The Policy also lays down how Reliance Jio may collect, use and share any information you provide. Reliance Jio reserves the right, at its discretion, to change, modify, add or remove portions of this Policy at any time. Reliance Jio recommends that you review this Policy periodically to ensure that you are aware of the current privacy practices. This Policy shall be construed as provided in compliance with Information Technology Act, 2000 as amended and read with the Information Technology (Reasonable Security Practices and Procedures and Sensitive Personal Data or Information) Rules, 2011. \n\n\n1. Collection of Information \n\n1. Reliance Jio may collect the following two types of information: \n\na. \"Personal Information\" which shall mean information which could reasonably be used to identify you personally, such as your name, email address, registration account details, physical address or other relevant personal details; and demographic information, such as gender, pin code or similar information. For the purpose of this policy, sensitive personal data or information has been considered as a part of Personal Information, which may include information such as password, financial information (details of bank account, credit card, debit card, or other payment instrument details). \n\nb. \"Non-Personal Information\" which shall mean information that does not identify you or any other individual, and includes session, web beacons and usage data, log data and aggregate information. We use this information to inter-alia deliver our web pages to you upon request, to tailor our Application/website to the interests of our users, to measure traffic within our Application/website, to improve the Application/website quality, functionality and interactivity and let advertisers know the geographic locations from where our visitors come. \n\nc. Reliance Jio may install cookies or other similar data collection software in your computer system/device for such purpose and you hereby consent to the same. We may use \"cookies\", beacons or similar electronic tools to collect information to assign each visitor a unique, random number as a User Identification (User ID) to understand the user's individual interests using the identified computer. Unless you voluntarily identify yourself (through registration, for example), we will have no way of knowing who you are, even if we assign a cookie to your computer. The only personal information a cookie can contain is information you supply. A cookie cannot read data off your hard drive. Our advertisers may also assign their own cookies to your browser (if you click on their ads), a process that we do not control. \n\n2. You represent that the information or data you provide from time to time is and shall be correct, current and updated and you have all the rights, permissions and consents to provide such information or data. Your providing the information or data and Reliance Jio’s consequent storage, collection, usage, transfer, access or processing of the same shall not be in violation of any third party agreement, laws, judgments, orders or decrees. \n\n\n2. Use of Information \n\n1. You may need to provide Reliance Jio with your Personal Information while registering yourself on any of the Applications. The information so provided by you to Reliance Jio or otherwise captured by Reliance Jio may be used for a number of purposes connected with Reliance Jio business operations which may include the following: \n\na. processing orders or applications; \n\nb. provisioning of services, testing or improvement of services, recommending various products or services including those of third parties; \n\nc. dealing with requests, enquiries and complaints, customer services and related activities; \n\nd. marketing products and services of Reliance Jio and its analysis; \n\ne. responding to your queries and fulfilling your requests for information regarding the Applications; \n\nf. notifying you of any new offers or services of Reliance Jio and sending you important information regarding the Applications, changes to any of Reliance Jio’s policies and/or other administrative information; \n\ng. keeping you informed about the latest content available on the Applications and special offers with respect to the same; \n\nh. sending you surveys and marketing communications that Reliance Jio believes may be of interest to you; \n\ni. conducting internal reviews and data analysis for the Applications; \n\nj. personalizing your experience while using the Applications by presenting advertising, products and offers tailored to you; \n\nk. if you wish to subscribe to any content package or service offered by Reliance Jio through the Applications, for completing your purchase. (For example, to have your payments processed, communicate with you regarding your purchase and provide you with related customer service); \n\nl. improving the services, content and advertising on the Applications; \n\nm. protecting the integrity of the Applications; and \n\nn. responding to judicial process and provide information to law enforcement agencies or in connection with an investigation on matters related to public safety, as permitted by law. \n\n\n2. Your Personal Information will be kept confidential to the maximum possible extent and will be used to support your relationship with Reliance Jio, to notify you of any updated information and new activities and other related functions offered by Reliance Jio. Any personally identifiable information provided by you will not be considered as sensitive if it is freely available and / or accessible in the public domain. Further, any comments, messages, blogs, scribbles etc. posted/uploaded/conveyed/communicated by users on the public sections of the Application becomes published content and is not considered personally identifiable information subject to this Policy. \n\n3. Reliance Jio may use Personal Information to verify whether you are entitled to access and use the Applications and the products and services made available through the Applications. This Personal Information may also be used to enable Reliance Jio to enhance your experience of the Applications. \n\n4. Further, with respect to Non-Personal Information automatically collected and stored in files, Reliance Jio uses this information to understand and analyze trends, to administer the Applications, to learn about user behavior on the Applications, and to gather demographic information about the user base as a whole. Reliance Jio may use this information in its marketing and advertising services. Reliance Jio may also use such information to measure traffic patterns on the Applications. As Non-Personal Information does not personally identify you, Reliance Jio may use and disclose Non-Personal Information for any purpose. \n\n\n3. Disclosure \n\n1. Reliance Jio does not sell or rent Personal Information. Personal Information may be disclosed under the following circumstances: \n\na. Reliance Jio may disclose your Personal Information to its affiliates, group companies, consultants, vendors and contractors who provide various services including, contact information verification, payment processing, customer service, website hosting, data analysis, infrastructure provision, IT services, and other similar services, under confidentiality restrictions, in order to enable such vendor and service providers to provide the services subscribed to by you; \n\nb. Reliance Jio may provide your information or data to its partners, associates, advertisers, service providers or other third parties to provide, advertise or market their legitimate products and/or services which may be of your interest. You will have the choice to 'opt out' of such marketing or promotional communications at your will; and \n\nc. As necessary or appropriate: (a) in any manner permitted under applicable law, including laws outside your country of residence; (b) to comply with legal process whether local or foreign; (c) to respond to requests from public and government authorities, including public and government authorities outside your country of residence; (d) to enforce Reliance Jio’s terms and conditions; (e) to protect Reliance Jio’s rights, privacy, safety or property, and/or that of Reliance Jio’s affiliates, you or others; and (f) to allow Reliance Jio to pursue available remedies or limit the damages that Reliance Jio may sustain. \n\nd. We may disclose to third party services certain personally identifiable information listed below: \n\ni. information you provide us such as name, email, mobile phone number. \n\nii. information we collect as you access and use our service, including device information, location and network carrier. \n\ne. This information is shared with third party service providers so that we can: \n\ni. personalize the app for you. \n\nii. perform behavioral analytics. \n\n2. Your consent being part of the terms and conditions through which Reliance Jio provide you with a service. your consent to collecting Personal and Non-Personal Information may be implicit or implied or through course of conduct. \n\n3. Application may present display advertising and may collect data about traffic via Open X and/or Google Analytics, Demographics and Interest Reporting. \n\n\n4. Information Security and Storage \n\n1. Reliance Jio uses reasonable security measures, at the minimum those mandated under the Information Technology Act, 2000 as amended and read with Information Technology (Reasonable Security Practices and Procedures and Sensitive Personal Data or Information) Rules, 2011, to safeguard and protect your data and information. Reliance Jio implements such measures, as stated above, to protect against unauthorized access to, and unlawful interception of, Personal Information. You accept the inherent security implications of providing information over Internet/ cellular/data networks and will not hold Reliance Jio responsible for any breach of security or the disclosure of Personal Information unless Reliance Jio has been grossly and wilfully negligent. \n\n2. Your information or data will primarily be stored in electronic form. However, certain data can also be stored in physical form. Reliance Jio may store, collect, process and use your data in countries other than the Republic of India but under full compliance with applicable laws. Reliance Jio may enter into agreement with third parties (in or outside of India) to store your information or data. These third parties may have their own security standards to safeguard your information or data and Reliance Jio will on commercial reasonable basis require such third parties to adopt reasonable security standards to safeguard your information / data. \n\n3. Notwithstanding anything contained in this Policy or elsewhere, Reliance Jio shall not be held responsible for any loss, damage or misuse of your Personal Information, if such loss, damage or misuse is attributable to a Force Majeure Event. A \"Force Majeure Event\" shall mean any event that is beyond the reasonable control of Reliance Jio and shall include, without limitation, sabotage, fire, flood, explosion, acts of God, civil commotion, strikes or industrial action of any kind, riots, insurrection, war, acts of government, computer hacking, unauthorized access to computer data and storage device, computer crashes, breach of security and encryption, etc. \n\n\n5. Third Party Websites, Applications and Services \n\nThe Application/website may include links to other websites/applications. Such websites/application are governed by their respective privacy policies, which are beyond our control. Once you leave our servers (you can tell where you are by checking the URL in the location bar on your browser), use of any information you provide is governed by the privacy policy of the operator of the website/application you are visiting. That policy may differ from ours. If you can't find the privacy policy of any of these websites/application via a link from the website's homepage, you should contact the website/application directly for more information. \n\n\n6. Access, Correction and Deletion \n\nReliance Jio provides you with all information that Reliance Jio maintains about you such as the transaction and contact information upon proper verification. This may be provided to you on request, in case you experience any doubts. You may request access and/or correct the information Reliance Jio has collected from you by contacting Reliance Jio at jiocinema@jio.com . If you wish to have the information or data that you have provided to Reliance Jio deleted, you can always do so by sending a request to us on the e-mail id. You may note that correction or deletion of certain information or data may lead to cancellation of your registration with the Application(s) or your access to certain features of the Application(s). You also agree and acknowledge that certain data or information cannot be corrected or deleted or prohibited to be deleted as required under any applicable law, law enforcement requests or under any judicial proceedings. \n\n\nIf you have questions or concerns about this Policy, please contact Reliance Jio at jiocinema@jio.com \n\n\n  Copyright © 2016, Reliance Jio Digital Services Private Limited. All rights reserved."

let TermsAndConditionText = "This End User License Agreement along with the Privacy Policy (\"EULA\"), is a binding agreement between Reliance Jio Digital Services Private Limited (\"Reliance Jio\") and the end user who access or avail the Application (defined below) and the Content in accordance with the terms of their subscription plan and this EULA (\"you\"/\"your\") of the Application (defined below). This EULA is an electronic record under Information Technology Act, 2000 and the rules there under as applicable and the amended provisions pertaining to electronic records in various statutes under applicable Indian laws. This electronic record is generated by a computer system and does not require any physical or digital signatures.\nBY CLICKING ON THE \"I ACCEPT\" BUTTON AT THE END OF THE EULA, OR OTHERWISE HAVING ACCESS TO, RECEIVING, AND/OR USING THE JioCinema APPLICATION (\"APPLICATION\"), YOU HEREBY CONFIRM TO HAVE READ, UNDERSTOOD AND AGREE TO BE GOVERNED AND BOUND BY, THIS EULA, AND THE PRIVACY POLICY (\"POLICY\") WHICH IS INCORPORATED BY REFERANCE AND FORMS PART OF EULA AND ANY OTHER RULES OR GUIDELINES, AS MAY BE ISSUED BY RELIANCE JIO WITH RESPECT TO THE APPLICATION, FROM TIME TO TIME. YOU MAY ACCESS THE PRIVACY POLICY. IF YOU DO NOT AGREE TO BE BOUND BY THE EULA, PLEASE DO NOT CLICK THE \"I ACCEPT BUTTON OR DOWNLOAD OR INSTALL THE APPLICATION. \nReliance Jio reserves the right to modify the EULA at any time at its sole discretion, with or without any prior notice to you. It is your responsibility to review the EULA from time to time. You will be deemed to have accepted the terms of the EULA, as amended, if you continue to access the Application after the EULA is modified. Discontinuing use of this Application will not affect the applicability of the EULA to your prior uses of the Application. \nYou acknowledge and confirm that Reliance Jio is merely acting as a passive conduit to facilitate storage, transfer of the Content and therefore Reliance Jio is an intermediary under the Information Technology Act, 2000 as amended and the relevant rules made thereunder. This EULA is deemed to be published and shall be construed in accordance with the provisions of Rule 3 (1) of the Information Technology (Intermediaries guidelines) Rules, 2011 under Information Technology Act, 2000 that require publishing the rules and regulations, privacy policy and user agreement for access or usage of the Content. \n1. Registration: \n\n1. In order to access the any information, content ( including files, media, videos, music, images, text) which you may have authorized access to as part of, or through your use of, the Application, you will be required to download and install the Application on your Device (defined below). At the time of installation of the Application, the Application will require your permission to enable it to find the location of your Device, modify or delete SD card contents, read phone statistics and identity, mount and un-mount file systems, etc. You acknowledge that you are agreeable to providing such permissions. \n2. If you are under the age of 18 years, you should review this EULA with your parent or legal guardian to make sure that you and your parent or legal guardian understand and agree to it and further if required your parent / legal guardian shall perform or undertake such activities to enter into a legally binding agreement with Reliance Jio. \n3. In order to access and use the Content, you are required to create a user account with Reliance Jio for the Application. You agree not to reveal your user account information to anyone. You are solely responsible for maintaining the confidentiality and security of your user account and for all activities that occur on or through your user account. You agree to immediately notify Reliance Jio of any security breach of your user account. Reliance Jio shall not be responsible for any losses arising out of the unauthorized use of your user account. You confirm and warrant that all the data and information supplied by you when you register for subscribing the services and provided by you to Reliance Jio is true, current, complete and accurate in all respects. \n4. On creation of a user account and on subscribing to specific Content, you shall be able to access/view/stream/download the Content as per the subscription plan selected by you. You may at the sole discretion of Reliance Jio be permitted to write comments/reviews/feedback regarding the Content on social networking websites through the social networking capabilities incorporated in the Application. You shall not post any unlawful, threatening, abusive, libellous, defamatory, obscene, vulgar, pornographic, profane or indecent information of any kind, including, without limitation, any comments/reviews/feedback constituting or encouraging conduct that would constitute a criminal offence, give rise to civil liability or otherwise violate any local, state, national or international law or regulation. You give Reliance Jio express rights and consent to display your rating / review in relation to the relevant Content on the Application/website, including making it available to other members for viewing. These features may change without notice to you and the degrees of associated information sharing and functionality may also change without notice. \n5. Reliance Jio is free at its sole discretion to use any comments, information, ideas, concepts, reviews, or techniques or any other material contained in any communication you may send to us (\"User Feedback\"), including responses to questionnaires or through postings to the Application and user submissions, without further compensation, acknowledgement or payment to you for any purpose whatsoever including, but not limited to, developing, manufacturing and marketing products and creating, modifying or improving the Reliance Jio’s service offering including Application. By posting / submitting any User Feedback / user submission on the Application, you grant Reliance Jio a perpetual, worldwide, non-exclusive, royalty-free irrevocable, sub-licensable license and right in such User Feedback / user submission to Reliance Jio, including the right to display, use, reproduce, or modify the User Feedback / user submission in any media, software or technology of any kind now existing or developed in the future.  Reliance Jio reserves the right to remove User Feedback / user submission at sole discretion and/or upon on request of any third party that such User Feedback / user submission may create liability for Reliance Jio or harm the reputation of Reliance Jio or are offensive, inappropriate, defamatory, obscene or libelous in nature. \n6. Operators of public search engines have the permission to use functionalities like spiders to copy materials from the Application for the sole purpose of creating publicly available searchable indices of the materials, but not caches or archives of such materials. We reserve the right to revoke these exceptions either generally or in specific cases, in our sole discretion. You agree not to collect or harvest any personally identifiable information, including account names, from the Application, nor to use the communication systems provided by the Application for any commercial solicitation purposes. You agree not to solicit, for commercial purposes, any users of the Application with respect to its user submissions \n\n\n2. Grant of License: \n\n1. Software License: You hereby agree that all rights, title and interests in the Application vest with Reliance Jio or its licensors. Subject to your strict and full compliance with the EULA, Reliance Jio hereby grants you a revocable, non-exclusive, non-transferable, non-sub-licensable, limited license, to download, install and use the Application on Devices owned and controlled by you, and to access and use the Content only through the Application on such Devices, strictly in accordance with the terms of the EULA and as per the subscription plan selected by you. The Application includes (i) the software application in object code/source code that you may access and download and the scripts, interfaces, graphics, displays, text, documentation and other components/associated data and information made available to you as part of the software; and (ii) any updates, modifications, or enhancements to (i) or any part thereof, as may be provided by Reliance Jio \n2. Content License:  \"Content\" shall include all visual and audio-visual works, including all interactive content, texts, photographs, etc., made available to you through the Application.  The Content is owned by Reliance Jio or by third party content providers and licensed to Reliance Jio.  Subject to your strict and full compliance with the EULA, Reliance Jio, hereby grants you for a term of your subscription package and for the territory of India a personal, limited, non-exclusive, non-transferable, revocable license to use the Content for your private and personal use and non-commercial viewing/streaming/downloading, through your Device in accordance with the subscription plan selected by you. \n3. Except for the rights expressly stated herein, no other rights are granted to you with respect to the Application or the Content, either by implication, estoppel, or otherwise. \n\n\n3. Terms of Accessing the Application and the Content: \n\n1. The Application is merely intended as a means to deliver the Content. Your access to the Application and the Content signifies your consent to view / receive all such Content.  You agree and acknowledge that by use of the Application, you do not acquire ownership in the Application or the Content. You shall view the Content only by way of streaming/download or any other functionality provided by the Application only. You agree to view the Content for your personal, non-commercial use only, and strictly in the manner permitted under this EULA and in accordance with the subscription plan selected by you \n2. Application and all Content, including all text, graphics, trademarks, logos, photographs, audio visual content, and other material made available through the Application constitutes material proprietary to Reliance Jio or its content providers, and is protected by applicable intellectual property laws, and may not be used by You, except as permitted by Reliance Jio. \n3. Reliance Jio may, in its sole discretion, and without any obligation or liability towards you (including refund or credits for any subscription fee whether in full or in part thereof), add or delete one or more Content, or any feature from the Application, or modify the Subscription Fee (defined below) for the Content or any of your rights or authorizations at any time, without any notice to you. You agree to abide by the changes made under this provision. \n4. Use of the Application requires: (i) compatible devices including Internet enabled devices, now known or later developed, including all mobile devices, smart phones, phablets, tablets, television sets, personal digital assistants, gaming consoles, kiosks, portable players, wearable gear such as Google Eye Glass or the Samsung Gear, etc. (\"Device\"), and (ii) Internet access. Further, certain software (fees may apply), in your Device or in the Application may require periodic updates and use of the Application along with its performance may be affected by the performance of these factors. High-speed Internet access is strongly recommended for regular use. The latest version of the Application is recommended to access the Content and may be required for certain transactions or features. You agree that meeting these requirements, which may change from time to time, is your responsibility. \n5. From time to time, and without prior notice to you, Reliance Jio may provide updates of the Application, or may issue upgraded versions of the Application. However, Reliance Jio shall be under no obligation to do so. All updates/upgrades provided by Reliance Jio will be subject to the terms of this EULA. \n6. The Application may contain the links or pointers to other websites but you should not infer or assume that Reliance Jio operates, controls, or is otherwise connected with these other websites. When you click on a link within the Application, Reliance Jio may not warn you that you have left the Application and are subject to the terms and conditions (including privacy policies) of another website. Please be careful to read the terms of use and privacy policy of any other website before you provide any confidential information or engage in any transactions. You should not rely on this EULA to govern your use of another website. Reliance Jio is not responsible for the content or practices of any other website even if it links to the Application even if the website is operated by a company affiliated or otherwise connected with Reliance Jio. You acknowledge and agree that Reliance Jio is not responsible or liable to you for any content or other materials hosted and served from any website other than the Application. \n\n\n4. Restrictions on use of the Application and the Content \n\n1. You shall use the Application strictly in accordance with this EULA and shall not: (i) decompile, disassemble, reverse engineer or attempt to derive the source code of or in any manner decrypt the Application; (ii) make any modification, adaptation or improvement, enhancement, or derivative work from the Application or incorporate any portion of the software into your own programs or compile any portion of it in combination with your own programs, transfer it for use with another service; (iii) violate any applicable laws or regulations including but not limited to copyright act,  import and export control laws and regulations in connection with your access or use of the Application or the Content; (iv) remove or obscure any proprietary notice (including any notice of copyright or trademark) forming a part of the Application or the Content; (v) use the Application or the Content for any revenue generation endeavor, or any other purpose for which it is not designed or intended; (vi) install, use or permit the Application to exist on more than one Device at a  time or on any other applicable device, other than by means of your separate downloads of the Application, each of which is subject to a separate license; (vii) distribute or link the services being provided to multiple devices, or other services; (viii)  make available the Application over a network or other environment permitting access or use by multiple users at the same time or where it could be used by multiple devices at the same time, whether or not the same is for commercial use; (ix) use the Application for data mining, scraping, crawling, redirecting, or for any purpose not in accordance with the terms of the EULA; (x) use the Application to attempt to interfere with the proper display of the Content; (xi) use the Application for undertaking any hacking activities like breaching or attempt to breach the security of another user or attempt to gain access to any other person's computer, software or data without the knowledge and consent of such person; (xii) use the Application for creating a service or software that is directly or indirectly, competitive with the Application or any services offered by Reliance Jio; or (xiii) derive any confidential information, processes, data or algorithms from the Application. \n2. You also expressly agree not to engage in any use or activity that (a) may interrupt, destroy, alter, damage, delay, or limit the functionality or integrity of the Application or the Content including that of, any associated software, hardware, telecommunications or wireless equipment; (b) may manipulate identifiers, or numeric information to disguise the origin of any user, device, material or other information; (c) may interfere with the proper working of the Application or prevent others from using the Application; or (d) may delete the copyright and other proprietary rights notices on the Application. \n3. You agree not to use the Application for any activity relating to infringement of any intellectual property rights, including any trademarks, service marks, or trade names, privacy rights, personality rights, or any other proprietary rights of any third party. You shall not use the Application and access the Content through the Application outside the territory of the Republic of India, unless permitted by Reliance Jio.  Reliance Jio shall have the right to use various technologies and digital rights management mechanisms to enforce this territorial restriction and/or to verify your compliance with this restriction. \n4. Nothing contained herein shall be construed or implied to grant any right or license to use any trademarks, trade names, service marks or logos, which are a part of the Application or the Content, without the prior written consent of the owner of rights in such marks. \n5. You agree not to incorporate the Content into, or stream or retransmit the Content via, any hardware or software application or make it available via frames or in-line links unless expressly permitted by Reliance Jio. \n6. You shall not access the Content by any means other than through the Application  You shall, unless explicitly provided herein, neither directly nor through the use of any device, software, web-based service, or other means copy, download, stream capture, reproduce, duplicate, archive, distribute, upload, publish, / re-publish, modify, translate, broadcast, perform, publicly display, sell, transmit or retransmit, edit, re-use, adapt, incorporate or create any derivative works of, any Content streamed / viewed / downloaded from the Application. \n7. You are permitted to use and exploit a particular Content only in accordance with the rights granted by Reliance Jio for that particular Content in accordance with your subscription package. You agree not to, or permit anyone else to, circumvent, disable or otherwise interfere with security-related features and any digital rights management mechanisms of the Application including the features that prevent or restrict use or copying of any Content provided to you through the Application. You agree that Reliance Jio shall have no liability for, and you agree to defend, indemnify and hold Reliance Jio harmless against, any claims, losses or damages arising out of, or in connection with, your unauthorized use of any Content and/or Application. \n8. Reliance Jio does not endorse any Content made available through the Application, or any opinion, recommendation, or advice expressed thereon by any user and Reliance Jio expressly disclaims any and all liability in connection with such views or opinions or comments provided by the users. \n9. Reliance Jio shall use reasonable efforts to make the Content available to the users, at all times through the Application. However, the Content is provided over the Internet, data and cellular networks and so the quality and availability of the same may be affected by factors outside Reliance Jio’s control. Accordingly, Reliance Jio does not accept any responsibility for unavailability of the Application and/or Content, at any time.  Reliance Jio will not be responsible for any support or maintenance for the Application. \n10. Part of the Application may contain advertising information or promotion material or other material submitted to the Reliance Jio by third parties. Responsibility for ensuring that material submitted for inclusion on the Application complies with applicable international and national law is exclusively on the party providing the information/material. Your correspondence or business dealings with, or participation in promotions of advertisers including payment and delivery of related goods or services, and any other terms, conditions, warranties or representations associated with such dealings, are solely between you and such advertiser. Before relying on any advertising material, you should independently verify its relevance for your purpose, and should obtain appropriate professional advice. Reliance Jio shall not be responsible nor liable for any loss or claim that you may have against an advertiser or any consequential damages arising on account of you relying on the contents of the advertisement. \n\n\n5. Fees: \n\n1. The Application may be downloaded through an online store/e-store as per the terms and condition applicable for such download including this EULA. \n2. You hereby agree that for subscribing to any Content or any Content package (which may contain more than a single audio-visual content), you shall be required to pay the requisite subscription fee to Reliance Jio, as per the subscription plan selected by you (\"Subscription Fee\"). The Subscription Fee shall be inclusive of applicable taxes. \n3. At the time of subscribing for the Content, you agree to Reliance Jio's collection of the Subscription Fee associated with the subscribed Content as selected by you, through your credit (or debit) card/net banking using the payment gateway or through other modes of payment authorized by Reliance Jio. \n4. You understand and acknowledge that Reliance Jio only facilitates the third party payment gateway for processing of payment. This facility is managed by the third party payment gateway provider and you are required to follow all the terms and conditions of such third party payment gateway provider. You are responsible for the accuracy and authenticity of the information provided by you, including the bank account number/credit card details and the like. You agree and acknowledge that Reliance Jio shall not be liable and in no way be held responsible for any losses whatsoever, whether direct, indirect, incidental or consequential, including without limitation any losses due to delay in processing of payment instruction or any credit card fraud. \n5. Unless otherwise specified, Subscriptions Fee once paid is non-refundable except as provided under sub-Clause 5.6. The subscribed services will automatically be terminated once the subscription period is over and the Subscription Fee for renewal is not paid within a grace period of three (3) days after the expiry of the prior Subscription Period. \n6. You shall be entitled to a refund of the Subscription Fee on a pro-rata basis, only if Reliance Jio terminates the license to the Application and the Content, for no cause via mode and medium convenient to Reliance Jio. \n7. By using this Application, you acknowledge that the Content available via the Application may be accessed through telecommunications/internet connection. You are responsible for the provision of, and payment for, telecommunications/internet services including, the relevant network or data charges, roaming charges or other costs or fees and for any other items of hardware or communications equipment necessary to enable you to access the subscribed services.  Reliance Jio will not be responsible, nor will you be entitled for any refunds of Subscription Fee for unavailability of the Content due to disruption, unavailability, or failure in your telecommunications equipment or internet connection or other relevant services. \n\n\n6. Rights of Reliance Jio: \n\n1. Reliance Jio, in its sole discretion, may terminate or suspend your access to the Content without any obligation to serve any prior notice and without any obligations or liabilities towards you or towards any third parties, except as provided under Clause 5.6 above. \n2. Upon your breach of this EULA, the Policy or any other restrictions or guidelines of Reliance Jio for use of the Application and/or accessing any of the Content, Reliance Jio reserves the right to take any responsive actions which Reliance Jio may deem appropriate. Such actions may include (but may not be limited to) temporary or permanent removal of Content, termination of your subscription or immediate suspension or cancellation of your access to the Content via the Application, without any obligation of Reliance Jio to refund any Subscription Fee whether in whole or in any part thereof. \n3. Reliance Jio may take any other legal or technical action against you that Reliance Jio may deem appropriate, including any action against offenders to recover the costs and expenses of identifying them. \n4. Upon cancellation of your subscription service, Reliance Jio will be authorised to delete any files, programs, data and email messages associated with your account/usage. \n5. Reliance Jio may directly or through third party service providers send information to you about the various services offered by the Reliance Jio from time to time. \n\n\n7. Indemnity: \n\n1. You shall defend, indemnify and hold harmless, Reliance Jio, its affiliates, any third party networks / infrastructure providers and their respective directors, officers, personnel, contractors and agents, for and against any and all claims, suits, judgment, losses, damages, cost and expenses arising or relating to your use of the Application and/or the Content or your breach of the terms of the EULA or the Policy or any other restrictions or guidelines provided by Reliance Jio.  This indemnification obligation will survive this EULA and Your use of the Application / Content. \n\n\n8. Disclaimer of Warranties: \n\n1. THE APPLICATION AND ALL CONTENT PROVIDED THROUGH THE APPLICATION, IS PROVIDED ON AN \"AS-IS\" AND \"WITH ALL FAULTS AND RISKS\" BASIS, WITHOUT WARRANTIES OF ANY KIND. RELIANCE JIO DOES NOT WARRANT, EXPRESSLY OR BY IMPLICATION, THE ACCURACY OR RELIABILITY OF THE APPLICATION OR ANY CONTENT OR ITS SUSTAINABILITY FOR A PARTICULAR PURPOSE.  TO THE MAXIMUM EXTENT PERMITTED UNDER APPLICABLE LAWS, RELIANCE JIO DISCLAIMS ALL WARRANTIES WHETHER EXPRESS OR IMPLIED, INCLUDING THOSE OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, OR THAT USE OF THE APPLICATION AND THE CONTENT OR ANY MATERIAL THEREOF WILL BE UNINTERRUPTED OR ERROR-FREE OR THAT ANY CONTENT WILL BE AVAILABLE THROUGHOUT TERM AS PER USER'S SUBSCRIPTION PACKAGE.  WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, RELIANCE JIO DOES NOT REPRESENT OR WARRANT THAT THE APPLICATION WILL RESULT IN COMPLIANCE, FULFILLMENT OR CONFORMITY WITH THE LAWS, REGULATIONS, REQUIREMENTS OR GUIDELINES OF ANY GOVERNMENT OR GOVERNMENTAL AGENCY. \n2. To the maximum extent permitted by applicable law, Reliance Jio provides no warranty on use of the Content and shall not be liable for the same under intellectual property rights, libel, privacy, publicity, obscenity or other laws. Reliance Jio also disclaims all liability with respect to the misuse, loss, modification or unavailability of any Content \n\n\n9. Limitation of Liability: \n\n1. YOU ASSUME THE ENTIRE RISK OF USING THE APPLICATION AND THE CONTENT.  TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL RELIANCE JIO BE LIABLE TO YOU FOR ANY SPECIAL, INCIDENTAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF USE, LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF, OR INABILITY TO USE OR ACCESS, THE APPLICATION OR THE CONTENT OR FOR ANY SECURITY BREACH OR ANY VIRUS, BUG, UNAUTHORIZED INTERVENTION, DEFECT, OR TECHNICAL MALFUNCTIONING OF THE APPLICATION, WHETHER OR NOT FORESEEABLE OR WHETHER OR NOT RELIANCE JIO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, OR BASED ON ANY THEORY OF LIABILITY, INCLUDING BREACH OF CONTRACT OR WARRANTY, NEGLIGENCE OR OTHER TORTIOUS ACTION, OR ANY OTHER CLAIM ARISING OUT, OF OR IN CONNECTION WITH, YOUR USE OF, OR ACCESS TO, THE APPLICATION OR THE CONTENT. FURTHER, RELIANCE JIO SHALL NOT BE LIABLE TO YOU FOR ANY TEMPORARY DISABLEMENT, PERMANENT DISCONTINUANCE OR MODIFICATION OF THE APPLICATION BY RELIANCE JIO OR FOR ANY CONSEQUENCES RESULTING FROM SUCH ACTIONS. \n2. RELIANCE JIO'S AGGREGATE LIABILITY (WHETHER UNDER CONTRACT, TORT INCLUDING NEGLIGENCE, WARRANTY OR OTHERWISE) AND THAT OF ITS AFFILIATES SHALL BE LIMITED TO THE AGGREGATE SUBSCRIPTION AMOUNT LAST PAID BY YOU TO ACCESS AND VIEW THE CONTENT. \n\n\n10. Governing Law: \n\n1. This EULA is governed and construed in accordance with the laws of India. The courts in Mumbai shall have exclusive jurisdiction to hear disputes arising out of the EULA. \n\n\n11. Force Majeure: \n\n1. Reliance Jio shall be under no liability whatsoever in the event of non-availability of any portion of the Application or subscribed Content occasioned by act of God, war, disease, revolution, riot, civil commotion, strike, lockout, flood, fire, failure of any public utility, man-made disaster, infrastructure failure or any other cause whatsoever beyond the control of Reliance Jio. \n\n\n12. Copyright Notice and Notice for other Grievances: \n\n1. In accordance with the applicable laws, for any grievance including if, you believe in good faith that the Content or any information viewed through the Application infringes your copyright, you may reach us at jiocinema@jiocom. \n\n\n13. Waiver: \n\n1. Any failure by Reliance Jio to enforce the EULA, for whatever reason, shall not necessarily be construed as a waiver of any right to do so at any time. \n\n\n14. Severability: \n\n1. If any of the provisions of this EULA are deemed invalid, void, or for any reason unenforceable, that part of the EULA will be deemed severable and will not affect the validity and enforceability of any remaining provisions of the EULA. \n\n\n15. Entire Agreement: \n\n1. The EULA including the Policy, as amended from time to time, constitutes the entire agreement between the parties and supersedes all prior understandings between the parties relating to the subject matter herein. \n\n\n16. Limited Time To Bring Your Claim: \n\n1. You and Reliance Jio agree that any cause of action arising out of or related to use of the Application or the Content must commence within one (1) year after the cause of action accrues otherwise, such cause of action will be permanently barred. \n\n\n Copyright © 2014, Reliance Jio Digital Services Private Limited. All rights reserved."



