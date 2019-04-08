//
//  PlayerButtonsView.swift
//  JioCinema
//
//  Created by Shweta Adagale on 04/04/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class PlayerButtonsView: UIView {
    @IBOutlet var buttonHolderViewCollection: [UIView]!
    var arrayOfPlayerButtonItem : [PlayerButtonItem] = []
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
}
extension PlayerButtonsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfPlayerButtonItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCollectionViewCell", for: indexPath) as! ButtonCollectionViewCell
        cell.playerButton.setImage(UIImage(named: arrayOfPlayerButtonItem[indexPath.row].selectedImage ?? ""), for: .normal)
        cell.buttonTitle.text = arrayOfPlayerButtonItem[indexPath.row].titleOfButton
        return cell
        }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
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
            unselectedImage = "Previous"
            titleOfButton = "Previous"
        case 2:
            selectedImage = "Play"
            unselectedImage = "Pause"
            titleOfButton = "Pause"
        case 3:
            selectedImage = "next"
            unselectedImage = "next"
            titleOfButton = "Next"
        case 4:
            selectedImage = "subtitles"
            unselectedImage = "subtitlesFilled"
            titleOfButton = "Subtitles"
        default:
            print("default")
        }
    }
}
