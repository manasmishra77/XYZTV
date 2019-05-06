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
    var id: String?
    weak var delegate: playerMoreLikeDelegate?
    
    func configMoreLikeView() {
        moreLikeCollectionView.delegate = self
        moreLikeCollectionView.dataSource = self
        let cellNib = UINib(nibName: BaseItemCellNibIdentifier, bundle: nil)
        moreLikeCollectionView.register(cellNib, forCellWithReuseIdentifier: BaseItemCellNibIdentifier)
        moreLikeCollectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseItemCellNibIdentifier, for: indexPath) as! ItemCollectionViewCell
        let cellData = getCellData(indexPath: indexPath)
        cell.nameLabel.text = cellData.2
        cell.configureView(cellData.0, isPlayingNow: cellData.1)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (appType == .Movie) ? PlayerRecommendationSize.potraitCellSize : PlayerRecommendationSize.landscapeCellSize
        return size
    }
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return true
    }
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
            if id == newItem.id {
                return
            }
            delegate?.moreLikeTapped(newItem: newItem, index: indexPath.row)
        }
    }
    func getCellData(indexPath: IndexPath) -> (BaseItemCellModel, Bool, String) {
        let cellItems: BaseItemCellModel = BaseItemCellModel(item: nil, cellType: .player, layoutType: .landscapeWithTitleOnly, charactorItems: nil)
        if isEpisodeDataAvailable {
            let model = episodesArray?[indexPath.row]
            
            if appType == .Episode {
                isPlayList = true
            }
            let item = model?.getItem
            let cellType: ItemCellType = isDisney ? .disneyPlayer: .player
            let layoutType: ItemCellLayoutType = .landscapeWithLabelsAlwaysShow
            let cellItems: BaseItemCellModel = BaseItemCellModel(item: item, cellType: cellType, layoutType: layoutType, charactorItems: nil)
            let isPlayingNow = model?.id == id
            return (cellItems, isPlayingNow, model?.name ?? "")
        } else if isMoreDataAvailable {
            let model = moreArray?[indexPath.row]
            let item = moreArray?[indexPath.row]
            let cellType: ItemCellType = isDisney ? .disneyPlayer: .player
            let layoutType: ItemCellLayoutType = (appType == .Movie) ? .potraitWithLabelAlwaysShow : .landscapeWithLabelsAlwaysShow
            let cellItems: BaseItemCellModel = BaseItemCellModel(item: item, cellType: cellType, layoutType: layoutType, charactorItems: nil)
            let isPlayingNow = model?.id == id
            return (cellItems, isPlayingNow, model?.name ?? "")
        }
        return (cellItems, false, "")
    }
    
    func scrollToIndex(index:Int) {
        if let cell = moreLikeCollectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as? ItemCollectionViewCell {
            cell.shouldShowIsPlaying(boolValue: false)
        }
    }
    
    
    deinit {
        print("moreLikeView deinit called")
    }
    
    
    
    
    
}
