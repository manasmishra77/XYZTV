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
}

class BaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    var delegate: BaseTableViewCellDelegate?
    var cellItems: TableCellItemsTuple = (title: "", items: [], cellType: .base, layout: .landscapeWithTitleOnly)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureCell()
        
        //tvOS11 adjustment
        if #available(tvOS 11.0, *) {
            let collectionFrame = CGRect.init(x: itemCollectionView.frame.origin.x - 70, y: itemCollectionView.frame.origin.y, width: itemCollectionView.frame.size.width, height: itemCollectionView.frame.size.height)
            itemCollectionView.frame = collectionFrame
            
//            let labelFrame = CGRect(x: categoryTitleLabel.frame.origin.x - 70, y: categoryTitleLabel.frame.origin.y, width: categoryTitleLabel.frame.size.width, height: categoryTitleLabel.frame.size.height)
//            
//            categoryTitleLabel.frame = labelFrame
            
            
        } else {
            // or use some work around
        }
    }
    
    private func configureCell() {
        let cellNib = UINib(nibName: "ItemCollectionViewCell", bundle: nil)
        itemCollectionView.register(cellNib, forCellWithReuseIdentifier: "ItemCollectionViewCell")
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
    }
    
    func configureView(_ cellItems: TableCellItemsTuple, delegate: BaseTableViewCellDelegate) {
        self.cellItems = cellItems
        self.delegate = delegate
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
        return cellItems.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        cell.configureView((item: cellItems.items[indexPath.row], cellType: cellItems.cellType, layoutType: cellItems.layout))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapOnItemCell(self, cellItems.items[indexPath.row])
    }
}


extension BaseTableViewCell: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 30
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = ((cellItems.layout == .potrait) || (cellItems.layout == .potraitWithLabelAlwaysShow)) ? (height * widthToHeightPropertionForPotrat) + 30 : (height * widthToHeightPropertionForLandScape) + 30
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}







