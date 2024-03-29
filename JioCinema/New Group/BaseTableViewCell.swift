//
//  BaseTableViewCell.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol BaseTableViewCellDelegate: NSObject {
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item)
    func didTapOnCharacterItem(_ baseCell: BaseTableViewCell?, _ charItem: DisneyCharacterItems)
    func setHeaderValues(focusedItem: UIView?,urlString: String?, title: String, subtitle: String?, maturityRating: String?, description: String, toFullScreen: Bool, mode: UIImageView.ContentMode, currentItem: Item?)
}
extension BaseTableViewCellDelegate {
    func setHeaderValues(focusedItem: UIView?,urlString: String?, title: String, subtitle: String?, maturityRating: String?, description: String, toFullScreen: Bool, mode: UIImageView.ContentMode, currentItem: Item?) {
    }
}
//To be used in place of TableCellItemsTuple Tuple
struct BaseTableCellModel {
    var title: String!
    var items: [Item]?
    var cellType: ItemCellType!
    var layoutType: ItemCellLayoutType!
    var sectionLanguage: AudioLanguage!
    var charItems: [DisneyCharacterItems]?
    
    init(title: String, items: [Item]?, cellType: ItemCellType = .base, layoutType: ItemCellLayoutType = .landscapeWithLabels, sectionLanguage: AudioLanguage = .english, charItems : [DisneyCharacterItems]?) {
        self.title = title
        self.items = items
        self.cellType = cellType
        self.layoutType = layoutType
        self.sectionLanguage = sectionLanguage
        self.charItems = charItems
    }
}

class BaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    weak var delegate: BaseTableViewCellDelegate?
    var cellItems: BaseTableCellModel = BaseTableCellModel(title: "", items: nil, cellType: .base, layoutType: .landscapeWithTitleOnly , sectionLanguage: .english , charItems: nil)

    
    //audio lang from category
    var defaultAudioLanguage: AudioLanguage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureCell()
        
        //tvOS11 adjustment
        if #available(tvOS 11.0, *) {
            let collectionFrame = CGRect.init(x: itemCollectionView.frame.origin.x - 70, y: itemCollectionView.frame.origin.y, width: itemCollectionView.frame.size.width, height: itemCollectionView.frame.size.height)
            itemCollectionView.frame = collectionFrame
        } else {
            // or use some work around
        }
    }
    
    private func configureCell() {
        let cellNib = UINib(nibName: BaseItemCellNibIdentifier, bundle: nil)
        itemCollectionView.register(cellNib, forCellWithReuseIdentifier: BaseItemCellNibIdentifier)
        itemCollectionView.register(UINib(nibName: "TvPosterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "posterCell")
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
    }
    
    func configureView(_ cellItems: BaseTableCellModel, delegate: BaseTableViewCellDelegate) {
        self.cellItems = cellItems
        self.delegate = delegate
        self.defaultAudioLanguage = cellItems.sectionLanguage
        self.categoryTitleLabel.text = cellItems.title
        self.itemCollectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
//        DispatchQueue.main.async {
//            self.itemCollectionView.contentOffset = CGPoint.init(x: 0, y: 0)
//        }
    }
}

extension BaseTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if cellItems.charItems != nil {
            return cellItems.charItems?.count ?? 0
        }
        return cellItems.items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if #available(tvOS 12.1, *) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath) as! TvPosterCollectionViewCell
            let baseItemCellModel : BaseItemCellModel = BaseItemCellModel(item: cellItems.items?[indexPath.row], cellType: cellItems.cellType, layoutType: cellItems.layoutType, charactorItems: cellItems.charItems?[indexPath.row])
            cell.configureCell(baseItemCellModel)
            return cell
        } else {
            // Fallback on earlier versions
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseItemCellNibIdentifier, for: indexPath) as! ItemCollectionViewCell
            let baseItemCellModel : BaseItemCellModel = BaseItemCellModel(item: cellItems.items?[indexPath.row], cellType: cellItems.cellType, layoutType: cellItems.layoutType, charactorItems: cellItems.charItems?[indexPath.row])
            cell.configureView(baseItemCellModel)
            return cell
        }
    }//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseItemCellNibIdentifier, for: indexPath) as! ItemCollectionViewCell
    //        let baseItemCellModel : BaseItemCellModel = BaseItemCellModel(item: cellItems.items?[indexPath.row], cellType: cellItems.cellType, layoutType: cellItems.layoutType, charactorItems: cellItems.charItems?[indexPath.row])
    //        cell.configureView(baseItemCellModel)
    //        return cell

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = cellItems.items {
            var newItem = item[indexPath.row]
            newItem.setDefaultAudioLanguage(defaultAudioLanguage)
            delegate?.didTapOnItemCell(self, newItem)
        }
        if let item = cellItems.charItems {
            let newCharItem = item[indexPath.row]
            delegate?.didTapOnCharacterItem(self, newCharItem)
            //disney character click to be handled
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let item = cellItems.items {
            let newItem = item[context.nextFocusedIndexPath?.row ?? 0]
            if context.nextFocusedItem is ItemCell/*ItemCollectionViewCell*/ {
                delegate?.setHeaderValues(focusedItem: self, urlString: newItem.imageUrlOfTvStillImage, title: newItem.name ?? newItem.showname ?? "", subtitle: newItem.subtitle, maturityRating: newItem.maturityRating, description: newItem.description ?? "", toFullScreen: false, mode: .scaleAspectFill, currentItem: newItem)
            }
        } else if let charItem = cellItems.charItems {
            let newItem = charItem[context.nextFocusedIndexPath?.row ?? 0]
            if context.nextFocusedItem is ItemCell/*ItemCollectionViewCell*/ {
                delegate?.setHeaderValues(focusedItem: self, urlString: newItem.LogoUrlForDisneyChar, title: newItem.name ?? "", subtitle: nil, maturityRating: nil, description: "", toFullScreen: false, mode: .scaleAspectFit, currentItem: nil)
            }
        }
    }
}


extension BaseTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = collectionView.frame.height
        if cellItems.layoutType == .disneyCharacter {
            height = itemHeightForPortrait
        } else if cellItems.layoutType == .landscapeForLangGenre {
            height = itemHeightForLandscapeForTitleOnly
        } else if cellItems.layoutType == .landscapeWithTitleOnly{
            height = itemHeightForLandscapeForTitleOnly
        } else {
            height = itemHeightForLandscapeForTitleAndSubtitle
        }
//        let width = ((cellItems.layoutType == .potrait) || (cellItems.layoutType == .potraitWithLabelAlwaysShow) || (cellItems.layoutType == .disneyCharacter)) ? itemWidthForPortrait : itemWidthForLadscape
        let width = (cellItems.layoutType == .disneyCharacter) ? itemWidthForPortrait : itemWidthForLadscape
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
