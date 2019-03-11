//
//  ViewController.swift
//  CustomPlayer
//
//  Created by Shweta Adagale on 26/02/19.
//  Copyright © 2019 Shweta Adagale. All rights reserved.
//

import UIKit
import Foundation

class PlayerViewController: UIViewController {
    
    //    @IBOutlet weak var recommendView: UIView!
//    fileprivate var playerViewModel: PlayerViewModel
//    fileprivate var playbackRightModel : PlaybackRightsModel?
//    fileprivate var enterParentalPinView: EnterParentalPinView?
//    fileprivate var enterPinViewModel: EnterPinViewModel?
    fileprivate var playerItem: Item?

    
    init(item: Item) {
//        super.init()
//        playerViewModel = PlayerViewModel(item: item)
//        super.init(nibName: nil, bundle: nil)
//        playerViewModel.delegate = self
        self.playerItem = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    func configureView() {
        let viewforplayer = UINib(nibName: "CustomPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! CustomPlayerView
            viewforplayer.addAsSubViewWithConstraints(self.view, top: 0, bottom: 0, leading: 0, trailing: 0)
        viewforplayer.configureView(item: self.playerItem!, superView: self.view)
        }
}

extension UIView {
    func addConstraintsToViewForPlayer(_ superView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
    }
}

//
//extension PlayerViewController: EnterPinViewModelDelegate {
//    func pinVerification(_ isSucceed: Bool) {
//        if isSucceed {
//            enterPinViewModel = nil
//            enterParentalPinView?.removeFromSuperview()
//            enterParentalPinView = nil
//            playerViewModel.instantiatePlayerAfterParentalCheck()
//        }
//    }
//}
//
//extension PlayerViewController: PlayerViewModelDelegate {
//    func checkParentalControlFor(playbackRightModel: PlaybackRightsModel) {
//        self.playbackRightModel = playbackRightModel
//        let ageGroup:AgeGroup = self.playbackRightModel?.maturityAgeGrp ?? .allAge
//        if ParentalPinManager.shared.checkParentalPin(ageGroup) {
//            enterParentalPinView = Utility.getXib(EnterParentalPinViewIdentifier, type: EnterParentalPinView.self, owner: self)
//            enterPinViewModel = EnterPinViewModel(contentName: playbackRightModel.contentName ?? "", delegate: self)
//            enterParentalPinView?.delegate = enterPinViewModel
//            enterParentalPinView?.contentTitle.text = self.enterPinViewModel?.contentName
//            enterParentalPinView?.frame = self.view.frame
//            self.view.addSubview(enterParentalPinView!)
//        }
//        else {
//            playerViewModel.instantiatePlayerAfterParentalCheck()
//        }
//    }
//
//    func addAvPlayerControllerToController() {
//
//
//            let viewforplayer = UINib(nibName: "CustomPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! CustomPlayerView
//            if let path = Bundle.main.path(forResource: "SampleVideo", ofType: "mp4"){
////                let url = URL(fileURLWithPath: path)
//                viewforplayer.configureView(player: (playerViewModel.playerController?.player)!, superView: self.view)
//                viewforplayer.addAsSubViewWithConstraints(self.view, top: 0, bottom: 0, leading: 0, trailing: 0)
//            }
//
////        self.addChildViewController(playerViewModel.playerController!)
////        self.view.addSubview((playerViewModel.playerController?.view)!)
////        playerViewModel.playerController?.view.frame = self.view.frame
//    }
//
//    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String) {
//        //vinit_comment handle player error
//    }
//}
