//
//  JCTrendingSearchResultViewModel.swift
//  JioCinema
//
//  Created by manas on 24/05/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import UIKit

class JCTrendingSearchResultViewModel: NSObject {
    
    var searchTextsModelArray: [PopularSearches]?
    let view: JCSearchVC
    
    init(_ view: JCSearchVC) {
        self.view = view
        super.init()
        self.view.searchRecommendationTableView.delegate = self
        self.view.searchRecommendationTableView.dataSource = self
    }
    
    func callWebServiceForTrendingResult() {
        let url = TrendingSearchTextURL
        let request = RJILApiManager.defaultManager.prepareRequest(path: url, params: nil, encoding: .URL)
        RJILApiManager.defaultManager.get(request: request) {[unowned self] (data, response, error) in
            if let error = error as NSError? {
                print(error)
                return
            }
            let searchSuperModel = RJILApiManager.parseData(data, modelType: JCTrendingSearchTextSuperModel.self)
            if let searchRecommTexts = searchSuperModel?.data?["popularSearches"] {
                self.updateTableView(searchRecommTexts)
            }
        }
    }
    func updateTableView(_ models: [PopularSearches]) {
        searchTextsModelArray = models
        DispatchQueue.main.async {
            self.tuggleSearchViewsAndSearchRecommViews(toShowSearchRecommView: true)
            self.view.searchRecommendationTableView.reloadData()
            self.view.seaarchRecommendationLabel.text = "Trending Search Result"
        }
    }
    
    func tuggleSearchViewsAndSearchRecommViews(toShowSearchRecommView: Bool) {
        if toShowSearchRecommView {
            if searchTextsModelArray == nil {
                callWebServiceForTrendingResult()
            } else {
                view.searchRecommendationTableView.reloadData()
            }
        }
        view.baseTableView.isHidden = toShowSearchRecommView
        view.searchRecommendationContainerView.isHidden = !toShowSearchRecommView
    }
}

extension JCTrendingSearchResultViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTextsModelArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = view.searchRecommendationTableView.dequeueReusableCell(withIdentifier: SearchRecommendationCellIdentifier, for: indexPath) as! JCSearchRecommendationTableViewCell
        cell.textLabel?.text = searchTextsModelArray?[indexPath.row].key
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchItem = searchTextsModelArray?[indexPath.row].key
        view.searchResultForkey(with: searchItem ?? "")
        view.searchViewController?.searchBar.text = searchItem ?? ""
    }
}

