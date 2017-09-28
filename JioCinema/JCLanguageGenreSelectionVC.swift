//
//  JCLanguageGenreSelectionVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 03/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//
import UIKit

protocol JCLanguageGenreSelectionDelegate : class
{
    func selectedFilter(filter:Int)
}

class JCLanguageGenreSelectionVC: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    @IBOutlet weak var selectionVCHeaderLabel: UILabel!
    var dataSource:[List]?
    weak var languageSelectionDelegate:JCLanguageGenreSelectionDelegate?
    @IBOutlet weak var languageGenreSelctionTableView: UITableView!
    var textForHeader:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        selectionVCHeaderLabel.text = textForHeader
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if dataSource?.count != nil
        {
            return (dataSource?.count)!
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: languageGenreSelectionCellIdentifier, for: indexPath) as! JCLanguageGenreSelectionPrototypeCell
        cell.titleLabel.text = dataSource![indexPath.row].name!
        cell.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4352941176, blue: 0.4352941176, alpha: 1)
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        languageSelectionDelegate?.selectedFilter(filter: indexPath.row)
        self.dismiss(animated: false, completion: nil)
    }
    
    
}

class JCLanguageGenreSelectionPrototypeCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if context.nextFocusedView == self
        {
            self.backgroundColor = UIColor.white
            self.titleLabel.textColor = #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1)
            //self.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1)
            self.layer.cornerRadius = 10
            self.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        }
        else
        {
            //self.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4352941176, blue: 0.4352941176, alpha: 1)
            self.titleLabel.textColor = UIColor.white
            self.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4352941176, blue: 0.4352941176, alpha: 1)
            self.layer.cornerRadius = 10
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
}
