//
//  Utility.swift
//  JioCinema
//
//  Created by Atinderpal Singh on 04/10/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ReachabilitySwift

class Utility
{
    static let sharedInstance = Utility()
    var reachability: Reachability?
    var isNetworkAvailable = false

    // MARK:- Network Notifier
    func startNetworkNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        reachability = Reachability.init()
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let r = note.object as! Reachability
        if r.isReachable {
            isNetworkAvailable = true
            if let isRechable = (reachability?.isReachableViaWiFi), isRechable {
                print("Reachable via WiFi")
                
            } else {
                print("Reachable via Cellular")
            }
        } else {
            isNetworkAvailable = false
            print("Network not reachable")
            let alertController = UIAlertController.init(title: networkErrorMessage, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
                exit(0)
            }))
            appDelegate?.window?.rootViewController?.present(alertController, animated: false, completion: nil)
        }
    }
    // MARK:- Show Alert
     func showAlert(viewController: UIViewController, title: String, message: String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    struct AlertAction {
        var title: String
        var style: UIAlertActionStyle
    }
    //MARK: Apply Gradient
    class func applyGradient(_ view: UIView) {
        let initalColor = #colorLiteral(red: 0.1068576351, green: 0.1179018542, blue: 0.1013216153, alpha: 1).cgColor
        let finalColor = UIColor.clear.cgColor
        
        let colors2 = [initalColor, finalColor, finalColor, finalColor]
        
        let layer2 = CAGradientLayer()
        layer2.colors = colors2
        layer2.frame = view.bounds
        layer2.startPoint = CGPoint(x: 0, y: 1)
        layer2.endPoint = CGPoint(x: 0, y: 0)
        view.layer.insertSublayer(layer2, at: 0)
        
        let layer = CAGradientLayer()
        layer.colors = colors2
        let newRect = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: view.bounds.width, height: view.bounds.height * 0.95)
        layer.frame = newRect
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0) //: CGPoint(x: 1, y: 0)
        view.layer.insertSublayer(layer, at: 1)
        
    }
    
    class func getCustomizedAlertController(with title: String, message: String, actions: [AlertAction]?, _ responseHandlerForAction: (( UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        if let actions = actions {
            for each in actions {
                let newAction = UIAlertAction(title: each.title, style: each.style, handler: responseHandlerForAction)
                alertController.addAction(newAction)
            }
        }
        return alertController
    }
    
    func showDismissableAlert(title: String, message: String)
    {
        let topVC = UIApplication.topViewController()
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
               exit(0)
            }))
            topVC?.present(alert, animated: true, completion: nil)
        }
    }
    
    func encodeStringWithBase64(aString: String?) -> String
    {
        if aString != nil
        {
            let encodedData = aString?.data(using: .utf8)
            let encodedString = encodedData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            return encodedString!
        }
        return ""
    }
    
    func handleScreenNavigation(screenName:String, toScreen: String, duration: Int)
    {
      let snavInternalEvent = JCAnalyticsEvent.sharedInstance.getSNAVEventForInternalAnalytics(currentScreen: screenName, nextScreen: toScreen, durationInCurrentScreen: String(duration))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: snavInternalEvent)
    }
    
    //MARK:- Check Video type
    class func checkType(_ typeString: String) -> VideoType {
        switch typeString.capitalized {
        case "Movies":
            return .Movie
        case "TV Shows":
            return .TVShow
        case "Music":
            return .Music
        case "Trailer":
            return .Trailer
        case "Clip":
            return .Clip
        default:
            return .None
        }
    }
    
    //MARK:- Player View Controller Preparation method
    func preparePlayerVC(_ itemId: String, itemImageString: String, itemTitle: String, itemDuration: Float, totalDuration: Float, itemDesc: String, appType: VideoType, isPlayList: Bool = false, playListId: String = "", isMoreDataAvailable: Bool = false, isEpisodeAvailable: Bool = false, recommendationArray: Any = false, fromScreen: String, fromCategory: String, fromCategoryIndex: Int, fromLanguage: String, director: String? = nil, starCast: String? = nil, vendor: String? = nil) -> JCPlayerVC  {
        
        let playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        
        playerVC.id = itemId
        playerVC.bannerUrlString = itemImageString
        playerVC.itemTitle = itemTitle
        playerVC.currentDuration = itemDuration
        playerVC.totalDuration = totalDuration
        playerVC.itemDescription = itemDesc
        playerVC.appType = appType
        playerVC.isPlayList = isPlayList
        playerVC.playListId = playListId
        
        playerVC.fromScreen = fromScreen
        playerVC.fromCategory = fromCategory
        playerVC.fromCategoryIndex = fromCategoryIndex
        
        playerVC.isEpisodeDataAvailable = isEpisodeAvailable
        playerVC.isMoreDataAvailable = isMoreDataAvailable
        
        if isEpisodeAvailable{
            playerVC.episodeArray = recommendationArray as! [Episode]
        }
        else if isMoreDataAvailable{
            playerVC.moreArray = recommendationArray as! [More]
        }
        playerVC.director = director ?? ""
        playerVC.starCast = starCast ?? ""
        playerVC.vendor = vendor ?? ""
        return playerVC
    }
    
    //MARK:- Metadata View Controller Preparation method
    func prepareMetadata(_ itemToBePlayedId: String, appType: VideoType, fromScreen: String, categoryName: String, categoryIndex: Int, tabBarIndex: Int, shouldUseTabBarIndex: Bool = false, isMetaDataAvailable: Bool = false, metaData: Any? = nil, languageData: Any? = nil) -> JCMetadataVC {
        print("show metadata")
        let metadataVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: metadataVCStoryBoardId) as! JCMetadataVC
        metadataVC.itemId = itemToBePlayedId
        metadataVC.itemAppType = appType
        metadataVC.categoryName = categoryName
        metadataVC.categoryIndex = categoryIndex
        metadataVC.fromScreen = fromScreen
        metadataVC.tabBarIndex = tabBarIndex
        metadataVC.shouldUseTabBarIndex = shouldUseTabBarIndex
        metadataVC.isMetaDataAvailable = isMetaDataAvailable
        if let metaData = metaData as? MetadataModel{
            metadataVC.metadata = metaData
        }
        if let langData = languageData as? Item {
            metadataVC.languageModel = langData
        }
       // metadataVC.modalPresentationStyle = .overFullScreen
        //metadataVC.modalTransitionStyle = .coverVertical
        return metadataVC
    }
    
    //MARK:- Login View Controller Preparation method
    func prepareLoginVC(fromAddToWatchList: Bool = false, fromPlayNowBotton: Bool = false, fromItemCell: Bool = false, presentingVC: Any) -> JCLoginVC
    {
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: loginVCStoryBoardId) as! JCLoginVC
        loginVC.isLoginPresentedFromItemCell = fromItemCell
        loginVC.isLoginPresentedFromAddToWatchlist = fromAddToWatchList
        loginVC.isLoginPresentedFromPlayNowButtonOfMetaData = fromPlayNowBotton
        loginVC.presentingVCOfLoginVc = presentingVC
        //loginVC.modalPresentationStyle = .overFullScreen
        //loginVC.modalTransitionStyle = .coverVertical
        loginVC.view.layer.speed = 0.7
        return loginVC
    }
    //MARK:- LanguageGenre View Controller Preparation method
    func prepareLanguageGenreVC(languageModel: Item, metadataToBePlayedId: String, metadataAppType: VideoType, metadataFromScreen: String, metadataCategoryName: String, metadataCategoryIndex: Int, metadataTabBarIndex: Int, shouldUseTabBarIndex: Bool = false, isMetaDataAvailable: Bool = false, metaData: Any? = nil) -> JCLanguageGenreVC {
        let languageGenreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreStoryBoardId) as! JCLanguageGenreVC
        languageGenreVC.item = languageModel
        languageGenreVC.metadataToBePlayedId = metadataToBePlayedId
        languageGenreVC.metadataAppType = metadataAppType
        languageGenreVC.metadataCategoryName = metadataCategoryName
        languageGenreVC.metadataCategoryIndex = metadataCategoryIndex
        languageGenreVC.metadataFromScreen = metadataFromScreen
        languageGenreVC.metadataTabBarIndex = metadataTabBarIndex
        languageGenreVC.shouldUseTabBarIndex = shouldUseTabBarIndex
        languageGenreVC.isMetaDataAvailable = isMetaDataAvailable
        if let metaData = metaData as? MetadataModel{
            languageGenreVC.metaData = metaData
        }
        return languageGenreVC
    }
    
    
    //MARK:- Search container View Controller Preparation method
    func prepareSearchViewController(searchText: String) -> UISearchController {
        let searchVC = JCSearchResultViewController.init(nibName: "JCBaseVC", bundle: nil)
        searchVC.view.backgroundColor = .black
        
        let searchViewController = JCSearchViewController(searchResultsController: searchVC)
        searchViewController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        searchViewController.view.backgroundColor = .black
        searchViewController.searchBar.placeholder = "Search"
        searchViewController.searchBar.tintColor = UIColor.white
        searchViewController.searchBar.barTintColor = UIColor.black
        searchViewController.searchBar.tintColor = UIColor.gray
        searchViewController.hidesNavigationBarDuringPresentation = true
        searchViewController.obscuresBackgroundDuringPresentation = false
        searchViewController.searchBar.delegate = searchVC
        searchViewController.searchBar.searchBarStyle = .minimal
        searchVC.searchViewController = searchViewController
        return searchViewController
    }
    //MARK:- Converting Item array to More Array
    func convertingItemArrayToMoreArray(_ itemArray: [Item]) -> [More] {
        var moreArray = [More]()
        for each in itemArray{
            let more = More()
            more.id = each.id
            more.name = each.name
            more.subtitle = each.subtitle
            more.format = each.format
            more.banner = each.banner
            more.language = each.language
            more.app = each.app
            more.description = each.description
            more.totalDuration = each.totalDurationInt
            more.srt = ""
            more.totalDurationString = each.totalDuration
            more.image = each.image
            moreArray.append(more)
        }
        return moreArray
        
    }
    
    
    //MARK: Getting Carousal View in TableViewHeader
    class func getHeaderForTableView(for delegate: JCCarouselCellDelegate, with carouselItems: [Item]) -> InfinityScrollView {
        let carousalView = Bundle.main.loadNibNamed("kInfinityScrollView", owner: delegate, options: nil)?.first as! InfinityScrollView
            carousalView.carouselArray = carouselItems
            carousalView.loadViews()
            carousalView.carouselDelegate = delegate
        return carousalView
    }
    
    
    
    //MARK: Getting customized string
    struct StringAttribute {
        var fontName = "HelveticaNeue-Bold"
        var fontSize: CGFloat?
        var initialIndexOftheText = 0
        var lastIndexOftheText: Int?
        var color: UIColor = .black
        
        var fontOfText: UIFont {
            if let font = UIFont(name: fontName, size: fontSize!) {
                return font
            } else {
                return UIFont(name: "HelveticaNeue-Bold", size: fontSize!)!
            }
            
        }
    }
    
    class func getFontifiedText(_ text: String, partOfTheStringNeedTOConvert partTexts: [StringAttribute]) -> NSAttributedString {
        let fontChangedtext = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: (partTexts.first?.fontSize)!)!])
        for eachPartText in partTexts {
            let lastIndex = eachPartText.lastIndexOftheText ?? text.count
            let attrs = [NSAttributedStringKey.font : eachPartText.fontOfText, NSAttributedStringKey.foregroundColor: eachPartText.color]
            let range = NSRange(location: eachPartText.initialIndexOftheText, length: lastIndex - eachPartText.initialIndexOftheText)
            fontChangedtext.addAttributes(attrs, range: range)
        }
        return fontChangedtext
    }
    
}

extension Date {
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
extension String {
    func subString(start: Int, end: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: end)
        
        let finalString = self.substring(from: startIndex)
        return finalString.substring(to: endIndex)
    }

    //Converting String to float
    func floatValue() -> Float? {
            if let floatval = Float(self) {
                return floatval
            }
            return nil
        }
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    //Height of the label according to the textlength
    func heightForWithFont(font: UIFont, width: CGFloat, insets: UIEdgeInsets) -> CGFloat {
        let rect = CGRect(x: 0, y: 0, width: width + insets.left + insets.right, height: .greatestFiniteMagnitude)
        let label:UILabel = UILabel(frame: rect)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self
        
        label.sizeToFit()
        return label.frame.height + insets.top + insets.bottom
    }
    
    //MARK: Getting customized string
    struct StringAttribute {
        var fontName = "HelveticaNeue-Bold"
        var fontSize: CGFloat?
        var initialIndexOftheText = 0
        var lastIndexOftheText: Int?
        var color: UIColor = .black
        
        var fontOfText: UIFont {
            if let font = UIFont(name: fontName, size: fontSize!) {
                return font
            } else {
                return UIFont(name: "HelveticaNeue-Bold", size: fontSize!)!
            }
        }
    }
    func getFontifiedText(partOfTheStringNeedToConvert partTexts: [StringAttribute]) -> NSAttributedString {
        let fontChangedtext = NSMutableAttributedString(string: self, attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: (partTexts.first?.fontSize)!)!])
        for eachPartText in partTexts {
            let lastIndex = eachPartText.lastIndexOftheText ?? self.count
            let attrs = [NSAttributedStringKey.font : eachPartText.fontOfText, NSAttributedStringKey.foregroundColor: eachPartText.color]
            let range = NSRange(location: eachPartText.initialIndexOftheText, length: lastIndex - eachPartText.initialIndexOftheText)
            fontChangedtext.addAttributes(attrs, range: range)
        }
        return fontChangedtext
    }
    
    
    
    
}
extension UIView {
    func setRadius(radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.width / 2;
        self.layer.masksToBounds = true;
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
