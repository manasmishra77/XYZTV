//
//  JCBaseTableViewCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCBaseTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var tableCellCollectionView: UICollectionView!
    var data:[Item]?
    let itemCellIdentifier = "kJCItemCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableCellCollectionView.delegate = self
        tableCellCollectionView.dataSource = self
        self.tableCellCollectionView.register(UINib.init(nibName: "JCItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier)
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = data?.count
        {
            return count
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        
        if(data?[indexPath.row].banner != nil)
        {
            let imageUrl = data?[indexPath.row].banner!
            
            if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            {
                cell.itemImageView.image = image;
            }
            else
            {
                self.downloadImageFrom(urlString: imageUrl!, indexPath: indexPath)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let itemToPlay = ["item":(data?[indexPath.row])!]
        NotificationCenter.default.post(name: cellTapNotificationName, object: nil, userInfo: itemToPlay)
    }
    
    fileprivate func downloadImageFrom(urlString:String,indexPath:IndexPath)
    {
        
        weak var weakSelf = self
        
        let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(urlString)
        RJILImageDownloader.shared.downloadImage(urlString: imageUrl!, shouldCache: true){
            
            image in
            
            if let img = image {
                
                DispatchQueue.main.async {
                    
                    if let cell = weakSelf?.tableCellCollectionView?.cellForItem(at: indexPath){
                        
                        let itemCell = cell as! JCItemCell
                        itemCell.itemImageView.image = img
                    }
                }
            }
        }
    }
    
}
