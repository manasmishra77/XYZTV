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
    
    @IBOutlet weak var itemCollectionView: UICollectionView!
    var delegate: BaseTableViewCellDelegate?
    var cellItems: TableCellItemsTuple = (title: "", items: [], cellType: .base)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureCell()
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
        self.itemCollectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension BaseTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellItems.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        cell.configureView((item: cellItems.items[indexPath.row], cellType: cellItems.cellType))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapOnItemCell(self, cellItems.items[indexPath.row])
    }
}








