//
//  JCBaseTableViewHeaderCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 27/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCBaseTableViewHeaderCell: UITableViewCell,UICollectionViewDataSource {

    let verticalInset = CGFloat(10)
    let spaceBetweenCells = CGFloat(40)
    let minimumLineSpacing = CGFloat(60)
    var horizontalInset = CGFloat()
    var cellWidth = CGFloat()
    var carousalData:[Item]?
    
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
        
        if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
        {
            cell.carouselImageView.image = image;
        }
        else
        {
            self.downloadImageFrom(urlString: imageUrl, indexPath: indexPath)
        }
        
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let itemToPlay = ["item":(carousalData?[indexPath.row])!]
        NotificationCenter.default.post(name: cellTapNotificationName, object: nil, userInfo: itemToPlay)
    }
    
    fileprivate func downloadImageFrom(urlString:String,indexPath:IndexPath){
        
        weak var weakSelf = self
        
        let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(urlString)
        RJILImageDownloader.shared.downloadImage(urlString: imageUrl!, shouldCache: true){
            
            image in
            
            if let img = image {
                
                DispatchQueue.main.async {
                    
                    if let cell = weakSelf?.headerCollectionView?.cellForItem(at: indexPath){
                        
                        let carouselCell = cell as! JCCarouselCell
                        carouselCell.carouselImageView.image = img
                    }
                }
            }
        }
    }
    
}

extension JCBaseTableViewHeaderCell: UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        self.cellWidth = self.headerCollectionView.frame.width - (spaceBetweenCells * 2) - 80
        return CGSize(width: self.cellWidth, height: self.headerCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

