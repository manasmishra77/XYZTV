//
//  MoreLikeView.swift
//  JioCinema
//
//  Created by Shweta Adagale on 06/03/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
protocol playerMoreLikeDelegate : NSObject {
    func moreLikeTapped(newItem: Item, index: Int)
}

class MoreLikeView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var moreLikeCollectionView: UICollectionView!
    var moreArray: [Item]?
    var episodesArray: [Episode]?
    
    var appType = VideoType.None
    var isMoreDataAvailable: Bool = false
    var isEpisodeDataAvailable: Bool = false
    var isPlayList: Bool = false
    var isDisney: Bool = false
    var cureentItemId: String?
    weak var delegate: playerMoreLikeDelegate?
    var currentPlayingIndex: Int?
    
    //MARK:- Scroll Collection View To Row
    var myPreferredFocusView:UIView? = nil
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferredView = myPreferredFocusView {
            return [preferredView]
        }
        return []
    }
    
    
    func configMoreLikeView(id: String) {
            self.cureentItemId = id
            let cellNib = UINib(nibName: BaseItemCellNibIdentifier, bundle: nil)
        DispatchQueue.main.async {
            self.moreLikeCollectionView.delegate = self
            self.moreLikeCollectionView.dataSource = self
            self.moreLikeCollectionView.register(cellNib, forCellWithReuseIdentifier: BaseItemCellNibIdentifier)
            self.moreLikeCollectionView.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if moreArray?.count ?? 0 > 0 {
            isMoreDataAvailable = true
            return moreArray?.count ?? 0
        } else if episodesArray?.count ?? 0 > 0 {
            isEpisodeDataAvailable = true
            return episodesArray?.count ?? 0
        } else {
            return 0
        }
    }
    
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        super.pressesBegan(presses, with: event)
//        for press in presses {
//            switch press.type{
//            case .downArrow, .leftArrow, .upArrow, .rightArrow:
//                //resetTimer()
//                print("Arrow")
//            case .menu:
//
//                print("menu")
//            case .playPause:
//                print("playPause")
//
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
//
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseItemCellNibIdentifier, for: indexPath) as! ItemCollectionViewCell
        let cellData = getCellData(indexPath: indexPath)
//        cell.nameLabel.text = cellData.2
        cell.configureView(cellData.0, isPlayingNow: cellData.1)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = /*(appType == .Movie) ? PlayerRecommendationSize.potraitCellSize : */PlayerRecommendationSize.landscapeCellSize
        return size
    }
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return true
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 50
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            var item : Item?
        if isMoreDataAvailable {
            guard let newItem = moreArray?[indexPath.row] else{
                return
            }
            item = newItem
        }
        else if isEpisodeDataAvailable {
            guard let newItem = episodesArray?[indexPath.row] else{
                return
            }
            item = newItem.getItem
        }
        if let newItem = item {
            if cureentItemId == newItem.id {
                return
            } else {
                cureentItemId = newItem.id
            }
            delegate?.moreLikeTapped(newItem: newItem, index: indexPath.row)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
    }
    func getCellData(indexPath: IndexPath) -> (BaseItemCellModel, Bool, String) {
        let cellItems: BaseItemCellModel = BaseItemCellModel(item: nil, cellType: .player, layoutType: .landscapeWithTitleOnly, charactorItems: nil)
        if isEpisodeDataAvailable {
            let model = episodesArray?[indexPath.row]
            
            if appType == .Episode || appType == .TVShow {
                isPlayList = true
            }
            let item = model?.getItem
            let cellType: ItemCellType = isDisney ? .disneyPlayer: .player
            var layoutType: ItemCellLayoutType = .landscapeWithLabelsAlwaysShow
//            if appType == .Clip || appType == .Episode || appType == .Music || appType == .ResumeWatching || appType == .Trailer {
//                layoutType = .landscapeWithLabelsAlwaysShow
//            }
            let cellItems: BaseItemCellModel = BaseItemCellModel(item: item, cellType: cellType, layoutType: layoutType, charactorItems: nil)

            let isPlayingNow = model?.id == cureentItemId

//            if let currentIndex = self.currentPlayingIndex {
//                if indexPath.row == currentIndex && isPlayList {
//                    isPlayingNow = true
//                }
//            }

            return (cellItems, isPlayingNow, model?.name ?? "")
        } else if isMoreDataAvailable {
            let model = moreArray?[indexPath.row]
            let item = moreArray?[indexPath.row]
            let cellType: ItemCellType = isDisney ? .disneyPlayer: .player
            var layoutType: ItemCellLayoutType = .landscapeWithTitleOnly
            if appType == .Clip || appType == .Episode || appType == .Music || appType == .ResumeWatching || appType == .Trailer {
                layoutType = .landscapeWithLabelsAlwaysShow
            }
//            let layoutType: ItemCellLayoutType = /*(appType == .Movie) ? .potraitWithoutLabels : */.landscapeWithTitleOnly
            let cellItems: BaseItemCellModel = BaseItemCellModel(item: item, cellType: cellType, layoutType: layoutType, charactorItems: nil)

            let isPlayingNow = model?.id == cureentItemId

//            if let currentIndex = self.currentPlayingIndex {
//                if indexPath.row == currentIndex {
//                    isPlayingNow = true
//                }
//            }
            return (cellItems, isPlayingNow, model?.name ?? "")
        }

        return (cellItems, false, "")
    }
    
    func scrollToIndex(index:Int) {
        var previousIndex: IndexPath?
        if currentPlayingIndex != nil {
            previousIndex = IndexPath.init(row: currentPlayingIndex!, section: 0)
        }
        if previousIndex?.row == index {
            return
        }
        currentPlayingIndex = index
        DispatchQueue.main.async {
            let cellIndex = IndexPath.init(row: index, section: 0)
            var indexArray = [cellIndex]
            if previousIndex != nil {
                indexArray.append(previousIndex!)
            }
            self.moreLikeCollectionView.reloadItems(at: indexArray)
            self.moreLikeCollectionView.scrollToItem(at: cellIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            let cell = self.moreLikeCollectionView.cellForItem(at: cellIndex)
            self.myPreferredFocusView = cell
            self.setNeedsFocusUpdate()
            self.updateFocusIfNeeded()
        }
    }
    
//    func scrollCollectionViewToRow(row: Int) {
//        print("Scroll to Row is = \(row)")
//        if row >= 0, collectionView_Recommendation.numberOfItems(inSection: 0) > 0 {
//            DispatchQueue.main.async {
//                self.collectionView_Recommendation.isScrollEnabled = true
//                let path = IndexPath(row: row, section: 0)
//
//                self.collectionView_Recommendation.scrollToItem(at: path, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
//                self.collectionView_Recommendation.layoutIfNeeded()
//                let cell = self.collectionView_Recommendation.cellForItem(at: path)
//
//
//            }
//        }
//    }
    
    deinit {
        print("moreLikeView deinit called")
    }
    
}
