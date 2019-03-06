//
//  MoreLikeView.swift
//  JioCinema
//
//  Created by Shweta Adagale on 06/03/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class MoreLikeView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var moreLikeCollectionView: UICollectionView!
    
    func configMoreLikeView() {
        moreLikeCollectionView.delegate = self
        moreLikeCollectionView.dataSource = self
        let cellNib = UINib(nibName: BaseItemCellNibIdentifier, bundle: nil)
        moreLikeCollectionView.register(cellNib, forCellWithReuseIdentifier: BaseItemCellNibIdentifier)
        moreLikeCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseItemCellNibIdentifier, for: indexPath) as! ItemCollectionViewCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 300, height: 500)
        return size
    }
    
    

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
