//
//  CharHeroViewController.swift
//  JioCinema
//
//  Created by Shweta Adagale on 15/02/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class CharHeroViewController: UIViewController {

    @IBOutlet weak var characterLogo: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var charItem : DisneyCharacterItems?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }
    func configureView(){
        if let urlString = charItem?.LogoUrlForDisneyChar{
            let url = URL(string: urlString)
            characterLogo.sd_setImage(with: url)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
