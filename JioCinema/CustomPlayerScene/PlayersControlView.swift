//
//  CustomSlider.swift
//  JioCinema
//
//  Created by Shweta Adagale on 05/03/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

protocol PlayerControlsDelegate: NSObject {
    func getTimeDetails(_ currentTime: String,_ duration: String)
    func setPlayerSeekTo(seekValue: CGFloat)
    func cancelTimerForHideControl()
    func resetTimerForHideControl()
    func skipIntroButtonPressed()
}

class PlayersControlView: UIView {
    @IBOutlet weak var sliderHolderView: UIView!
    @IBOutlet weak var playerButtonsHolderView: UIView!
    @IBOutlet weak var recommendViewHolder: UIView!
    @IBOutlet weak var nextContentImageView: UIImageView!
    @IBOutlet weak var nextContentTitle: UILabel!
    @IBOutlet weak var nextContentSubtitle: UILabel!    
    @IBOutlet weak var skipIntroButton: UIButton!
    
    var isPlayerPaused: Bool {
        return (self.superview?.superview as? CustomPlayerView)?.isPlayerPaused ?? true
    }

    var isPaused = false
    
    weak var delegate : PlayerControlsDelegate?

    var sliderView : CustomSlider?
    var playerButtonsView: PlayerButtonsView?
    
    func configurePlayersControlView() {
        addCustomSlider()
        addPlayerButtons()
    }
    
    func addCustomSlider() {
        sliderView = UINib(nibName: "CustomSlider", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomSlider
        sliderView?.frame = sliderHolderView.bounds
        sliderView?.configureControls()
        sliderView?.sliderDelegate = self
        sliderHolderView.addSubview(sliderView!)
    }
    
    func addPlayerButtons() {
        playerButtonsView = UINib(nibName: "PlayerButtonsView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayerButtonsView
        playerButtonsView?.frame = playerButtonsHolderView.bounds
        playerButtonsView?.configurePlayerButtonsView()
        playerButtonsHolderView.addSubview(playerButtonsView!)
    }
    @IBAction func skipIntroPressed(_ sender: Any) {
        delegate?.skipIntroButtonPressed()
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            switch press.type{
            case .downArrow, .leftArrow, .upArrow, .rightArrow:
                //resetTimer()
                print("Arrow")
            case .menu:
                
                print("menu")
            case .playPause:
                print("playPause")
               
            case .select:
                print("select")
            @unknown default:
                print("unknown")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches{
            switch touch.type{
            case .direct:
                print("Direct")
            case .indirect:
                print("indirect")
            case .pencil:
                print("pencil")
            @unknown default:
                print("unknown")
            }
        }
    }
    
    
    
    deinit {
        print("PlayerControlsView deinit called")
    }
    
    func showNextVideoView(videoName: String, remainingTime: Int, banner: String) {
        DispatchQueue.main.async {
            
            self.recommendViewHolder.isHidden = false
            self.nextContentTitle.text = videoName
            self.nextContentSubtitle.text = "Playing in " + "\(5)" + " Seconds"
            var t1 = 4
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true , block: {(t) in
                
                self.nextContentSubtitle.text = "Playing in " + "\(Int(t1))" + " Seconds"
                if t1 < 1 {
                    self.recommendViewHolder.isHidden = true
                    t.invalidate()
                }
                t1 = t1 - 1
            })
            
            let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(banner) ?? ""
            let url = URL(string: imageUrl)
            self.nextContentImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.fromCacheOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
        }
        
    }
}

extension PlayersControlView: CustomSliderProtocol {
    func resetTimerForShowControl() {
        delegate?.resetTimerForHideControl()
    }
    
    func seekPlayerTo(pointX: CGFloat) {
        delegate?.setPlayerSeekTo(seekValue: pointX)
    }
    
    func cancelTimerForHideControl() {
        delegate?.cancelTimerForHideControl()
    }

}
