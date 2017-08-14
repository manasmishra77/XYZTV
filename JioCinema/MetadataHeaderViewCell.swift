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
        let id = (item?.app?.type == VideoType.Movie.rawValue) ? item?.id! : metadata?.latestEpisodeId!
        playerVC.callWebServiceForPlaybackRights(id: id!)
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        let playerItem = ["player":playerVC]
        NotificationCenter.default.post(name: watchNowNotificationName, object: nil, userInfo: playerItem)
    }
 

    @IBAction func didClickOnAddToWatchListButton(_ sender: Any) {
    }
}
