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
    func setPlayerSeekTo(seekValue: CGFloat)
    func cancelTimerForHideControl()
    func resetTimertToHideControls()
    func skipIntroButtonPressed()
    
    func playTapped()
    func subtitlesAndMultiaudioButtonPressed(todisplay: Bool)
    func settingsButtonPressed(toDisplay: Bool)
    func nextButtonPressed(toDisplay: Bool)
    func previousButtonPressed(toDisplay: Bool)
}

class PlayersControlView: UIView {
    @IBOutlet weak var sliderHolderView: UIView!
    @IBOutlet weak var playerButtonsHolderView: UIView!
    @IBOutlet weak var recommendViewHolder: UIView!
    @IBOutlet weak var nextContentImageView: UIImageView!
    @IBOutlet weak var nextContentTitle: UILabel!
    @IBOutlet weak var nextContentSubtitle: UILabel!    
    @IBOutlet weak var skipIntroButton: UIButton!
    
    @IBOutlet weak var controlButtonCollectionView: UICollectionView!
    
    var arrayOfPlayerButtonItem : [PlayerButtonItem] = []
    var ispaused: Bool = false
    
    var isPaused = false
    
    weak var delegate : PlayerControlsDelegate?

    var sliderView : CustomSlider?
//    var playerButtonsView: PlayerButtonsView?
    
    func configurePlayersControlView() {
        
        addCustomSlider()
        configurePlayerButtonsView()
    }
    
    func addCustomSlider() {
        sliderView = UINib(nibName: "CustomSlider", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomSlider
        sliderView?.frame = sliderHolderView.bounds
        sliderView?.configureControls()
        sliderView?.sliderDelegate = self
        let colorLayer = CAGradientLayer()
        colorLayer.frame = sliderHolderView.bounds
        colorLayer.colors = [UIColor.clear.cgColor,UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        //        sliderHolderView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        //        sliderHolderView.layer.insertSublayer(colorLayer, at:0)
        
        sliderHolderView.addSubview(sliderView!)

    }
    

    
    func configurePlayerButtonsView() {
    controlButtonCollectionView.delegate = self
    controlButtonCollectionView.dataSource = self
    controlButtonCollectionView.register(UINib(nibName: "ButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ButtonCollectionViewCell")
    appendArray()
    }
    
    func appendArray() {
        for tag in 0...4{
            let item = PlayerButtonItem(tag: tag)
            arrayOfPlayerButtonItem.append(item)
        }
    }
    func changePlayPauseButtonIcon(shouldPause: Bool) {
        let indexPath = IndexPath(row: 2, section: 0)
        guard let cell = controlButtonCollectionView.cellForItem(at: indexPath) as? ButtonCollectionViewCell else {return}
        if !shouldPause {
            cell.playerButton.setAttributedTitle(NSAttributedString(string: "p"), for: .normal)
            //            cell.playerButton.setImage(UIImage(named: "Pause"), for: .normal)
            cell.buttonTitle.text = "Pause"
        } else {
            cell.playerButton.setAttributedTitle(NSAttributedString(string: "P"), for: .normal)
            //            cell.playerButton.setImage(UIImage(named: "play"), for: .normal)
            cell.buttonTitle.text = "Play"
        }
    }
    
    @IBAction func skipIntroPressed(_ sender: Any) {
        delegate?.skipIntroButtonPressed()
    }
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        super.pressesBegan(presses, with: event)
//        for press in presses {
//            switch press.type{
//            case .downArrow, .leftArrow, .upArrow, .rightArrow:
//                //resetTimer()
//                print("Arrow")
//            case .menu:
//                print("menu")
//            case .playPause:
//                print("playPause")
//            case .select:
//                print("select")
//            @unknown default:
//                print("unknown")
//            }
//        }
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        for touch in touches{
//            switch touch.type{
//            case .direct:
//                print("Direct")
//            case .indirect:
//                print("indirect")
//            case .pencil:
//                print("pencil")
//            @unknown default:
//                print("unknown")
//            }
//        }
//    }
    
    
    
    deinit {
        print("PlayerControlsView deinit called")
    }
    
    func showNextVideoView(videoName: String, remainingTime: Int, banner: String) {
        DispatchQueue.main.async {
//            self.recommendViewHolder.isHidden = false
//            self.recommendViewHolder.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.nextContentTitle.text = videoName
            self.nextContentSubtitle.text = "Playing in " + "\(Int(remainingTime))" + " Seconds"
//            var t1 = 4
//            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true , block: {(t) in
//
//                self.nextContentSubtitle.text = "Playing in " + "\(Int(t1))" + " Seconds"
//                if t1 < 1 {
//                    self.isHidden = false
//                    self.recommendViewHolder.isHidden = true
//                    t.invalidate()
//                }
//                t1 = t1 - 1
//            })
//
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
        delegate?.resetTimertToHideControls()
    }
    
    func seekPlayerTo(pointX: CGFloat) {
        delegate?.setPlayerSeekTo(seekValue: pointX)
    }
    
    func cancelTimerForHideControl() {
        delegate?.cancelTimerForHideControl()
    }

}


extension PlayersControlView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfPlayerButtonItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCollectionViewCell", for: indexPath) as! ButtonCollectionViewCell
        cell.configCellView(item: arrayOfPlayerButtonItem[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return inset
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            delegate?.settingsButtonPressed(toDisplay: true)
        case 1:
            delegate?.previousButtonPressed(toDisplay: true)
        case 2:
            delegate?.playTapped()
        case 3:
            delegate?.nextButtonPressed(toDisplay: true)
        case 4:
         delegate?.subtitlesAndMultiaudioButtonPressed(todisplay: true)
        default:
            print("default")
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 || indexPath.row == arrayOfPlayerButtonItem.count - 1 {
            return CGSize(width: 296, height: self.controlButtonCollectionView.frame.height)
        } else {
            return CGSize(width: 132, height: self.controlButtonCollectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

struct PlayerButtonItem {
    var selectedImage: String!
    var unselectedImage: String?
    var titleOfButton: String!
    var tag: Int
    init(tag: Int) {
        self.tag = tag
        switch tag {
        case 0:
            selectedImage = "S"
            unselectedImage = "s"
            titleOfButton = "Settings"
        case 1:
            selectedImage = "B"
            unselectedImage = "b"
            titleOfButton = "Backward"
        case 2:
            selectedImage = "p"
            unselectedImage = "p"
            titleOfButton = "Pause"
        case 3:
            selectedImage = "F"
            unselectedImage = "f"
            titleOfButton = "Forward"
        case 4:
            selectedImage = "M"
            unselectedImage = "m"
            titleOfButton = "Audio & Subtitles"
        default:
            print("default")
        }
    }
    
}
