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
    func removePlayerAfterAesFailure()
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
    var isDisney: Bool = false
    var isPlayList: Bool = false
    var latestEpisodeId: String?
    var indicator: SpiralSpinner?
    fileprivate var currentPlayingIndex: Int!
    
    var controlsView : PlayersControlView?
    var lastSelectedItem: String?
    var resumeWatchView: ResumeWatchView?
    fileprivate var didSeek :Bool = false
    
    @IBOutlet weak var alertMsg: UILabel!
    @IBOutlet weak var playerHolderView: UIView!
    @IBOutlet weak var controlHolderView: UIView!
    @IBOutlet weak var moreLikeHolderView: UIView!
    @IBOutlet weak var buttonTopBorder: UIView!
    
    @IBOutlet weak var bottomSpaceOfMoreLikeInContainer: NSLayoutConstraint!
    @IBOutlet weak var heightOfMoreLikeHolderView: NSLayoutConstraint!
    @IBOutlet weak var heightOfPopUpView: NSLayoutConstraint!
    @IBOutlet weak var heightOfRememberMySettings: NSLayoutConstraint!
    @IBOutlet weak var rememberMySettingsButton: JCRememberMe!
    
    @IBOutlet weak var popUpHolderView: UIView!
    @IBOutlet weak var tableViewHolderInPopupView: UIView!
    weak var bitrateTableView: PlayerSettingMenu?
    weak var multiAudioTableView: PlayerSettingMenu?
    weak var subtitleTableView: PlayerSettingMenu?
    
    var lastSelectedAudioSubtitle: String?
    var lastSelectedAudioLanguage: String?
    var lastSelectedVideoQuality: String?
    
    var recommendationArray: Any = false
    
    @IBOutlet weak var popUpTableViewHolderWidth: NSLayoutConstraint!
    
    
    var timer: Timer!
    var timerToHideControls : Timer!
    
    var myPreferredFocusView:UIView? = nil
    var rememberMyChoiceTapped: Bool = false
    
    var audioLanguage : AudioLanguage?
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferredView = myPreferredFocusView {
            return [preferredView]
        }
        return []
    }

    func configureView(item: Item, latestEpisodeId: String? = nil, audioLanguage: AudioLanguage? = nil) {
        self.audioLanguage = audioLanguage
        self.initialiseViewModelForItem(item: item, latestEpisodeId: latestEpisodeId)
        addSubviewOnPlayer()
    }
    
    func initialiseViewModelForItem(item: Item, latestEpisodeId: String? = nil) {
        playerViewModel = nil
        playerViewModel = PlayerViewModel(item: item, latestEpisodeId: latestEpisodeId)
        playerViewModel?.isDisney = isDisney
        playerViewModel?.delegate = self
        self.playerItem = item
        isPlayList = item.isPlaylist ?? false
        self.updateIndicatorState(toStart: true)
        playerViewModel?.preparePlayer()
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
        self.controlHolderView.addSubview(controlsView)
        setValuesOnControlView()
    }
    
    func setValuesOnControlView() {
     self.controlsView?.sliderView?.title.text = playerItem?.name
        if playerItem?.appType == .TVShow {
            self.controlsView?.sliderView?.title.text = playerItem?.showname
        }
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
            if isPlayList == true, playerItem?.id == "" {
                playerViewModel?.callWebServiceForPlayListData(id: playerItem?.playlistId ?? "")
            } else {
                playerViewModel?.callWebServiceForMoreLikeData()

            }
        }
        moreLikeView?.appType = playerItem?.appType ?? .None
        moreLikeView?.configMoreLikeView()
        moreLikeView?.delegate = self
        self.bottomSpaceOfMoreLikeInContainer.constant = playerViewModel?.appType == .Movie ? -(rowHeightForPotrait - 100) : -(rowHeightForLandscape - 100)
        moreLikeView?.frame = moreLikeHolderView.bounds
        self.moreLikeHolderView.addSubview(moreLikeView!)
    }
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        resetTimer()
        if context.nextFocusedView is ItemCollectionViewCell{
            self.bottomSpaceOfMoreLikeInContainer.constant = 0
            UIView.animate(withDuration: 0.7) {
                self.layoutIfNeeded()
                self.controlsView?.layoutIfNeeded()
            }
        } else {
            self.bottomSpaceOfMoreLikeInContainer.constant = playerViewModel?.appType == .Movie ? -(rowHeightForPotrait - 100) : -(rowHeightForLandscape - 100)
            UIView.animate(withDuration: 0.72) {
                self.layoutIfNeeded()
            }
        }
    }
    
    func resetAndRemovePlayer() {
        self.resetPlayer()
        self.controlsView?.removeFromSuperview()
        self.controlsView = nil
        self.moreLikeView?.removeFromSuperview()
        self.moreLikeView = nil
    }
    
    
    func resetPlayer() {
        if let player = player {
            print("1 inside player reset")
            player.pause()
            self.removePlayerObserver()
            self.playerViewModel = nil
            self.playerLayer?.removeFromSuperlayer()
            self.playerLayer = nil
        }
        player = nil
        alertMsg.text = ""
        alertMsg.isHidden = true
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
        player?.play()
    }
    
    func removeControlDetailview() {
        if bitrateTableView != nil {
            if rememberMyChoiceTapped {
                UserDefaults.standard.set(bitrateTableView?.currentSelectedItem ?? lastSelectedVideoQuality, forKey: isRememberMySettingsSelectedKey)
            } else {
                UserDefaults.standard.set(nil, forKey: isRememberMySettingsSelectedKey)
            }

            if let selectedItem = bitrateTableView?.currentSelectedItem {
                
                if lastSelectedVideoQuality != bitrateTableView?.currentSelectedItem {
                    playerViewModel?.currentDuration = Float(player?.currentTime().seconds ?? 0)
                    self.playerViewModel?.changePlayerBitrateTye(bitrateQuality: BitRatesType(rawValue: selectedItem)!)
                    lastSelectedVideoQuality = bitrateTableView?.currentSelectedItem
                }
                
//                lastSelectedVideoQuality = "\(selectedItem)"
            }
        }
        else {
            self.changePlayerSubtitleLanguageAndAudioLanguage(subtitleLang: subtitleTableView?.currentSelectedItem, audioLang: multiAudioTableView?.currentSelectedItem)
            lastSelectedAudioLanguage = multiAudioTableView?.currentSelectedItem
            lastSelectedAudioSubtitle = subtitleTableView?.currentSelectedItem
        }
        
        subtitleTableView?.removeFromSuperview()
        multiAudioTableView?.removeFromSuperview()
        bitrateTableView?.removeFromSuperview()
        
        subtitleTableView = nil
        multiAudioTableView = nil
        bitrateTableView = nil
        
        self.popUpHolderView.isHidden = true
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
        
        //        if let langIndex = audioes?.index(where: {$0.lowercased() == audioLanguage.lowercased()}), let language = audioes?[langIndex] {
        //            _ = player?.currentItem?.select(type: .audio, name: language)
        //        }
        //    }
        if let langIndex = audioes?.firstIndex(where: {$0.lowercased() == audioLanguage.lowercased().trimmingCharacters(in: .whitespaces)}) {
            if let language = audioes?[langIndex] {
                _ = player?.currentItem?.select(type: .audio, name: language)
            }
        }
    }
    
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
    }
    deinit {
        print("CustomPlayerView deinit called")
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
        player?.pause()
        var audioArray = [String]()
        var subtitleArray = [String]()
        
        if let audio = playerViewModel?.playbackRightsModel?.displayLanguages{
            audioArray = audio
            if audioArray.count == 0{
                if let defaultLang = playerViewModel?.playbackRightsModel?.defaultLanguage{
                    audioArray.append(defaultLang)
                }
            }
        }
        if let subtitles = playerViewModel?.playbackRightsModel?.displaySubtitles {
            subtitleArray = subtitles
        }
        
        popUpTableViewHolderWidth.constant = 1280.5
        buttonTopBorder.isHidden = true
        heightOfPopUpView.constant = 715
        heightOfRememberMySettings.constant = 0
        rememberMySettingsButton.isHidden = true
        self.popUpHolderView.isHidden = false
        myPreferredFocusView = self.tableViewHolderInPopupView
        
        self.popUpHolderView.layoutIfNeeded()
        
        
        multiAudioTableView = Utility.getXib("PlayerSettingMenu", type: PlayerSettingMenu.self, owner: self)
        multiAudioTableView?.frame = CGRect.init(x: tableViewHolderInPopupView.frame.origin.x, y: tableViewHolderInPopupView.frame.origin.y, width: popUpTableViewHolderWidth.constant/2, height: tableViewHolderInPopupView.bounds.height)
        if let lastIndex = audioArray.firstIndex(of: lastSelectedAudioLanguage ?? ""){
            multiAudioTableView?.previousSelectedIndexpath = IndexPath(row: lastIndex, section: 0)
        }
        multiAudioTableView?.configurePlayerSettingMenu(menuItems: audioArray, menuType: .multiaudioLanguage)
        tableViewHolderInPopupView.addSubview(multiAudioTableView!)
        
        
        subtitleTableView = Utility.getXib("PlayerSettingMenu", type: PlayerSettingMenu.self, owner: self)
        subtitleTableView?.frame = CGRect.init(x: (popUpTableViewHolderWidth.constant/2) + 2, y: tableViewHolderInPopupView.frame.origin.y, width: popUpTableViewHolderWidth.constant/2, height: tableViewHolderInPopupView.bounds.height)
        if let lastIndex = subtitleArray.firstIndex(of: lastSelectedAudioSubtitle ?? ""){
            subtitleTableView?.previousSelectedIndexpath = IndexPath(row: lastIndex, section: 0)
        }
        subtitleTableView?.configurePlayerSettingMenu(menuItems: subtitleArray, menuType: .multiSubtitle)
        
        tableViewHolderInPopupView.addSubview(subtitleTableView!)
    }
    
    func settingsButtonPressed(toDisplay: Bool) {
        player?.pause()
        self.popUpHolderView.isHidden = false
        myPreferredFocusView = self.tableViewHolderInPopupView
        popUpTableViewHolderWidth.constant = 640
        heightOfPopUpView.constant = 820
        heightOfRememberMySettings.constant = 105
        rememberMySettingsButton.isHidden = false
        buttonTopBorder.isHidden = false
        self.popUpHolderView.layoutIfNeeded()
        bitrateTableView = Utility.getXib("PlayerSettingMenu", type: PlayerSettingMenu.self, owner: self)
        bitrateTableView?.frame = tableViewHolderInPopupView.bounds
        
        var bitrateArray = [String]()
        bitrateArray.append(BitRatesType.auto.rawValue)
        bitrateArray.append(BitRatesType.low.rawValue)
        bitrateArray.append(BitRatesType.medium.rawValue)
        bitrateArray.append(BitRatesType.high.rawValue)
        if let valueInUserDefaults = UserDefaults.standard.value(forKey: isRememberMySettingsSelectedKey){
            bitrateTableView?.previousSelectedIndexpath = IndexPath(row: bitrateArray.firstIndex(of: valueInUserDefaults as! String) ?? 0, section: 0)
            lastSelectedVideoQuality = bitrateArray[bitrateTableView?.previousSelectedIndexpath?.row ?? 0]
            rememberMySettingsButton.setImage(UIImage(named: "filledCheckBox"), for: .normal)
            rememberMyChoiceTapped = true
        } else {
                rememberMySettingsButton.setImage(UIImage(named: "emptyCheckBox"), for: .normal)
                rememberMyChoiceTapped = false
            bitrateTableView?.previousSelectedIndexpath = IndexPath(row: bitrateArray.firstIndex(of: lastSelectedVideoQuality ?? "Auto") ?? 0, section: 0)
                
        }

        
        bitrateTableView?.configurePlayerSettingMenu(menuItems: bitrateArray, menuType: .videobitratequality)
        tableViewHolderInPopupView.addSubview(bitrateTableView!)
    }
    func nextButtonPressed(toDisplay: Bool) {
        playnextOrPreviousItem(playNext: true)
    }
    
    func previousButtonPressed(toDisplay: Bool) {
        playnextOrPreviousItem(playNext: false)
    }
    func playnextOrPreviousItem(playNext: Bool){
        player?.pause()
        guard let currentTime = player?.currentItem?.currentTime().seconds else {
            return
        }
        guard let duration = player?.currentItem?.duration.seconds else {
            return
        }
        if playNext {
            if currentTime + 10 < duration {
                player?.seek(to: CMTimeMakeWithSeconds(Float64(currentTime + 10), preferredTimescale: 1))
            }
        } else {
            if currentTime - 10 > 0{
                player?.seek(to: CMTimeMakeWithSeconds(Float64(currentTime - 10), preferredTimescale: 1))
            }
        }
        player?.play()
        
    }
}
extension CustomPlayerView : PlayerControlsDelegate {
    func skipIntroButtonPressed() {
        guard let seekTime = playerViewModel?.convertStringToSeconds(strTime: playerViewModel?.playbackRightsModel?.introCreditEnd ?? playerViewModel?.playbackRightsModel?.recapCreditEnd ?? "") else {
            return
        }
        DispatchQueue.main.async {
            self.player?.seek(to: CMTime(seconds: seekTime, preferredTimescale: 1))
        }
    }
    
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
            self.updateIndicatorState(toStart: true)
            playerViewModel?.instantiatePlayerAfterParentalCheck()
        }
    }
}

extension CustomPlayerView: PlayerViewModelDelegate {
    func checkTimeToShowSkipButton(isValidTime: Bool, starttime: Double, endTime: Double) {
        if isValidTime && !(controlsView?.isHidden ?? false) {
            controlsView?.skipIntroButton.isHidden = false
        } else {
            if isValidTime && (controlsView?.isHidden ?? false) {
                if Int(starttime) == Int(player?.currentItem?.currentTime().seconds ?? 0.0){
                    controlsView?.skipIntroButton.isHidden = false
                }else if Int(starttime + 5) == Int(player?.currentItem?.currentTime().seconds ?? 0.0){
                    controlsView?.skipIntroButton.isHidden = true
                }
                
            } else {
                controlsView?.skipIntroButton.isHidden = true
            }
        }
    }

    func dismissPlayer() {
        self.resetPlayer()
        self.delegate?.removePlayerController()
    }
    
    func updateIndicatorState(toStart: Bool) {
        if toStart {
            DispatchQueue.main.async {
                if self.indicator != nil {
                    return
                }
                self.indicator = IndicatorManager.shared.addAndStartAnimatingANewIndicator(spinnerColor: ViewColor.selectionBarOnLeftNavigationColor , superView: self, superViewSize: self.frame.size, spinnerSize: CGSize(width: 100, height: 100), spinnerWidth: 10, superViewUserInteractionEnabled: false, shouldUseCoverLayer: true, coverLayerOpacity: 1, coverLayerColor: .clear)
                //self.addSubview(self.indicator!)
            }
        } else {
            DispatchQueue.main.async {
                IndicatorManager.shared.stopSpinningIndependent(spinnerView: self.indicator)
                if self.indicator != nil{
                    self.indicator = nil
                }
            }
            
        }
        
    }
    
    func addResumeWatchView() {
        self.updateIndicatorState(toStart: false)
        self.popUpHolderView.isHidden = true
        resumeWatchView = UINib(nibName: "ResumeWatchView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? ResumeWatchView
        resumeWatchView?.frame = self.bounds
        resumeWatchView?.delegate = self
        self.addSubview(resumeWatchView!)
    }
    
    func setValuesForSubviewsOnPlayer() {
        startTimer()
        setValuesOnControlView()
    }
    
    func addSubviewOnPlayer() {
        addPlayersControlView()
        addMoreLikeView()
    }
    
    func reloadMoreLikeCollectionView(currentMorelikeIndex: Int) {
        currentPlayingIndex = currentMorelikeIndex
        self.moreLikeView?.moreArray = playerViewModel?.moreArray
        self.moreLikeView?.episodesArray = playerViewModel?.episodeArray
        self.moreLikeView?.appType = playerViewModel?.appType ?? .None
        self.moreLikeView?.moreLikeCollectionView.reloadData()
    }
    
    func checkParentalControlFor(playbackRightModel: PlaybackRightsModel) {
        self.playbackRightModel = playbackRightModel
        let ageGroup:AgeGroup = self.playbackRightModel?.maturityAgeGrp ?? .allAge
        if ParentalPinManager.shared.checkParentalPin(ageGroup) {
            DispatchQueue.main.async {
                self.updateIndicatorState(toStart: false)
                self.enterParentalPinView = Utility.getXib(EnterParentalPinViewIdentifier, type: EnterParentalPinView.self, owner: self)
                self.enterParentalPinView?.frame = self.bounds
                self.enterPinViewModel = EnterPinViewModel(contentName: playbackRightModel.contentName ?? "", delegate: self)
                self.enterParentalPinView?.delegate = self.enterPinViewModel
                self.enterParentalPinView?.contentTitle.text = self.enterPinViewModel?.contentName
                
                self.addSubview(self.enterParentalPinView!)
                self.bringSubviewToFront(self.enterParentalPinView!)
            }
            
        }
        else {
            playerViewModel?.instantiatePlayerAfterParentalCheck()
        }
    }

    func addAvPlayerToController() {
        DispatchQueue.main.async {
            self.updateIndicatorState(toStart: false)
            if self.player?.currentItem != nil {
                self.player?.replaceCurrentItem(with: self.playerViewModel?.playerItem)
            }
            else {
                self.resetPlayer()
                self.player = AVPlayer(playerItem: self.playerViewModel?.playerItem)
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer?.frame = self.bounds
                self.playerLayer?.videoGravity = .resize
                self.playerHolderView.layer.addSublayer(self.playerLayer!)
                self.didSeek = false
                if self.playerViewModel?.currentDuration ?? 0 > 0 {
                }
            }
            
            
            self.setCurrentPlayingOnMoreLike()
            
            if self.audioLanguage != nil, self.audioLanguage?.name.lowercased() == "none" {
                
            }
            if let audioLanguageToBePlayed = MultiAudioManager.getFinalAudioLanguage(itemIdToBeChecked: self.playerItem?.id ?? "", appType: self.playerItem?.appType ?? .TVShow, defaultLanguage: self.audioLanguage) {
                self.playerAudioLanguage(audioLanguageToBePlayed.name)
            }
            //            self.setPlayerSeekTo(seekValue: CGFloat(self.playerViewModel?.currentDuration ?? 0))
            self.addPlayerNotificationObserver()

            self.player?.seek(to: CMTime(seconds: Double(self.playerViewModel?.currentDuration ?? 0), preferredTimescale: 1))
            
            
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
        viewModel.updateResumeWatchList(audioLanguage: lastSelectedAudioLanguage ?? (playerViewModel?.playbackRightsModel?.defaultLanguage ?? ""))
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
    }
    
    
    //MARK:- AVPlayer Finish Playing Item
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.updateIndicatorState(toStart: false)
        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey) {
            
            if let currentPlayingIndex = currentPlayingIndex
            {
            
            if playerItem?.appType == .Music || playerItem?.appType == .Clip || playerItem?.appType == .Trailer || playerItem?.appType == .Movie {
                if let moreArray = moreLikeView?.moreArray, isPlayList {
                    if (currentPlayingIndex + 1) < moreArray.count {
                        let nextItem = moreArray[currentPlayingIndex + 1]
                        resetPlayer()
                        self.currentPlayingIndex = currentPlayingIndex + 1
                        self.initialiseViewModelForItem(item: nextItem, latestEpisodeId: nil)
                        return
                    }
                }
            }
            else if playerItem?.appType == .Episode {
                if let moreArray = moreLikeView?.episodesArray {
                    if let nextItemTupple = playerViewModel?.gettingNextEpisodeAndSequence(episodes: moreArray, index: currentPlayingIndex) {
                        self.resetPlayer()
                        self.currentPlayingIndex += nextItemTupple.1 ? 1: -1
                        self.initialiseViewModelForItem(item: nextItemTupple.0.getItem, latestEpisodeId: nil)
                        return
                    }
                }
            }
            
        }
    }
        delegate?.removePlayerController()
        
    }


    
    func setCurrentPlayingOnMoreLike() {
        if let currentPlayingIndex = currentPlayingIndex {
            self.moreLikeView?.scrollToIndex(index: currentPlayingIndex)
        }
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
        else if keyPath == #keyPath(player.currentItem.isPlaybackBufferFull)
        {
            print("KeyPathBufferFull")
            self.updateIndicatorState(toStart: false)
            print("indicator stoped on isPlaybackBufferFull")

        }
        else if keyPath == #keyPath(player.currentItem.isPlaybackBufferEmpty)
        {
            self.updateIndicatorState(toStart: true)
            print("indicator started on isPlaybackBufferempty")

            playerViewModel?.startTime_BufferDuration = Date()
        }
        else if keyPath == #keyPath(player.currentItem.isPlaybackLikelyToKeepUp)
        {
            self.updateIndicatorState(toStart: false)
            print("indicator stoped on isPlaybackLikelyToKeepUp")
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
                self.updateIndicatorState(toStart: false)
                print("indicator start on ready to play")
                //                indicator?.removeFromSuperview()
                self.seekPlayer()
                videoStartingTimeDuration = Int(videoStartingTime.timeIntervalSinceNow)
                playerViewModel?.isItemToBeAddedInResumeWatchList = true
                //                self.isRecommendationCollectionViewEnabled = true
                self.addPlayerPeriodicTimeObserver()
                break
            case .failed:
                if let indicator = indicator {
                    updateIndicatorState(toStart: false)
                    print("indicator stop on failed")

                }
                
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
                    guard let duration = self?.getPlayerDuration(), duration.isNaN == false else{
                        return
                    }
                    self?.currentTimevalueChanged(newTime: currentPlayerTime, duration: duration)
                    self?.playerViewModel?.observeValueToHideUnhideSkipIntro(newTime: currentPlayerTime )
                    let remainingTime = duration - currentPlayerTime
                    if remainingTime <= 5
                    {
                        self?.checkForNextVideoInAutoPlay(remainingTime: remainingTime)
                    }
                } else {
                    self?.playerTimeObserverToken = nil
                }
        }
    }
    
    
    func checkForNextVideoInAutoPlay(remainingTime: Double) {
        let autoPlayOn = UserDefaults.standard.bool(forKey: isAutoPlayOnKey)
        if autoPlayOn, controlsView?.recommendViewHolder.isHidden ?? false {
             guard let currentPlayingIndex = currentPlayingIndex else { return }
            self.controlHolderView.isHidden = false
            if self.playerItem?.appType == .Episode {

                if let moreArray = moreLikeView?.episodesArray, moreArray.count > 0 {
                self.resetTimer()
                    
                    if let nextItemTupple = playerViewModel?.gettingNextEpisodeAndSequence(episodes: moreArray, index: currentPlayingIndex) {
                        self.controlsView?.showNextVideoView(videoName: nextItemTupple.0.name ?? "", remainingTime: Int(remainingTime), banner: nextItemTupple.0.banner ?? "")
                    }
                }
            }
            else {
                if let moreArray = moreLikeView?.moreArray, moreArray.count > 0, self.isPlayList {
                self.resetTimer()
                    if (currentPlayingIndex + 1) < moreArray.count {
                        let nextItem = moreArray[(currentPlayingIndex + 1)]
                        self.controlsView?.showNextVideoView(videoName: nextItem.name ?? "", remainingTime: Int(remainingTime), banner: nextItem.banner ?? "")
                    }
                }
            }
        }
    }

    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String) {



        DispatchQueue.main.async {
            self.updateIndicatorState(toStart: false)
            self.alertMsg.isHidden = false
            self.alertMsg.text = "Some problem occured!!, please login again!!"
            
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] (timer) in
                guard let self = self else {
                    return
                }
                self.delegate?.removePlayerController()
            })
        }
        
        //vinit_comment handle player error
    }
    
    
    
    func dismissPlayerOnAesFailure() {
        delegate?.removePlayerAfterAesFailure()
    }
}




extension CustomPlayerView {
    func startTimer(){
        timerToHideControls = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.hideControlsView), userInfo: nil, repeats: true)
    }
    
    func resetTimer(){
        if timerToHideControls == nil{
            return
        }
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
        self.bottomSpaceOfMoreLikeInContainer.constant = playerViewModel?.appType == .Movie ? -(rowHeightForPotrait - 100) : -(rowHeightForLandscape - 100)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            switch press.type{
            case .downArrow, .leftArrow, .upArrow, .rightArrow:
                resetTimer()
            case .menu:
                if self.controlsView?.isHidden == false{
                    self.controlsView?.isHidden = true
                    self.moreLikeView?.isHidden = true
                }
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

extension CustomPlayerView: playerMoreLikeDelegate{
    func moreLikeTapped(newItem: Item, index: Int) {
        resetPlayer()
         self.currentPlayingIndex = index
        self.initialiseViewModelForItem(item: newItem, latestEpisodeId: nil)
    }
}

extension CustomPlayerView: ResumeWatchDelegate {
    func resumeWatchingPressed() {
        resumeWatchView?.removeFromSuperview()
        resumeWatchView = nil
        playerViewModel?.callWebServiceForPlaybackRights(id: playerItem?.id ?? "")
        setValuesForSubviewsOnPlayer()
    }
    
    func startFromBeginning() {
        playerViewModel?.currentDuration = 0
        playerViewModel?.callWebServiceForPlaybackRights(id: playerItem?.id ?? "")
        resumeWatchView?.removeFromSuperview()
        resumeWatchView = nil
        self.setValuesForSubviewsOnPlayer()
        
    }
    
    func removeFromResumeWatchingPressed() {
        playerViewModel?.callWebServiceForRemovingResumedWatchlist()
        resumeWatchView?.removeFromSuperview()
        resumeWatchView = nil
        delegate?.removePlayerController()
    }
    
    
}
