//
//  Utility.swift
//  JioCinema
//
//  Created by Atinderpal Singh on 04/10/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import Reachability

class Utility {
    static let sharedInstance = Utility()
    var reachability: Reachability?
    var isNetworkAvailable = false
    var activityIndicator = UIActivityIndicatorView()

    // MARK:- Network Notifier
    func startNetworkNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: Notification.Name.reachabilityChanged,object: reachability)
        reachability = Reachability.init()
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        guard let r = note.object as? Reachability else {return}
        if r.connection != .none {
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
     func showAlert(viewController: UIViewController? = nil, title: String, message: String) {
        var vc = viewController
        if vc == nil {
            vc = UIApplication.topViewController()
        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            vc?.present(alert, animated: true, completion: nil)
        }
    }
    struct AlertAction {
        var title: String
        var style: UIAlertAction.Style
    }
    //MARK: Apply Gradient
    class func applyGradient(_ view: UIView, _ initialColor : CGColor) {
        let initalColor  = initialColor
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
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
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
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
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
            return encodedString ?? ""
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
//    func preparePlayerVC(_ itemId: String, itemImageString: String, itemTitle: String, itemDuration: Float, totalDuration: Float, itemDesc: String, appType: VideoType, isPlayList: Bool = false, playListId: String = "",latestId : String?, isMoreDataAvailable: Bool = false, isEpisodeAvailable: Bool = false, recommendationArray: Any = false, fromScreen: String, fromCategory: String, fromCategoryIndex: Int, fromLanguage: String, director: String? = nil, starCast: String? = nil, vendor: String? = nil, isDisney: Bool = false, audioLanguage: AudioLanguage? = nil) -> JCPlayerVC  {
//        
//        let playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
//        
//        playerVC.id = itemId
//        playerVC.bannerUrlString = itemImageString
//        playerVC.itemTitle = itemTitle
//        playerVC.currentDuration = itemDuration
//        playerVC.totalDuration = totalDuration
//        playerVC.itemDescription = itemDesc
//        playerVC.appType = appType
//        playerVC.isPlayList = isPlayList
//        playerVC.playListId = playListId
//        playerVC.latestId = latestId
//        
//        playerVC.fromScreen = fromScreen
//        playerVC.fromCategory = fromCategory
//        playerVC.fromCategoryIndex = fromCategoryIndex
//        
//        playerVC.isEpisodeDataAvailable = isEpisodeAvailable
//        playerVC.isMoreDataAvailable = isMoreDataAvailable
//        
//        playerVC.isDisney = isDisney
//        playerVC.audioLanguage = audioLanguage
//        playerVC.defaultLanguage = fromLanguage
//        
//        if isEpisodeAvailable {
//            playerVC.episodeArray = recommendationArray as? [Episode] ?? []
//        }
//        else if isMoreDataAvailable {
//            playerVC.moreArray = recommendationArray as? [Item] ?? []
//        }
//        playerVC.director = director ?? ""
//        playerVC.starCast = starCast ?? ""
//        playerVC.vendor = vendor ?? ""
//        return playerVC
//    }
    func prepareAndPresentCustomPlayerVC(item: Item, recommendationArray: Any = false, subtitles: String? = "", audios: String? = "")-> PlayerViewController{
        let playerVC = PlayerViewController.init(item: item, subtitles: subtitles, audios: audios)
        playerVC.recommendationArray = recommendationArray
        //toBepresentedOnScreen.present(playerVC, animated: true, completion: nil)
        return playerVC
    }
    
    //MARK:- Metadata View Controller Preparation method
    func prepareMetadata(_ itemToBePlayedId: String, appType: VideoType, fromScreen: String, categoryName: String, categoryIndex: Int, tabBarIndex: Int?, shouldUseTabBarIndex: Bool = false, isMetaDataAvailable: Bool = false, metaData: Any? = nil, modelForPresentedVC: Any? = nil, vcTypeForArtist: VCTypeForArtist? = nil, isDisney: Bool = false, defaultAudioLanguage: AudioLanguage? = nil, currentItem: Item? = nil) -> JCMetadataVC {

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
        
        metadataVC.item = currentItem
        if let metaData = metaData as? MetadataModel {
            metadataVC.metadata = metaData
        }
        if let vcType = vcTypeForArtist {
            metadataVC.presentingVcTypeForArtist = vcType
        }
        if let langData = modelForPresentedVC as? Item {
            metadataVC.modelForPresentedVC = langData
        }
        metadataVC.defaultAudioLanguage = defaultAudioLanguage
        
        metadataVC.isDisney = isDisney
        return metadataVC
    }

    //MARK:- Login View Controller Preparation method
    func prepareLoginVC(fromAddToWatchList: Bool = false, fromPlayNowBotton: Bool = false, fromItemCell: Bool = false, presentingVC: Any?) -> JCLoginVC
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
    func convertingItemArrayToMoreArray(_ itemArray: [Item]) -> [Item] {
        return itemArray
        /*
        var moreArray = [Item]()
        for each in itemArray{
            var more = Item()
            more.id = each.id
            more.name = each.name
            more.subtitle = each.subtitle
            more.format = each.format
            more.banner = each.banner
            more.language = each.language
            more.app = each.app
            more.description = each.description
            more.totalDuration = each.totalDuration
            more.srt = ""
            more.totalDurationString = each.totalDuration
            more.image = each.image
            moreArray.append(more)
        }
        return moreArray
        */
    }
    
    //MARK:- Getting Xibs
    class func getXib<T>(_ name: String, type: T.Type, owner: Any) -> T {
        let viewArray = Bundle.main.loadNibNamed(name, owner: owner, options: nil)
        let view = viewArray?.first as! T
        return view
    }
    
    class func getFooterHeight(_ data: BaseDataModel?, loadedPage: Int) -> CGFloat {
        if let data = data {
            if loadedPage >= ((data.totalPages ?? 0) ) {
                return 0
            } else {
                return 60
            }
        }
        return 0
    }
    
    class func baseTableViewInBaseViewController(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextIndexPath = context.nextFocusedIndexPath, let prevIndexPath = context.previouslyFocusedIndexPath {
            guard nextIndexPath != prevIndexPath else {return}
            Utility.changeTableCellAlphaForbaseTableView(tableView, indexpath: nextIndexPath, alpha: 1.0, textColor: .white)
            Utility.changeTableCellAlphaForbaseTableView(tableView, indexpath: prevIndexPath, alpha: 0.5, textColor: #colorLiteral(red: 0.5843137255, green: 0.5843137255, blue: 0.5843137255, alpha: 1))
        } else if let nextIndexPath = context.nextFocusedIndexPath {
            Utility.changeTableCellAlphaForbaseTableView(tableView, indexpath: nextIndexPath, alpha: 1.0, textColor: .white)
        } else if let prevIndexPath = context.previouslyFocusedIndexPath {
            Utility.changeTableCellAlphaForbaseTableView(tableView, indexpath: prevIndexPath, alpha: 0.5, textColor: .white)
        }
    }
    
    class func changeTableCellAlpha(_ tableView: UITableView, indexpath: IndexPath, alpha: CGFloat, textColor: UIColor) {
        let cell = tableView.cellForRow(at: indexpath) as! JCBaseTableViewCell
        cell.categoryTitleLabel.textColor = textColor
        cell.contentView.alpha = alpha
    }
    
    class func changeTableCellAlphaForbaseTableView(_ tableView: UITableView, indexpath: IndexPath, alpha: CGFloat, textColor: UIColor) {
        let cell = tableView.cellForRow(at: indexpath) as! BaseTableViewCell
        cell.categoryTitleLabel.textColor = textColor
        cell.itemCollectionView.alpha = alpha
    }
    
    // pass seconds to this function it will return hour,min,seconds
    class func getTimeInFormatedStringFromSeconds(seconds : Int) -> String {
        if seconds > 3600 {
            return self.getStringForFormattedDate(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60, seconds)
        } else {
            return self.getStringForFormattedDate(nil,(seconds % 3600) / 60, (seconds % 3600) % 60,seconds)
        }
    }
    class func getStringForFormattedDate(_ h: Int? ,_ m: Int ,_ s: Int,_ itemDuration: Int) -> String {
//        let (h,m,s) = Utility.getTimeInFormatFromSeconds(seconds: itemDuration)
        if let hour = h {
            return String(format: "%02d:%02d:%02d", hour,m,s)
        } else {
            return String(format: "%02d:%02d", m,s)
        }
    }
    
    //MARK: Getting customized string
    struct StringAttribute {
        var fontName = "JioType-Bold"
        var fontSize: CGFloat?
        var initialIndexOftheText = 0
        var lastIndexOftheText: Int?
        var color: UIColor = .black
        
        var fontOfText: UIFont {
            if let font = UIFont(name: fontName, size: fontSize ?? 18) {
                return font
            } else {
                return UIFont(name: "JioType-Bold", size: fontSize ?? 18)!
            }
            
        }
    }
    
    
    class func getFontifiedText(_ text: String, partOfTheStringNeedTOConvert partTexts: [StringAttribute]) -> NSAttributedString {
        let fontChangedtext = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont(name: "JioType-Bold", size: (partTexts.first?.fontSize ?? 18))!])
        for eachPartText in partTexts {
            let lastIndex = eachPartText.lastIndexOftheText ?? text.count
            let attrs = [NSAttributedString.Key.font : eachPartText.fontOfText, NSAttributedString.Key.foregroundColor: eachPartText.color]
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
        
        let finalString = self[startIndex...endIndex]
        
        return String(finalString)
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
        var fontName = "JioType-Bold"
        var fontSize: CGFloat?
        var initialIndexOftheText = 0
        var lastIndexOftheText: Int?
        var color: UIColor = .black
        
        var fontOfText: UIFont {
            if let font = UIFont(name: fontName, size: fontSize ?? 18) {
                return font
            } else {
                return UIFont(name: "JioType-Bold", size: fontSize ?? 18)!
            }
        }
    }
    func getFontifiedText(partOfTheStringNeedToConvert partTexts: [StringAttribute]) -> NSAttributedString {
        let fontChangedtext = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: UIFont(name: "JioType-Bold", size: (partTexts.first?.fontSize ?? 18))!])
        for eachPartText in partTexts {
            let lastIndex = eachPartText.lastIndexOftheText ?? self.count
            let attrs = [NSAttributedString.Key.font : eachPartText.fontOfText, NSAttributedString.Key.foregroundColor: eachPartText.color]
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
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    //Add constraints from 4Sides
    func addAsSubViewWithConstraints(_ superview: UIView, top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.frame = superview.bounds
        superview.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing).isActive = true
    }
    
    func addFourConstraints(_ superview: UIView, top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing).isActive = true
    }
    //Applwing this will keep the view in the middle of the superview
    func addFourConstraintsAlignMentAndSize(_ superview: UIView, size: CGSize, xAlignment: CGFloat = 0, yAlignment: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: yAlignment).isActive = true
        self.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: xAlignment).isActive = true
        self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
    }
    //Adding constraint for: Height, Top, Leading, Trailing
    func addAsSubviewWithFourConstraintsFromTopWithConstantHeight(_ superview: UIView, height: CGFloat, top: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.frame = superview.bounds
        superview.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    func addAsSubviewWithFourConstraintsFromBottomWithConstantHeight(_ superview: UIView, height: CGFloat, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.frame = superview.bounds
        superview.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing).isActive = true

        superview.bringSubviewToFront(self)
        
    }
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
