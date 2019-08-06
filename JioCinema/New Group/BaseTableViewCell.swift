//
//  BaseTableViewCell.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol BaseTableViewCellDelegate {
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item)
    func didTapOnCharacterItem(_ baseCell: BaseTableViewCell?, _ charItem: DisneyCharacterItems)
    func setHeaderValues(urlString: String?, title: String, description: String, toFullScreen: Bool)
}
extension BaseTableViewCellDelegate {
    func setHeaderValues(urlString: String?, title: String, description: String, toFullScreen: Bool) {
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
    var delegate: BaseTableViewCellDelegate?
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseItemCellNibIdentifier, for: indexPath) as! ItemCollectionViewCell
        let baseItemCellModel : BaseItemCellModel = BaseItemCellModel(item: cellItems.items?[indexPath.row], cellType: cellItems.cellType, layoutType: cellItems.layoutType, charactorItems: cellItems.charItems?[indexPath.row])
        cell.configureView(baseItemCellModel)
        return cell
    }
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
            delegate?.setHeaderValues(urlString: newItem.imageUrlOfTvStillImage, title: newItem.name ?? newItem.showname ?? "", description: newItem.description ?? "", toFullScreen: false)
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
            height = itemHeightForLandscape
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
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}
