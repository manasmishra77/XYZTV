//
//  MetadataHeaderViewCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 09/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class MetadataHeaderViewCell: UIView {

    
    enum VideoType:Int
    {
        case Movie = 0
        case Music = 2
        case TVShow = 1
        case Clip = 6
    }
    
    var metadata:MetadataModel?
    var item:Item?
    @IBOutlet weak var addToWatchListButton: JCMetadataButton!
    @IBOutlet weak var playButton: JCMetadataButton!
    @IBOutlet weak var tvShowSubtitleLabel: UILabel!
    @IBOutlet weak var imdbImageLogo: UIImageView!
    @IBOutlet weak var starringLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel! 
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchlistLabel: UILabel!
    
    @IBOutlet weak var monthsCollectionView: UICollectionView!
    @IBOutlet weak var seasonCollectionView: UICollectionView!
    @IBOutlet weak var seasonsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func prepareView() ->UIView
    {
        self.titleLabel.text = metadata?.name
        self.subtitleLabel.text = metadata?.newSubtitle
        self.directorLabel.text = metadata?.directors?.joined(separator: ",")
        self.starringLabel.text = metadata?.artist?.joined(separator: ",")
        
//        if metadata != nil
//        {
//            watchlistLabel.text = (metadata?.inQueue)! ? "Remove from watchlist" : "Add to watchlist"
//        }
        
        if item?.app?.type == VideoType.Movie.rawValue, metadata != nil
        {
            self.ratingLabel.text = metadata?.rating?.appending("/10 |")
            return self
        }
        else if item?.app?.type == VideoType.TVShow.rawValue, metadata != nil
        {
            self.titleLabel.text = metadata?.name
            self.imdbImageLogo.isHidden = true
            self.ratingLabel.isHidden = true
            self.subtitleLabel.isHidden = true
            self.tvShowSubtitleLabel.isHidden = false
            self.tvShowSubtitleLabel.text = metadata?.newSubtitle
            
            if (metadata?.isSeason) != nil
            {
                if (metadata?.isSeason)!
                {
                    seasonsLabel.isHidden = false
                    seasonCollectionView.isHidden = false
                    monthsCollectionView.isHidden = true
                }
                else
                {
                    seasonsLabel.isHidden = false
                    seasonsLabel.text = "Previous Episodes"
                    seasonCollectionView.isHidden = false
                    monthsCollectionView.isHidden = false
                }
            }
            
            return self
        }
        else
        {
            return UIView.init()
        }
    }
    
    func resetView() -> UIView
    {
        titleLabel.text = ""
        ratingLabel.text = ""
        subtitleLabel.text = ""
        directorLabel.text = ""
        starringLabel.text = ""
        return self
    }
    
    @IBAction func didClickOnWatchNowButton(_ sender: Any)
    {
        let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        var id:String?
        
        if item?.app?.type == VideoType.Movie.rawValue
        {
            if let itemId = item?.id
            {
                id = itemId
            }
        }
        else
        {
            if let latestId = metadata?.latestEpisodeId
            {
                id = latestId
            }
        }
        if id != nil
        {
        playerVC.callWebServiceForPlaybackRights(id: id!)
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        let playerItem = ["player":playerVC]
        NotificationCenter.default.post(name: watchNowNotificationName, object: nil, userInfo: playerItem)
        }
    }
 

    @IBAction func didClickOnAddToWatchListButton(_ sender: Any)
    {
        var params = [String:Any]()
        var url = ""
        weak var weakSelf = self
        if item?.app?.type == VideoType.TVShow.rawValue,metadata?.contentId != nil
        {
             params = ["uniqueId":JCAppUser.shared.unique,"listId":"12" ,"json":["id":(metadata?.contentId!)!]]
        }
        else if item?.app?.type == VideoType.Movie.rawValue,metadata?.contentId != nil
        {
            params = ["uniqueId":JCAppUser.shared.unique,"listId":"13" ,"json":["id":(metadata?.contentId!)!]]
        }
        
        if JCLoginManager.sharedInstance.isUserLoggedIn()
        {
        url = (metadata?.inQueue)! ? removeFromWatchListUrl : addToWatchListUrl
        
            let updateWatchlistRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
            RJILApiManager.defaultManager.post(request: updateWatchlistRequest) { (data, response, error) in
                if let responseError = error
                {
                    //TODO: handle error
                    print(responseError)
                    return
                }
                if let responseData = data,let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
                {
                    let code = parsedResponse["code"] as? Int
                    if(code == 200)
                    {

                        DispatchQueue.main.async {
                            weakSelf?.watchlistLabel.text = (weakSelf?.metadata?.inQueue)! ? "Add to watchlist" : "Remove from watchlist"
                        }
                    }
                    return
                }
            }
        }
        else
        {
            NotificationCenter.default.post(name: showLoginFromMetadataNotificationName, object: nil, userInfo: nil)
        }
    }
}
