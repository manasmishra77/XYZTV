//
//  CustomPlayerView.swift
//  CustomPlayer
//
//  Created by Shweta Adagale on 26/02/19.
//  Copyright © 2019 Shweta Adagale. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation


protocol CustomPlayerViewProtocol: NSObjectProtocol {
    func removePlayerController()
}

var playerViewControllerKVOContext = 0
class CustomPlayerView: UIView {
    var moreLikeView: MoreLikeView?
    fileprivate var playerViewModel: PlayerViewModel?
    var playbackRightModel : PlaybackRightsModel?
    fileprivate var enterParentalPinView: EnterParentalPinView?
    fileprivate var enterPinViewModel: EnterPinViewModel?
    fileprivate var playerItem: Item?
    @objc var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerTimeObserverToken: Any?
    weak var delegate: CustomPlayerViewProtocol?
    var currentDuration: Float = 0.0
    var videoStartingTimeDuration = 0
    var videoStartingTime = Date()
    
    var playerSubtitles: String?
    var playerAudios: String?
    
    var controlsView : PlayersControlView?
    fileprivate var didSeek :Bool = false

    @IBOutlet weak var playerHolderView: UIView!
    @IBOutlet weak var controlHolderView: UIView!
    @IBOutlet weak var moreLikeHolderView: UIView!
    @IBOutlet weak var buttonTopBorder: UIView!

    @IBOutlet weak var bottomSpaceOfMoreLikeInContainer: NSLayoutConstraint!
    @IBOutlet weak var heightOfMoreLikeHolderView: NSLayoutConstraint!
    @IBOutlet weak var heightOfPopUpView: NSLayoutConstraint!
    @IBOutlet weak var heightOfRememberMySettings: NSLayoutConstraint!
    @IBOutlet weak var rememberMySettingsButton: JCRememberMe!
    
    
    @IBOutlet weak var controlDetailView: UIView!
    @IBOutlet weak var controlDetailHolderView: UIView!
    weak var bitrateTableView: PlayerSettingMenu?
    weak var multiAudioTableView: PlayerSettingMenu?
    weak var subtitleTableView: PlayerSettingMenu?
    
    var recommendationArray: Any = false
    
    @IBOutlet weak var controlDetailHolderWidth: NSLayoutConstraint!
    
    
    var timer: Timer!
    var timerToHideControls : Timer!
    
    var myPreferredFocusView:UIView? = nil
    var rememberMyChoiceTapped: Bool = false
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferredView = myPreferredFocusView {
            return [preferredView]
        }
        return []
    }
    
    func configureView(item: Item, subtitles: String?, audios: String?) {
        self.playerAudios = audios
        playerViewModel = PlayerViewModel(item: item)
        playerViewModel?.playbackRightsModel
        //self.playerSubtitles = playbackRightModel
        playerViewModel?.delegate = self
        self.controlDetailView.isHidden = true
        self.playerItem = item
        addPlayersControlView()
        moreLikeView?.moreLikeCollectionView.reloadData()
        addMoreLikeView()
        startTimer()
    }
    
    func addPlayersControlView() {
        controlsView = UINib(nibName: "PlayersControlView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayersControlView
        controlsView?.configurePlayersControlView()
        controlsView?.playerButtonsView?.buttonDelegate = self
        controlsView?.delegate = self
        controlsView?.frame = controlHolderView.bounds
        guard let controlsView = controlsView else {
            return
        }
        self.controlsView?.sliderView?.title.text = playerItem?.name
        self.controlHolderView.addSubview(controlsView)
        //        self.bringSubview(toFront: controlHolderView)
    }
    
    func addMoreLikeView() {
        moreLikeView = UINib(nibName: "MoreLikeView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? MoreLikeView
        heightOfMoreLikeHolderView.constant = (playerViewModel?.appType == .Movie) ? rowHeightForPotrait : rowHeightForLandscape
        self.layoutIfNeeded()
        if let moreLikeArray = recommendationArray as? [Item]{
            moreLikeView?.moreArray = moreLikeArray
        } else if let moreLikeArray = recommendationArray as? [Episode]{
            moreLikeView?.episodesArray = moreLikeArray
        } else {
            playerViewModel?.callWebServiceForMoreLikeData()
        }
        moreLikeView?.appType = playerItem?.appType ?? .None
        moreLikeView?.configMoreLikeView()
        moreLikeView?.frame = moreLikeHolderView.bounds
        self.moreLikeHolderView.addSubview(moreLikeView!)
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        print("inside didupdatefocus")
        resetTimer()
        if context.nextFocusedView is ItemCollectionViewCell{
            self.bottomSpaceOfMoreLikeInContainer.constant = 0
            UIView.animate(withDuration: 1) {
                self.layoutIfNeeded()
                self.controlsView?.layoutIfNeeded()
            }
        } else {
            self.bottomSpaceOfMoreLikeInContainer.constant = playerViewModel?.appType == .Movie ? -(rowHeightForPotrait - 100) : -(rowHeightForLandscape - 100)
            UIView.animate(withDuration: 1) {
                self.layoutIfNeeded()
            }
        }
    }
    
    func resetAndRemovePlayer() {
        if let player = player {
            print("1 inside player reset")
            player.pause()
            self.removePlayerObserver()
            self.playerViewModel = nil
            self.playerLayer?.removeFromSuperlayer()
            self.playerLayer = nil
        }
        player = nil
    }
    
    
    func currentTimevalueChanged(newTime: Double, duration: Double) {
        controlsView?.sliderView?.endingTime.text = "\(Utility.getTimeInFormatedStringFromSeconds(seconds: Int(newTime))) / \(Utility.getTimeInFormatedStringFromSeconds(seconds: Int(duration)))"
        let scale : CGFloat = CGFloat(newTime / duration)
        controlsView?.sliderView?.updateProgressBar(scale: scale, dueToScrubing: false, duration: duration)
        controlsView?.sliderView?.progressBar.progress = Float(newTime / duration)
    }
    
    @IBAction func okButtonPressedForSavingMenuSetting(_ sender: Any) {
        self.removeControlDetailview()
        myPreferredFocusView = nil
    }
    
    
    
    func removeControlDetailview() {
        if bitrateTableView != nil {
            if let selectedItem = bitrateTableView?.currentSelectedItem {
                self.playerViewModel?.changePlayerBitrateTye(bitrateQuality: BitRatesType(rawValue: selectedItem)!)
            }
        }
        else {
            self.changePlayerSubtitleLanguageAndAudioLanguage(subtitleLang: subtitleTableView?.currentSelectedItem, audioLang: multiAudioTableView?.currentSelectedItem)
        }
        
        subtitleTableView?.removeFromSuperview()
        multiAudioTableView?.removeFromSuperview()
        bitrateTableView?.removeFromSuperview()
        
        subtitleTableView = nil
        multiAudioTableView = nil
        bitrateTableView = nil
        
        self.controlDetailView.isHidden = true
    }
    
    
    func changePlayerSubtitleLanguageAndAudioLanguage(subtitleLang: String?, audioLang: String?) {
        
        player?.pause()
        if let subtitle = subtitleLang {
            self.playerSubTitleLanguage(subtitle)
        }
        if let audio = audioLang {
            self.playerAudioLanguage(audio)
        }
        player?.play()
    }
    
    private func playerAudioLanguage(_ audioLanguage: String?) {
        guard let audioLanguage = audioLanguage else {
            return
        }
        let audioes = player?.currentItem?.tracks(type: .audio)
        // Select track with displayName
        guard (audioes?.count ?? 0) > 0 else {
            return
        }
        
        if let langIndex = audioes?.firstIndex(where: {$0.lowercased() == audioLanguage.lowercased().trimmingCharacters(in: .whitespaces)}) {
            if let language = audioes?[langIndex] {
                _ = player?.currentItem?.select(type: .audio, name: language)
            }
        }
    }
    
    
    //    private func playerAudioLanguage(_ audioLanguage: String?) {
    //
    //        guard let audioLanguage = audioLanguage else {
    //            return
    //        }
    //        let audioes = player?.currentItem?.tracks(type: .audio)
    //        // Select track with displayName
    //        guard (audioes?.count ?? 0) > 0 else {return}
    //
    //
    //        if let langIndex = audioes?.index(where: {$0.lowercased() == audioLanguage.lowercased()}), let language = audioes?[langIndex] {
    //            _ = player?.currentItem?.select(type: .audio, name: language)
    //        }
    //    }
    
    private func playerSubTitleLanguage(_ subtitleLanguage: String?) {
        guard let language = subtitleLanguage else {
            return
        }
        let subtitles = player?.currentItem?.tracks(type: .subtitle)
        // Select track with displayName
        guard (subtitles?.count ?? 0) > 0 else {return}
        
        
        if let langIndex = subtitles?.firstIndex(where: {$0.lowercased() == language.lowercased()}), let language = subtitles?[langIndex] {
            _ = player?.currentItem?.select(type: .subtitle, name: language)
        }
    }
    
    
    @IBAction func rememberMyChoicePressed(_ sender: UIButton) {
        rememberMyChoiceTapped = !rememberMyChoiceTapped
        if rememberMyChoiceTapped {
            sender.setImage(UIImage(named: "filledCheckBox"), for: .normal)
            self.layoutIfNeeded()
        } else {
            sender.setImage(UIImage(named: "emptyCheckBox"), for: .normal)
            self.layoutIfNeeded()
        }
        sender.isSelected = !sender.isSelected
    }
    
    
}
extension CustomPlayerView: ButtonPressedDelegate {
    func playTapped(toPlay: Bool) {
        if toPlay{
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    func subtitlesAndMultiaudioButtonPressed(todisplay: Bool) {
        
        var audioArray = [String]()
        var subtitleArray = [String]()
        
        if let audio = self.playerAudios {
            audioArray = audio.components(separatedBy: ",")
        }
        else {
            audioArray.append("English")
        }
        
        if let subtitles = self.playerSubtitles {
            subtitleArray = subtitles.components(separatedBy: ",")
        }
        else {
            subtitleArray.append("English")
        }
        
        controlDetailHolderWidth.constant = 1280.5
        buttonTopBorder.isHidden = true
        heightOfPopUpView.constant = 715
        heightOfRememberMySettings.constant = 0
        rememberMySettingsButton.isHidden = true
        self.controlDetailView.isHidden = false
        myPreferredFocusView = self.controlDetailHolderView
        self.controlDetailView.layoutIfNeeded()
        
        multiAudioTableView = Utility.getXib("PlayerSettingMenu", type: PlayerSettingMenu.self, owner: self)
        multiAudioTableView?.frame = CGRect.init(x: controlDetailHolderView.frame.origin.x, y: controlDetailHolderView.frame.origin.y, width: controlDetailHolderWidth.constant/2, height: controlDetailHolderView.bounds.height)
        multiAudioTableView?.configurePlayerSettingMenu(menuItems: audioArray, menuType: .multiaudio)
        controlDetailHolderView.addSubview(multiAudioTableView!)
        
        subtitleTableView = Utility.getXib("PlayerSettingMenu", type: PlayerSettingMenu.self, owner: self)
        subtitleTableView?.frame = CGRect.init(x: (controlDetailHolderWidth.constant/2) + 2, y: controlDetailHolderView.frame.origin.y, width: controlDetailHolderWidth.constant/2, height: controlDetailHolderView.bounds.height)
        subtitleTableView?.configurePlayerSettingMenu(menuItems: subtitleArray, menuType: .multilanguage)
        controlDetailHolderView.addSubview(subtitleTableView!)
    }
    
    func settingsButtonPressed(toDisplay: Bool) {
        self.controlDetailView.isHidden = false
        myPreferredFocusView = self.controlDetailHolderView
        controlDetailHolderWidth.constant = 640
        heightOfPopUpView.constant = 820
        heightOfRememberMySettings.constant = 105
        rememberMySettingsButton.isHidden = false
        buttonTopBorder.isHidden = false
        self.controlDetailView.layoutIfNeeded()
        bitrateTableView = Utility.getXib("PlayerSettingMenu", type: PlayerSettingMenu.self, owner: self)
        bitrateTableView?.frame = controlDetailHolderView.bounds
        
        var bitrateArray = [String]()
        bitrateArray.append(BitRatesType.auto.rawValue)
        bitrateArray.append(BitRatesType.low.rawValue)
        bitrateArray.append(BitRatesType.medium.rawValue)
        bitrateArray.append(BitRatesType.high.rawValue)
        
        bitrateTableView?.configurePlayerSettingMenu(menuItems: bitrateArray, menuType: .videobitratequality)
        controlDetailHolderView.addSubview(bitrateTableView!)
    }
    func nextButtonPressed(toDisplay: Bool) {
        print("next")
    }
    
    func previousButtonPressed(toDisplay: Bool) {
        print("previous")
    }
}
extension CustomPlayerView : PlayerControlsDelegate {
    
    func cancelTimerForHideControl() {
        timerToHideControls.invalidate()
    }
    
    func resetTimerForHideControl() {
        self.resetTimer()
    }
    
    func getTimeDetails(_ currentTime: String, _ duration: String) {
        getPlayerDuration()
    }

    func setPlayerSeekTo(seekValue: CGFloat) {
        DispatchQueue.main.async {
            let seekToValue = Double(seekValue) * self.getPlayerDuration()
            self.player?.seek(to: CMTimeMakeWithSeconds(Float64(seekToValue), preferredTimescale: 1))
            self.currentDuration = Float(seekToValue)
        }
    }
    
}

extension CustomPlayerView: EnterPinViewModelDelegate {
    func pinVerification(_ isSucceed: Bool) {
        if isSucceed {
            enterPinViewModel = nil
            enterParentalPinView?.removeFromSuperview()
            enterParentalPinView = nil
            playerViewModel?.instantiatePlayerAfterParentalCheck()
        }
    }
}

extension CustomPlayerView: PlayerViewModelDelegate {
    
    
    func getCurrentTimeInFormat(time: Double) -> String {
        var seconds = 0
        var min = 0
        var hours = 0
        seconds = Int(time) % 60
        hours = Int(time) / 3600
        min = (Int(time) - hours * 3600) / 60
        var formatedTimeString = "\(hours):\(min):\(seconds)"
        if hours == 0 {
            formatedTimeString = "\(min):\(seconds)"
        }
        return formatedTimeString
    }
    
    func getDuration(duration: Double){
        //        controlsView?.sliderView?.endingTime.text = getCurrentTimeInFormat(time: duration)
    }
    
    func reloadMoreLikeCollectionView(i: Int) {
        self.moreLikeView?.moreArray = playerViewModel?.moreArray
        self.moreLikeView?.episodesArray = playerViewModel?.episodeArray
        self.moreLikeView?.appType = playerViewModel?.appType ?? .None
        self.moreLikeView?.moreLikeCollectionView.reloadData()
    }
    
    func checkParentalControlFor(playbackRightModel: PlaybackRightsModel) {
        self.playbackRightModel = playbackRightModel
        let ageGroup:AgeGroup = self.playbackRightModel?.maturityAgeGrp ?? .allAge
        if ParentalPinManager.shared.checkParentalPin(ageGroup) {
            enterParentalPinView = Utility.getXib(EnterParentalPinViewIdentifier, type: EnterParentalPinView.self, owner: self)
            enterPinViewModel = EnterPinViewModel(contentName: playbackRightModel.contentName ?? "", delegate: self)
            enterParentalPinView?.delegate = enterPinViewModel
            enterParentalPinView?.contentTitle.text = self.enterPinViewModel?.contentName
            enterParentalPinView?.frame = self.frame
            self.addSubview(enterParentalPinView!)
        }
        else {
            playerViewModel?.instantiatePlayerAfterParentalCheck()
        }
    }
    
    func addAvPlayerToController() {
        
        DispatchQueue.main.async {
            
            
            if let playerItem = self.player?.currentItem {
                self.player?.replaceCurrentItem(with: self.playerViewModel?.playerItem)
            }
            else {
                self.player = AVPlayer(playerItem: self.playerViewModel?.playerItem)
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer?.frame = self.bounds
                self.playerLayer?.videoGravity = .resize
                self.playerHolderView.layer.addSublayer(self.playerLayer!)
                self.didSeek = false
                self.addPlayerNotificationObserver()
            }
            self.player?.play()
        }
    }
    
    func addPlayerNotificationObserver () {
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackBufferEmpty), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackLikelyToKeepUp), options: [.new, .initial], context: &playerViewControllerKVOContext)
    }
    
    
    //MARK:- Remove Player Observer
    func removePlayerObserver() {
        guard let viewModel = playerViewModel else {
            return
        }
        //sendMediaEndAnalyticsEvent()
        //        if (appType == .Movie || appType == .Episode), isItemToBeAddedInResumeWatchList {
        viewModel.updateResumeWatchList()
        //        } //vinit_commented
        if let timeObserverToken = playerTimeObserverToken {
            self.player?.removeTimeObserver(timeObserverToken)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.duration), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.rate), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackBufferEmpty), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackLikelyToKeepUp), context: &playerViewControllerKVOContext)
        playerTimeObserverToken = nil
        //        self.player = nil
    }
    
    
    //MARK:- AVPlayer Finish Playing Item
    @objc func playerDidFinishPlaying(note: NSNotification) {
        //        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey), isPlayList {
        //            //handle play list
        //        } else {
        //            //dismiss Player
        //        }
        //        //vinit_commented
    }
    
    func getPlayerDuration() -> Double {
        guard let currentItem = self.player?.currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    //Seek player
    func seekPlayer() {
        if Double(currentDuration) >= ((self.player?.currentItem?.currentTime().seconds) ?? 0.0), didSeek{
            self.player?.seek(to: CMTimeMakeWithSeconds(Float64(currentDuration), preferredTimescale: 1))
        } else {
            didSeek = false
        }
    }
    
    func changePlayingUrlAsPerBitcode() {
        
//        AVPlayerItem *playeriem= [AVPlayerItem playerItemWithURL:urlOfSelectedQualityVideo];
//        [playeriem seekToTime:player.currentTime];
//        [player replaceCurrentItemWithPlayerItem:playeriem];
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard self.player != nil else {
            return
        }
        
        if keyPath == #keyPath(player.currentItem.duration) {
            // Update timeSlider and enable/disable controls when duration > 0.0
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = CMTime.zero
            }
            Log.DLog(message: newDuration as AnyObject)
        }
        else if keyPath == #keyPath(player.rate) {
            let newRate = (change?[NSKeyValueChangeKey.newKey] as? NSNumber)?.doubleValue ?? 0
            
            if newRate == 0
            {
                //vinit_commented swipeDownRecommendationView()
            }
        }
        else if keyPath == #keyPath(player.currentItem.isPlaybackBufferEmpty)
        {
            playerViewModel?.startTime_BufferDuration = Date()
        }
        else if keyPath == #keyPath(player.currentItem.isPlaybackLikelyToKeepUp)
        {
            playerViewModel?.updatePlayerBufferCount()
            
        }
        else if keyPath == #keyPath(player.currentItem.status) {
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue) ?? .unknown
            }
            else {
                newStatus = .unknown
            }
            switch newStatus {
            case .readyToPlay:
                self.seekPlayer()
                videoStartingTimeDuration = Int(videoStartingTime.timeIntervalSinceNow)
                playerViewModel?.isItemToBeAddedInResumeWatchList = true
                //                self.isRecommendationCollectionViewEnabled = true
                self.addPlayerPeriodicTimeObserver()
                break
            case .failed:
                Log.DLog(message: "Failed" as AnyObject)
                playerViewModel?.handlePlayerStatusFailed()
                //                self.isRecommendationCollectionViewEnabled = false
                //If video failed once and valid fps url is there
                /*
                 let eventPropertiesForCleverTap = ["Error Code": "-1", "Error Message": String(describing: playerItem?.error?.localizedDescription), "Type": appType.name, "Title": itemTitle, "Content ID": id, "Bitrate": bitrate, "Episode": itemDescription, "Platform": "TVOS", "Failure": failureType] as [String : Any]
                 let eventDicyForIAnalytics = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: failureType, errorCode: "-1", videoType: appType.name, contentTitle: itemTitle, contentId: id, videoQuality: "Auto", bitrate: bitrate, episodeSubtitle: itemDescription, playerErrorMessage: String(describing: playerItem?.error?.localizedDescription), apiFailureCode: "", message: "", fpsFailure: "")
                 
                 sendPlaybackFailureEvent(forCleverTap: eventPropertiesForCleverTap, forInternalAnalytics: eventDicyForIAnalytics)
             */ //vinit_commented
            default:
                print("unknown")
            }
            
        }
    }
    
    
    func addPlayerPeriodicTimeObserver() {
        let interval = CMTime(seconds: 1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        
        // Add time observer
        playerTimeObserverToken =
            self.player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
                [weak self] time in
                
                if self?.player != nil {
                    let currentPlayerTime = Double(CMTimeGetSeconds(time))
                    self?.currentTimevalueChanged(newTime: currentPlayerTime, duration: self?.getPlayerDuration() ?? 0)
                    //                    self?.delegate?.getDuration(duration: self?.getPlayerDuration() ?? 0)
                    let remainingTime = (self?.getPlayerDuration())! - currentPlayerTime

                    if remainingTime <= 5
                    {
                        //vinit_commented //show next item to play code
                    }
                } else {
                    self?.playerTimeObserverToken = nil
                }
        }
    }
    
    
    
    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String) {
        //vinit_comment handle player error
    }
}




extension CustomPlayerView {
    func startTimer(){
        timerToHideControls = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.hideControlsView), userInfo: nil, repeats: true)
    }
    
    func resetTimer(){
        timerToHideControls.invalidate()
        self.controlsView?.isHidden = false
        self.moreLikeView?.isHidden = false
        self.startTimer()
    }
    
    @objc func hideControlsView() {
        UIView.animate(withDuration: 0.1) {
            self.controlsView?.sliderView?.sliderLeadingForSeeking.constant = self.controlsView?.sliderView?.sliderLeading.constant ?? 0
            self.controlsView?.isHidden = true
            self.moreLikeView?.isHidden = true
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            switch press.type{
            case .downArrow, .leftArrow, .upArrow, .rightArrow:
                resetTimer()
            case .menu:
                print("menu")
            case .playPause:
                print("playPause")
                if player?.rate == 0 {
                    player?.play()
                } else {
                    player?.pause()
                }
            case .select:
                print("select")
            @unknown default:
                print("unknown")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            switch touch.type{
            case .direct:
                print("Direct")
            case .indirect:
                print("indirect")
                resetTimer()
            case .pencil:
                print("pencil")
            @unknown default:
                print("unknown")
            }
        }
    }
    
}
