//
//  CharHeroViewController.swift
//  JioCinema
//
//  Created by Shweta Adagale on 15/02/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class CharHeroViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var characterLogo: UIImageView!
    @IBOutlet weak var charTableView: UITableView!
    @IBOutlet weak var characterName: UILabel!
    
    //Details required to fetch and display data
    var charLogo: String?
    var charName: String?
    var id: String?
    
    var disneyCharViewModel : DisneyCharacterViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        charTableView.dataSource = self
        charTableView.delegate = self
        configureView()
        // Do any additional setup after loading the view.
    }
    func configureView(){
        let cellNib = UINib(nibName: BaseTableCellNibIdentifier, bundle: nil)
        charTableView.register(cellNib, forCellReuseIdentifier: BaseTableCellNibIdentifier)
        disneyCharViewModel = DisneyCharacterViewModel()
            disneyCharViewModel?.callWebserviceForCharacterHeros(id: id)
            disneyCharViewModel?.delegate = self

        if let urlString = charLogo{
            let url = URL(string: urlString)
            characterLogo.sd_setImage(with: url)
        }
        characterName.text = charName
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return disneyCharViewModel?.countOfItems() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = charTableView.dequeueReusableCell(withIdentifier: BaseTableCellNibIdentifier, for: indexPath) as? BaseTableViewCell else {
            return UITableViewCell()
        }
        if let cellData = disneyCharViewModel?.getCellData(indexpath: indexPath){
            cell.configureView(cellData, delegate: self)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return disneyCharViewModel?.heightOfRowAt(indexpath: indexPath) ?? 0
    }
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension CharHeroViewController : BaseViewModelDelegate, DisneyCharacterTableReloadDelegate{
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: false, completion: nil)
    }
    
    func presentMetadataOfIcarousel(_ itemId: Any) {
        return
    }
    
    func tableReloadWhenDataFetched() {
        if let tableView = self.charTableView {
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }
}
extension CharHeroViewController : BaseTableViewCellDelegate {
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item) {
        let selectedIndexPath: IndexPath? = (baseCell != nil) ? self.charTableView.indexPath(for: baseCell!) : nil
        disneyCharViewModel.presentVCdelegate = self
        disneyCharViewModel.itemCellTapped(selectedIndexPath?.row ?? 0, item)        
    }
    
    func didTapOnCharacterItem(_ baseCell: BaseTableViewCell?, _ charItem: DisneyCharacterItems) {
        return
    }
    
    
}
