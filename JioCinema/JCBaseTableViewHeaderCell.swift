//
//  JCBaseTableViewHeaderCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 27/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class JCBaseTableViewHeaderCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {

    let verticalInset = CGFloat(10)
    let spaceBetweenCells = CGFloat(40)
    let minimumLineSpacing = CGFloat(60)
    var horizontalInset = CGFloat()
    var cellWidth = CGFloat()
    var carousalData:[Item]?
    var itemFromViewController:VideoType?

    
    @IBOutlet weak var headerCollectionView: UICollectionView!
    let carouselCellIdentifier = "kBaseCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headerCollectionView.register(UINib.init(nibName: "JCCarouselCell", bundle: nil), forCellWithReuseIdentifier: carouselCellIdentifier)
        self.headerCollectionView.delegate = self
        self.headerCollectionView.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(carousalData != nil)
        {
            return (carousalData?.count)!
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: carouselCellIdentifier, for: indexPath) as! JCCarouselCell
        
        let imageUrl = (carousalData?[indexPath.row].tvImage)!
        let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
        cell.carouselImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "carousel_placeholder-min.png"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
            (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
        })
        
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionIndex = collectionView.tag
        selectedItemFromViewController = self.itemFromViewController!
        
        let itemToPlay = ["item":(carousalData?[indexPath.row])!]
        NotificationCenter.default.post(name: cellTapNotificationName, object: nil, userInfo: itemToPlay)
    }
    
    
}


