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
    func presenMetadataOnMoreLikeTapped(item: Item)
}

var playerViewControllerKVOContext = 0
class CustomPlayerView: UIView {
    var moreLikeView: MoreLikeView?
    var playerViewModel: PlayerViewModel?
    var playbackRightModel : PlaybackRightsModel?
    fileprivate var enterParentalPinView: EnterParentalPinView?
    fileprivate var enterPinViewModel: EnterPinViewModel?
    fileprivate var playerItem: Item?
    @objc var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerTimeObserverToken: Any?
    weak var delegate: CustomPlayerViewProtocol?
    
    var isDisney: Bool = false
    var isPlayList: Bool = false
    var recommendationArray: Any = false
    var audioLanguage : AudioLanguage?
    var latestEpisodeId: String?
    var indicator: SpiralSpinner?
    fileprivate var currentPlayingIndex: Int!
    var stateOfPlayerBeforeButtonClickWasPaused = false
    var stateOfPlayerBeforeGoingInBackgroundWasPaused = true
    var controlsView : PlayersControlView?
    var lastSelectedItem: String?
    var resumeWatchView: ResumeWatchView?
    fileprivate var didSeek :Bool = false
    
    var fromScreen: String = ""
    var fromCategory: String = ""
    var fromCategoryIndex: Int = 0
    var fromLanguage: String = ""
    
    var firstTime: Bool?
    
    @IBOutlet weak var alertMsg: UILabel!
    @IBOutlet weak var playerHolderView: UIView!
    @IBOutlet weak var controlHolderView: UIView!
    @IBOutlet weak var moreLikeHolderView: UIView!
    @IBOutlet weak var buttonTopBorder: UIView!
    @IBOutlet weak var gradientView: UIView!
    
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
    var timeSpent = 0
    
    var controlVisibleState: VisbleControls = .allHide
    var shouldShowSkipIntroButton: Bool = false
    
    @IBOutlet weak var popUpTableViewHolderWidth: NSLayoutConstraint!
    
    
    var timerToHideControls : Timer!
    
    var myPreferredFocusView: UIView? = nil
    
    //When focus is changed manualy, update focus is getting called, so we need to stop on that call, so this variable is used
    var isFocusViewChangedOnResetTimer: Bool = false
    
    var rememberMyChoiceTapped: Bool = false
    
    
    var clearanceFromBottomForMoreLikeView: CGFloat {
        return (self.playerViewModel?.appType == .Movie) ? (-itemHeightForPortrait + 70) : (-itemHeightForLandscape + 70)
    }
    var isPlayerPaused: Bool {
        return player?.rate == 0
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferredView = myPreferredFocusView {
            return [preferredView]
        }
        return []
    }
    
    func configureView(item: Item, latestEpisodeId: String? = nil, audioLanguage: AudioLanguage? = nil) {
        self.audioLanguage = audioLanguage
        self.initialiseViewModelForItem(item: item, latestEpisodeId: latestEpisodeId)
        //        addSubviewOnPlayer()
    }
    
    
    func initialiseViewModelForItem(item: Item, latestEpisodeId: String? = nil) {
        playerViewModel = nil
        playerViewModel = PlayerViewModel(item: item, latestEpisodeId: latestEpisodeId)
        playerViewModel?.isDisney = isDisney
        playerViewModel?.delegate = self
        playerViewModel?.fromCategoryIndex = fromCategoryIndex
        playerViewModel?.fromCategory = fromCategory
        playerViewModel?.fromScreen = fromScreen
        playerViewModel?.fromLanguage = fromLanguage
        self.playerItem = item
        isPlayList = item.isPlaylist ?? false
        if item.appType == .TVShow || item.appType == .Episode {
            isPlayList = true
        }
        self.updateIndicatorState(toStart: true)
        print("indicator started on initialise view model")
        playerViewModel?.preparePlayer()
    }
    
    func addPlayersControlView() {
        if controlsView == nil {
            controlsView = UINib(nibName: "PlayersControlView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayersControlView
            guard let controlsView = controlsView else {
                return
            }
            controlsView.configurePlayersControlView()
            controlsView.delegate = self
            controlsView.frame = controlHolderView.bounds
            self.controlHolderView.addSubview(controlsView)
        }
        setValuesForSubviewsOnPlayer()
        //        setValuesOnControlView()
    }
    
    func setValuesOnControlView() {
        self.controlsView?.sliderView?.title.text = playerItem?.name
        if playerItem?.name == "" || playerItem?.name == nil {
            self.controlsView?.sliderView?.title.text = playerItem?.showname
            if playerItem?.showname == nil || playerItem?.showname == "" {
                self.controlsView?.sliderView?.title.text = playbackRightModel?.contentName
            }
        }
        if let currentDuration = self.playerViewModel?.currentDuration, currentDuration > 0 {
            guard let totalDuration = self.playbackRightModel?.totalDuration else {
                return
            }
            if let totalFloatDuration = Float(totalDuration){
                self.controlsView?.sliderView?.sliderLeading.constant = CGFloat(currentDuration / totalFloatDuration) * PlayerSliderConstants.widthOfProgressBar
                self.controlsView?.sliderView?.sliderLeadingForSeeking.constant = CGFloat(currentDuration / totalFloatDuration) * PlayerSliderConstants.widthOfProgressBar
            }
        }
        self.controlsView?.sliderView?.progressBar.tintColor = ThemeManager.shared.selectionColor
    }
    func setThumbnailsValue() {
        guard let thumbnails = playerViewModel?.thumbImageArray else {
            return
        }
        self.controlsView?.sliderView?.thumbnailsArray = thumbnails
    }
    func addMoreLikeView() {
        if moreLikeView == nil {
            moreLikeView = UINib(nibName: "MoreLikeView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? MoreLikeView
            guard let moreLikeView = moreLikeView else{
                return
            }
            heightOfMoreLikeHolderView.constant = (playerViewModel?.appType == .Movie) ? itemHeightForPortrait + 20 : itemHeightForLandscape + 20
            self.layoutIfNeeded()
            self.bottomSpaceOfMoreLikeInContainer.constant =  clearanceFromBottomForMoreLikeView
            self.layoutIfNeeded()
            moreLikeView.frame = moreLikeHolderView.bounds
            self.moreLikeHolderView.addSubview(moreLikeView)
            self.layoutIfNeeded()
        }
        setValuesForMoreLikeData()
    }
    
    func setValuesForMoreLikeData(){
        moreLikeView?.appType = playerItem?.appType ?? .None
        var id = playerItem?.latestId
        if id == "" || id == nil{
            id = playerItem?.id
        }
        moreLikeView?.configMoreLikeView(id: id ?? "")
        moreLikeView?.isDisney = isDisney
        moreLikeView?.delegate = self
        
        if let moreLikeArray = recommendationArray as? [Item]{
            moreLikeView?.moreArray = moreLikeArray
            for (index, each) in moreLikeArray.enumerated() {
                if each.id == playerItem?.latestId || each.id == playerItem?.id {
                    currentPlayingIndex = index
                    moreLikeView?.currentPlayingIndex = currentPlayingIndex
                    //                    reloadMoreLikeCollectionView(currentMorelikeIndex: index)
                    break
                }
            }
        } else if let moreLikeArray = recommendationArray as? [Episode]{
            moreLikeView?.episodesArray = moreLikeArray
            for (index, each) in moreLikeArray.enumerated() {
                if each.id == playerItem?.latestId || each.id == playerItem?.id {
                    currentPlayingIndex = index
                    moreLikeView?.currentPlayingIndex = currentPlayingIndex
                    //                    reloadMoreLikeCollectionView(currentMorelikeIndex: index)
                    break
                }
            }
        } else {
            if isPlayList == true, playerItem?.id == "" {
                playerViewModel?.callWebServiceForPlayListData(id: playerItem?.playlistId ?? "")
            } else {
                playerViewModel?.callWebServiceForMoreLikeData()
                
            }
        }
        //        moreLikeView?.moreLikeCollectionView.reloadData()
    }
    
    func addGradientView() {
        if gradientView.layer.isHidden == true {
            gradientView.layer.isHidden = false
        } else {
        let colorLayer = CAGradientLayer()
        colorLayer.frame = gradientView.bounds
        colorLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        self.gradientView.layer.insertSublayer(colorLayer, at:0)
        }
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if !isFocusViewChangedOnResetTimer {
            resetTimertToHideControls()
        } else {
            isFocusViewChangedOnResetTimer = false
        }
        
        if context.nextFocusedView is ItemCollectionViewCell {
            self.bottomSpaceOfMoreLikeInContainer.constant = 0
            UIView.animate(withDuration: 0.7) {
                self.controlsView?.alpha = 0.0001
                self.layoutIfNeeded()
                self.controlsView?.layoutIfNeeded()
            }
        } else {
            self.bottomSpaceOfMoreLikeInContainer.constant = clearanceFromBottomForMoreLikeView
            UIView.animate(withDuration: 0.7) {
                self.controlsView?.alpha = 1
                self.layoutIfNeeded()
                self.controlsView?.layoutIfNeeded()
            }
        }
    }
    
    func resetAndRemovePlayer() {
        if !(playerViewModel?.isMediaEndAnalyticsEventSent ?? false){
            playerViewModel?.isMediaEndAnalyticsEventSent = true
            playerViewModel?.sendMediaEndAnalyticsEvent(timeSpent: timeSpent)
        }
        self.resetPlayer()
        self.controlsView?.removeFromSuperview()
        self.controlsView = nil
        self.moreLikeView?.removeFromSuperview()
        self.moreLikeView = nil
    }
    
    
    func resetPlayer() {
        if let player = player {
            player.pause()
            self.removePlayerObserver()
            self.playerViewModel = nil
            self.playerViewModel?.thumbImageArray = nil
            self.playerLayer?.removeFromSuperlayer()
            self.gradientView.layer.isHidden = true
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
        timeSpent += 1
        if player?.rate == 1 && indicator != nil {
            updateIndicatorState(toStart: false)
        }
        if gradientView.layer.isHidden == true {
            // currentPlayer is our instance of the AVPlayer
            if let currItem = player?.currentItem {
                let rule = AVTextStyleRule(textMarkupAttributes: [kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection as String: 95])
                // 93% from the top of the video
                currItem.textStyleRules = [rule!]
            }
        } else {
            //currentPlayer is our instance of the AVPlayer
            if let currItem = player?.currentItem {
                let rule = AVTextStyleRule(textMarkupAttributes: [kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection as String: 3])
                // 3% from the top of the video
                currItem.textStyleRules = [rule!]
            }
        }
    }
    
    @IBAction func okButtonPressedForSavingMenuSetting(_ sender: Any) {
        resetTimertToHideControls()
        self.removeControlDetailview(forOkButtonClick: true)
        myPreferredFocusView = nil
        if stateOfPlayerBeforeButtonClickWasPaused {
            changePlayerPlayingStatus(shouldPlay: false)
        } else {
            changePlayerPlayingStatus(shouldPlay: true)
        }
    }
    
    func removeControlDetailview(forOkButtonClick: Bool) {
        resetTimertToHideControls()
        if forOkButtonClick {
            if bitrateTableView != nil {
                changeValuesOfTableAfterOkButtonClick(forBitrateTable: true)
            } else {
                changeValuesOfTableAfterOkButtonClick(forBitrateTable: false)
            }
        }
        subtitleTableView?.removeFromSuperview()
        multiAudioTableView?.removeFromSuperview()
        bitrateTableView?.removeFromSuperview()
        
        subtitleTableView = nil
        multiAudioTableView = nil
        bitrateTableView = nil
        
        self.popUpHolderView.isHidden = true
    }
    
    func changeValuesOfTableAfterOkButtonClick(forBitrateTable: Bool){
        if forBitrateTable {
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
            }
        } else {
            self.changePlayerSubtitleLanguageAndAudioLanguage(subtitleLang: subtitleTableView?.currentSelectedItem, audioLang: multiAudioTableView?.currentSelectedItem)
            
            if multiAudioTableView?.currentSelectedItem != lastSelectedAudioLanguage{
                playerViewModel?.sendAudioChangedAnalytics()
            }
            lastSelectedAudioLanguage = multiAudioTableView?.currentSelectedItem
            lastSelectedAudioSubtitle = subtitleTableView?.currentSelectedItem
        }
    }
    func changePlayerSubtitleLanguageAndAudioLanguage(subtitleLang: String?, audioLang: String?) {
        if let subtitle = subtitleLang {
            self.playerSubTitleLanguage(subtitle)
        }
        if let audio = audioLang {
            self.playerAudioLanguage(audio)
        }
        changePlayerPlayingStatus(shouldPlay: true)
    }
    
    func changePlayerPlayingStatus(shouldPlay: Bool) {
        if shouldPlay {
            player?.play()
            controlsView?.changePlayPauseButtonIcon(shouldPause: false)
        } else {
            player?.pause()
            controlsView?.changePlayPauseButtonIcon(shouldPause: true)
        }
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
        lastSelectedAudioLanguage = audioLanguage
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
        } else {
            _ = player?.currentItem?.select(type: .subtitle, name: "")
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
extension CustomPlayerView: PlayerControlsDelegate {
    func playTapped() {
        resetTimertToHideControls()
        if isPlayerPaused {
            changePlayerPlayingStatus(shouldPlay: true)
        } else {
            changePlayerPlayingStatus(shouldPlay: false)
        }
    }
    
    func subtitlesAndMultiaudioButtonPressed(todisplay: Bool) {
        stateOfPlayerBeforeButtonClickWasPaused = isPlayerPaused
        
        invalidateTimerForControl()
        if player?.rate == 0 {
            stateOfPlayerBeforeButtonClickWasPaused = true
        } else {
            stateOfPlayerBeforeButtonClickWasPaused = false
        }
        changePlayerPlayingStatus(shouldPlay: false)
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
        
        self.popUpHolderView.layoutIfNeeded()
        
        
        multiAudioTableView = Utility.getXib("PlayerSettingMenu", type: PlayerSettingMenu.self, owner: self)
        multiAudioTableView?.frame = CGRect.init(x: tableViewHolderInPopupView.frame.origin.x, y: tableViewHolderInPopupView.frame.origin.y, width: popUpTableViewHolderWidth.constant/2, height: tableViewHolderInPopupView.bounds.height)
        if let lastIndex = audioArray.firstIndex(of: lastSelectedAudioLanguage ?? ""){
            multiAudioTableView?.previousSelectedIndexpath = IndexPath(row: lastIndex, section: 0)
        } else if let audioLanguage = playerViewModel?.playbackRightsModel?.languageIndex?.name {
            multiAudioTableView?.previousSelectedIndexpath = IndexPath(row: audioArray.firstIndex(of: audioLanguage) ?? 0, section: 0)
            lastSelectedAudioLanguage = audioArray[multiAudioTableView?.previousSelectedIndexpath?.row ?? 0]
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
        myPreferredFocusView = self.tableViewHolderInPopupView
        self.updateFocusIfNeeded()
        self.setNeedsFocusUpdate()
    }
    
    func settingsButtonPressed(toDisplay: Bool) {
        stateOfPlayerBeforeButtonClickWasPaused = isPlayerPaused
        invalidateTimerForControl()
        changePlayerPlayingStatus(shouldPlay: false)
        self.popUpHolderView.isHidden = false
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
        myPreferredFocusView = self.tableViewHolderInPopupView
        self.updateFocusIfNeeded()
        self.setNeedsFocusUpdate()
    }
    func nextButtonPressed(toDisplay: Bool) {
        resetTimertToHideControls()
        playnextOrPreviousItem(playNext: true)
    }
    
    func previousButtonPressed(toDisplay: Bool) {
        resetTimertToHideControls()
        playnextOrPreviousItem(playNext: false)
    }
    func playnextOrPreviousItem(playNext: Bool) {
        guard let currentTime = player?.currentItem?.currentTime().seconds else {
            return
        }
        guard let duration = player?.currentItem?.duration.seconds else {
            return
        }
        if playNext {
            if currentTime + 10 < duration {
                player?.seek(to: CMTimeMakeWithSeconds(Float64(currentTime + 10), preferredTimescale: 1), completionHandler: { (isSuccess) in
                    DispatchQueue.main.async {
                        print("hide indicator on play next")
                        self.changePlayerPlayingStatus(shouldPlay: true)
                        self.updateIndicatorState(toStart: false)
                    }
                })
            }
        } else {
            if currentTime - 10 > 0 {
                player?.seek(to: CMTimeMakeWithSeconds(Float64(currentTime - 10), preferredTimescale: 1), completionHandler: { (isSuccess) in
                    DispatchQueue.main.async {
                        print("hide indicator on play previous")
                        self.changePlayerPlayingStatus(shouldPlay: true)
                        self.updateIndicatorState(toStart: false)
                    }
                })
            }
        }
    }
    
    
    
    
    func skipIntroButtonPressed() {
        hideUnhideControl(visibleControls: .hideSkipIntro)
        guard let seekTime = playerViewModel?.convertStringToSeconds(strTime: playerViewModel?.playbackRightsModel?.introCreditEnd ?? playerViewModel?.playbackRightsModel?.recapCreditEnd ?? "") else {
            return
        }
        DispatchQueue.main.async {
            self.player?.seek(to: CMTime(seconds: seekTime, preferredTimescale: 1), completionHandler: { (isSuccess) in
                DispatchQueue.main.async {
                    self.updateIndicatorState(toStart: false)
                    print("hide Indicator on skip Intro")
                }
            })
        }
        let eventProperties : [String : Any] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ,"Video Id": playerViewModel?.itemId, "Type": playerViewModel?.appType.rawValue, "Category Position": "\(playerViewModel?.fromCategoryIndex)", "Language": playerViewModel?.itemLanguage, "Bitrate" : playerViewModel?.bitrate, "Duration" : playerViewModel?.currentDuration ?? 0.0 ,"Pro.Clicked": "YES"]
        playerViewModel?.sendSkipIntroEvent(eventProperties: eventProperties)
    }
    
    func cancelTimerForHideControl() {
        if timerToHideControls == nil{
            return
        }
        timerToHideControls.invalidate()
    }
    
//    func resetTimerForHideControl() {
//        self.resetTimertToHideControls()
//    }
    
    func setPlayerSeekTo(seekValue: CGFloat) {
        DispatchQueue.main.async {
            let seekToValue = Double(seekValue) * self.getPlayerDuration()
            self.player?.seek(to: CMTimeMakeWithSeconds(Float64(seekToValue), preferredTimescale: 1))
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
            print("INdicator started pin verification")
            //            addSubviewOnPlayer()
            playerViewModel?.instantiatePlayerAfterParentalCheck()
        }
    }
}

extension CustomPlayerView: PlayerViewModelDelegate {
    func checkTimeToShowSkipButton(isValidTime: Bool, starttime: Double, endTime: Double) {
        self.shouldShowSkipIntroButton = isValidTime
        if isValidTime {
            if firstTime == nil {
                self.firstTime = true
            }
            if self.firstTime ?? false {
                hideUnhideControl(visibleControls: .skipIntroOnlyVisible)
                firstTime = false
                self.myPreferredFocusView = controlsView?.skipIntroButton
                self.updateFocusIfNeeded()
                self.setNeedsFocusUpdate()
            }
        } else {
            hideUnhideControl(visibleControls: .hideSkipIntro)
            firstTime = nil
        }
        
//        if isValidTime && !(controlsView?.isHidden ?? false) {
//            hideUnhideControl(visibleControls: .SkipIntroOnly, toHide: false)
//            resetTimertToHideControls()
////            controlsView?.skipIntroButton.isHidden = false
//        } else {
//            if isValidTime && (controlsView?.isHidden ?? false) {
//                if Int(starttime) == Int(player?.currentItem?.currentTime().seconds ?? 0.0){
//                        hideUnhideControl(visibleControls: .SkipIntroOnly, toHide: false)
//                        resetTimertToHideControls()
////                    controlsView?.isHidden = false
////                    controlsView?.skipIntroButton.isHidden = false
//                } else if Int(starttime + 5) == Int(player?.currentItem?.currentTime().seconds ?? 0.0){
//                        hideUnhideControl(visibleControls: .All, toHide: true)
////                    controlsView?.isHidden = true
////                    controlsView?.skipIntroButton.isHidden = true
//                }
//
//            } else {
//                controlsView?.skipIntroButton.isHidden = true
//            }
//        }
    }
    
    func dismissPlayer() {
        self.resetPlayer()
        self.delegate?.removePlayerController()
    }
    
    func updateIndicatorState(toStart: Bool) {
        let spinnerColor : UIColor = ThemeManager.shared.selectionColor
        if toStart {
            DispatchQueue.main.async {
                if self.indicator != nil {
                    return
                }
                self.indicator = IndicatorManager.shared.addAndStartAnimatingANewIndicator(spinnerColor: spinnerColor, superView: self, superViewSize: self.frame.size, spinnerSize: CGSize(width: 100, height: 100), spinnerWidth: 10, superViewUserInteractionEnabled: false, shouldUseCoverLayer: true, coverLayerOpacity: 1, coverLayerColor: .clear)
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
        print("hide indicator on add to resume watch")
        self.popUpHolderView.isHidden = true
        resumeWatchView = UINib(nibName: "ResumeWatchView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? ResumeWatchView
        resumeWatchView?.frame = self.bounds
        resumeWatchView?.delegate = self
        self.addSubview(resumeWatchView!)
        self.controlHolderView.isHidden = true
        self.moreLikeHolderView.isHidden = true
    }
    
    func setValuesForSubviewsOnPlayer() {
        startTimerToHideControls()
        setValuesOnControlView()
    }
    
    func addSubviewOnPlayer() {
        DispatchQueue.main.async {
            self.addPlayersControlView()
            self.addMoreLikeView()
            self.addGradientView()
        }
    }
    
    func reloadMoreLikeCollectionView(currentMorelikeIndex: Int) {
        currentPlayingIndex = currentMorelikeIndex
        self.moreLikeView?.currentPlayingIndex = currentMorelikeIndex
        self.moreLikeView?.isPlayList = self.isPlayList
        self.recommendationArray = playerViewModel?.recommendationArray ?? false
        //        self.moreLikeView?.moreArray = playerViewModel?.moreArray
        //        self.moreLikeView?.episodesArray = playerViewModel?.episodeArray
        setValuesForMoreLikeData()
        self.moreLikeView?.appType = playerViewModel?.appType ?? .None
        DispatchQueue.main.async {
            self.moreLikeView?.moreLikeCollectionView.reloadData()
        }
    }
    
    func checkParentalControlFor(playbackRightModel: PlaybackRightsModel) {
        self.playbackRightModel = playbackRightModel
        let ageGroup:AgeGroup = self.playbackRightModel?.maturityAgeGrp ?? .allAge
        if ParentalPinManager.shared.checkParentalPin(ageGroup) {
            DispatchQueue.main.async {
                self.updateIndicatorState(toStart: false)
                print("Hide indicator on check parental for playbackright")
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
            print("hide on add player to controller")
            if self.player?.currentItem != nil {
                self.player?.replaceCurrentItem(with: self.playerViewModel?.playerItem)
                //                self.player?.replaceCurrentItem(with: playerItem)
            }
            else {
                self.resetPlayer()
                self.player = AVPlayer(playerItem: self.playerViewModel?.playerItem)
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer?.frame = self.bounds
                self.playerLayer?.videoGravity = .resizeAspect
                self.playerHolderView.layer.addSublayer(self.playerLayer!)
                self.didSeek = false
                if self.playerViewModel?.currentDuration ?? 0 > 0 {
                }
            }
            
            
            self.setCurrentPlayingOnMoreLike()
            
            if self.audioLanguage != nil, self.audioLanguage?.name.lowercased() == "none" {
                
            }
            if let selectedLanguage = self.lastSelectedAudioLanguage {
                self.playerAudioLanguage(selectedLanguage)
            } else {
                if let audioLanguageToBePlayed = MultiAudioManager.getFinalAudioLanguage(itemIdToBeChecked: self.playerItem?.id ?? "", appType: self.playerItem?.appType ?? .TVShow, defaultLanguage: self.audioLanguage) {
                    self.playerAudioLanguage(audioLanguageToBePlayed.name)
                    //                if let audioLang = self.lastSelectedAudioLanguage {
                    //                    print(audioLang)
                    //                    if audioLang != audioLanguageToBePlayed.name {
                    //                        self.playerAudioLanguage(audioLang)
                    //                    }
                    //                }
                    //                if let audioLang = self.lastSelectedAudioLanguage?.lowercased() && audioLanguage != audioLanguageToBePlayed.name{
                    //                    self.playerAudioLanguage(self.audioLanguage)
                    //                } else {
                    //                    self.playerAudioLanguage(audioLanguageToBePlayed.name)
                    //                }
                }
            }
            //            self.setPlayerSeekTo(seekValue: CGFloat(self.playerViewModel?.currentDuration ?? 0))
            self.addPlayerNotificationObserver()
            
            self.player?.seek(to: CMTime(seconds: Double(self.playerViewModel?.currentDuration ?? 0), preferredTimescale: 1))
            self.changePlayerPlayingStatus(shouldPlay: true)
        }
    }
    
    func addPlayerNotificationObserver () {
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackBufferFull), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackBufferEmpty), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackLikelyToKeepUp), options: [.new, .initial], context: &playerViewControllerKVOContext)
    }
    
    
    //MARK:- Remove Player Observer
    func removePlayerObserver() {
        guard let viewModel = playerViewModel else {
            return
        }
        //sendMediaEndAnalyticsEvent()
        if (viewModel.appType == .Movie || viewModel.appType == .Episode), viewModel.isItemToBeAddedInResumeWatchList {
        viewModel.updateResumeWatchList(audioLanguage: lastSelectedAudioLanguage ?? (playerViewModel?.playbackRightsModel?.defaultLanguage ?? ""))
        }
        if let timeObserverToken = playerTimeObserverToken {
            print("************************Observer removed successfully*******************")
            self.player?.removeTimeObserver(timeObserverToken)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.duration), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.rate), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackBufferFull), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackBufferEmpty), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackLikelyToKeepUp), context: &playerViewControllerKVOContext)
        playerTimeObserverToken = nil
    }
    
    
    //MARK:- AVPlayer Finish Playing Item
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.updateIndicatorState(toStart: false)
        print("HideOn playerdidFInish")
        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey),isPlayList {
            
            if let currentPlayingIndex = currentPlayingIndex
            {
                
                if playerItem?.appType == .Music || playerItem?.appType == .Clip || playerItem?.appType == .Trailer || playerItem?.appType == .Movie {
                    //                    if playerItem?.appType == .Movie {
                    //                        playerViewModel?.updateResumeWatchList(audioLanguage: playerItem?.audioLanguage?.name ?? "")
                    //                    }
                    if let moreArray = moreLikeView?.moreArray, isPlayList {
                        if (currentPlayingIndex + 1) < moreArray.count {
                            let nextItem = moreArray[currentPlayingIndex + 1]
                            self.currentPlayingIndex = currentPlayingIndex + 1
                            self.initialiseViewModelForItem(item: nextItem, latestEpisodeId: nil)
                            return
                        }
                    }
                }
                else if playerItem?.appType == .Episode || playerItem?.appType == .TVShow{
                    if let moreArray = moreLikeView?.episodesArray {
                        if let nextItemTupple = playerViewModel?.gettingNextEpisodeAndSequence(episodes: moreArray, index: currentPlayingIndex) {
                            self.currentPlayingIndex += nextItemTupple.1 ? 1: -1
                            self.initialiseViewModelForItem(item: nextItemTupple.0.getItem, latestEpisodeId: nil)
                            return
                        }
                    }
                }
                
            }
        }
        //        if playerItem?.appType == .Episode || playerItem?.appType == .Movies || playerItem?.appType == .TVShow{
        //            playerViewModel?.updateResumeWatchList(audioLanguage: playerItem?.audioLanguage?.name ?? "")
        //        }
        if !(playerViewModel?.isMediaEndAnalyticsEventSent ?? false){
            playerViewModel?.isMediaEndAnalyticsEventSent = true
            playerViewModel?.sendMediaEndAnalyticsEvent(timeSpent: timeSpent)
        }
        resetPlayer()
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
            //            if player?.rate == 1 {
            //                self.updateIndicatorState(toStart: false)
            //            }
            print("indicator started on isPlaybackBufferempty\(player?.rate)")
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
            } else {
                newStatus = .unknown
            }
            switch newStatus {
            case .readyToPlay:
                self.updateIndicatorState(toStart: false)
                print("indicator start on ready to play")
                playerViewModel?.videoStartingTimeDuration = Int(playerViewModel?.videoStartingTime.timeIntervalSinceNow ?? 0)
                playerViewModel?.isItemToBeAddedInResumeWatchList = true
                self.addPlayerPeriodicTimeObserver()
                playerViewModel?.sendMediaStartAnalyticsEvent()
                break
            case .failed:
                if indicator != nil {
                    updateIndicatorState(toStart: false)
                    print("indicator stop on failed")
                }
                
                Log.DLog(message: "Failed" as AnyObject)
                playerViewModel?.handlePlayerStatusFailed()
                //                self.isRecommendationCollectionViewEnabled = false
            //If video failed once and valid fps url is there
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
                    } else {
                        self?.hideUnhideControl(visibleControls: .hideNextVideo)
                    }
                } else {
                    self?.playerTimeObserverToken = nil
                }
        }
    }
    
    
    func checkForNextVideoInAutoPlay(remainingTime: Double) {
        let autoPlayOn = UserDefaults.standard.bool(forKey: isAutoPlayOnKey)
        if autoPlayOn{
            guard let currentPlayingIndex = currentPlayingIndex else { return }
            if self.playerItem?.appType == .Episode || self.playerItem?.appType == .TVShow {
                
                if let moreArray = moreLikeView?.episodesArray, moreArray.count > 0 {
                    self.resetTimertToHideControls()
                    
                    if let nextItemTupple = playerViewModel?.gettingNextEpisodeAndSequence(episodes: moreArray, index: currentPlayingIndex) {
                        self.hideUnhideControl(visibleControls: .nextVideoOnlyVisible)
                        self.controlsView?.showNextVideoView(videoName: nextItemTupple.0.name ?? "", remainingTime: Int(remainingTime), banner: nextItemTupple.0.banner ?? "")
                    }
                }
            }
            else {
                if let moreArray = moreLikeView?.moreArray, moreArray.count > 0, self.isPlayList {
                    self.resetTimertToHideControls()
                    if (currentPlayingIndex + 1) < moreArray.count {
                        let nextItem = moreArray[(currentPlayingIndex + 1)]
                        self.hideUnhideControl(visibleControls: .nextVideoOnlyVisible)
                        self.controlsView?.showNextVideoView(videoName: nextItem.name ?? "", remainingTime: Int(remainingTime), banner: nextItem.banner ?? "")
                    }
                }
            }
        } else {
            hideUnhideControl(visibleControls: .allVisible)
        }
    }
    
    func hideUnhideControl(visibleControls : VisbleControls) {
        if controlsView == nil{
            return
        }
        switch visibleControls {
        case .allVisible:
            controlsView?.skipIntroButton.isHidden = !self.shouldShowSkipIntroButton
            gradientView.isHidden = false
            controlsView?.sliderView?.isHidden = false
            controlsView?.playerButtonsHolderView.isHidden = false
            moreLikeView?.isHidden = false
            self.controlVisibleState = .allVisible
            resetTimertToHideControls()
        case .nextVideoOnlyVisible:
            controlsView?.recommendViewHolder.isHidden = false
        case .skipIntroOnlyVisible:
            self.controlsView?.skipIntroButton.isHidden = false
            self.resetTimertToHideControls()
        case .allHide:
            controlsView?.skipIntroButton.isHidden = true
            gradientView.isHidden = true
            controlsView?.sliderView?.isHidden = true
            controlsView?.playerButtonsHolderView.isHidden = true
            moreLikeView?.isHidden = true
            self.controlsView?.sliderView?.sliderLeadingForSeeking.constant = self.controlsView?.sliderView?.sliderLeading.constant ?? 0
            self.bottomSpaceOfMoreLikeInContainer.constant = clearanceFromBottomForMoreLikeView
            self.updateFocusIfNeeded()
            self.setNeedsFocusUpdate()
            
        case .allVisibleExceptSkipIntro:
            controlsView?.sliderView?.isHidden = false
            controlsView?.playerButtonsHolderView.isHidden = false
            moreLikeView?.isHidden = false
            controlsView?.recommendViewHolder.isHidden = false
            resetTimertToHideControls()
        case .hideSkipIntro:
            controlsView?.skipIntroButton.isHidden = true
        case .hideNextVideo:
            controlsView?.recommendViewHolder.isHidden = true
        }
    }
    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String) {
        DispatchQueue.main.async {
            self.updateIndicatorState(toStart: false)
            print("hide indicator on playbackright Data error")
            self.alertMsg.isHidden = false
            self.alertMsg.text = "Some problem occured!!"
            
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
    func startTimerToHideControls() {
        if timerToHideControls != nil {
            timerToHideControls.invalidate()
            timerToHideControls = nil
        }
        timerToHideControls = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {[weak self] (timer) in
//            self?.hideControlsView()
            self?.hideUnhideControl(visibleControls: .allHide)
            self?.timerToHideControls.invalidate()
            self?.timerToHideControls = nil
        })
    }
    
    func resetTimertToHideControls() {
        if controlsView != nil || controlsView?.isHidden == false{
            invalidateTimerForControl()
            self.startTimerToHideControls()
        }
    }
    
    func invalidateTimerForControl() {
        if self.timerToHideControls != nil {
            self.timerToHideControls.invalidate()
        }
        
        
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.type{
            case .downArrow, .leftArrow, .upArrow, .rightArrow:
                resetTimertToHideControls()
            case .menu:
                super.pressesBegan(presses, with: event)
                print("Menu")
                //                if popUpHolderView.isHidden == true {
                //                    self.resetAndRemovePlayer()
                //                    self.delegate?.removePlayerController()
                //                } else {
                //                    resetTimer()
                //                    removeControlDetailview()
                //                    print("menu")
            //                }
            case .playPause:
                print("playPause")
                if isPlayerPaused {
                    changePlayerPlayingStatus(shouldPlay: true)
                } else {
                    changePlayerPlayingStatus(shouldPlay: false)
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
                hideUnhideControl(visibleControls: .allVisible)
                resetTimertToHideControls()
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
        self.currentPlayingIndex = index
        resetPlayer()
        if newItem.appType == .Movie {
            delegate?.presenMetadataOnMoreLikeTapped(item: newItem)
        } else {
            if moreLikeView?.episodesArray != nil {
                playerViewModel?.updateResumeWatchList(audioLanguage: playerItem?.audioLanguage?.name ?? playerItem?.language ?? "")
            }
            self.initialiseViewModelForItem(item: newItem, latestEpisodeId: nil)
            if moreLikeView?.moreArray != nil  && isPlayList != true{
//                playerViewModel?.callWebServiceForMoreLikeData()
            }
        }
    }
}

extension CustomPlayerView: ResumeWatchDelegate {
    func resumeWatchingPressed() {
        resumeWatchView?.removeFromSuperview()
        resumeWatchView = nil
        playerViewModel?.callWebServiceForPlaybackRights(id: playerItem?.id ?? "")
        //        addSubviewOnPlayer()
        //        setValuesForSubviewsOnPlayer()
        self.controlHolderView.isHidden = false
        //        self.controlsView?.sliderView?.sliderLeadingForSeeking.constant = playerViewModel?.currentDuration / playerItem?.
        self.moreLikeHolderView.isHidden = false
    }
    
    func startFromBeginning() {
        playerViewModel?.currentDuration = 0
        playerViewModel?.callWebServiceForPlaybackRights(id: playerItem?.id ?? "")
        resumeWatchView?.removeFromSuperview()
        resumeWatchView = nil
        //        addSubviewOnPlayer()
        //        self.setValuesForSubviewsOnPlayer()
        self.controlHolderView.isHidden = false
        self.moreLikeHolderView.isHidden = false
        
    }
    
    func removeFromResumeWatchingPressed() {
        playerViewModel?.callWebServiceForRemovingResumedWatchlist()
        resumeWatchView?.removeFromSuperview()
        resumeWatchView = nil
        self.updateIndicatorState(toStart: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.updateIndicatorState(toStart: false)
            self.delegate?.removePlayerController()
        }
    }
    
    
}
enum VisbleControls {
    case skipIntroOnlyVisible
    case nextVideoOnlyVisible
    case allHide
    case allVisible
//    case allVisibleExceptNext // Skip intro to be shown
    case allVisibleExceptSkipIntro
    case hideSkipIntro
    case hideNextVideo
}
