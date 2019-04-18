//
//  PlayerButtonsView.swift
//  JioCinema
//
//  Created by Shweta Adagale on 04/04/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
protocol ButtonPressedDelegate: NSObject{
    func playTapped(toPlay: Bool)
    func subtitlesAndMultiaudioButtonPressed(todisplay: Bool)
    func settingsButtonPressed(toDisplay: Bool)
    func nextButtonPressed(toDisplay: Bool)
    func previousButtonPressed(toDisplay: Bool)
}

class PlayerButtonsView: UIView {
    @IBOutlet var buttonHolderViewCollection: [UIView]!
    var arrayOfPlayerButtonItem : [PlayerButtonItem] = []
    var ispaused: Bool = false
    weak var buttonDelegate: ButtonPressedDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    func configurePlayerButtonsView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ButtonCollectionViewCell")
        appendArray()
    }
    
    func appendArray() {
        for tag in 0...4{
            let item = PlayerButtonItem(tag: tag)
            arrayOfPlayerButtonItem.append(item)
        }
    }
    deinit {
        print("PLayerButtonsView deinit called")
    }
}
extension PlayerButtonsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfPlayerButtonItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCollectionViewCell", for: indexPath) as! ButtonCollectionViewCell
        cell.configCellView(item: arrayOfPlayerButtonItem[indexPath.row])
        return cell
        }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ButtonCollectionViewCell
        switch indexPath.row {
        case 0:
            buttonDelegate?.settingsButtonPressed(toDisplay: true)
        case 1:
            buttonDelegate?.previousButtonPressed(toDisplay: true)
        case 2:
            ispaused = !ispaused
            if ispaused{
                cell.playerButton.setImage(UIImage(named: "play"), for: .normal)
                cell.buttonTitle.text = "Play"
                buttonDelegate?.playTapped(toPlay: false)
            } else{
                cell.playerButton.setImage(UIImage(named: "Pause"), for: .normal)
                cell.buttonTitle.text = "Pause"
                buttonDelegate?.playTapped(toPlay: true)
            }
        case 3:
            buttonDelegate?.nextButtonPressed(toDisplay: true)
        case 4:
            buttonDelegate?.subtitlesAndMultiaudioButtonPressed(todisplay: true)
        default:
            print("default")
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 || indexPath.row == arrayOfPlayerButtonItem.count - 1{
            return CGSize(width: 348, height: self.collectionView.frame.height)
        } else {
            return CGSize(width: 200, height: self.collectionView.frame.height)
        }
    }
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        return true
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//
//    }
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
            selectedImage = "playerSettingsFilled"
            unselectedImage = "playerSettings"
            titleOfButton = "Settings"
        case 1:
            selectedImage = "PreviousFilled"
            unselectedImage = "previous"
            titleOfButton = "Previous"
        case 2:
            selectedImage = "Pause"
            unselectedImage = "Pause"
            titleOfButton = "Pause"
        case 3:
            selectedImage = "nextFilled"
            unselectedImage = "next"
            titleOfButton = "Next"
        case 4:
            selectedImage = "subtitlesFilled"
            unselectedImage = "subtitles"
            titleOfButton = "Subtitles"
        default:
            print("default")
        }
    }

}
