//
//  ResumeWatchView.swift
//  JioCinema
//
//  Created by Shweta Adagale on 16/04/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
protocol ResumeWatchDelegate: NSObject {
    func resumeWatchingPressed()
    func startFromBeginning()
    func removeFromResumeWatchingPressed()
}

class ResumeWatchView: UIView {
    weak var delegate: ResumeWatchDelegate?
    override func awakeFromNib() {
        print("__")
    }

    @IBAction func resumeWatchingPressed(_ sender: Any) {
        delegate?.resumeWatchingPressed()
    }
    @IBAction func startFromBeginning(_ sender: Any) {
        delegate?.startFromBeginning()
    }
    @IBAction func removeFromResumeWatchingPressed(_ sender: Any) {
        delegate?.removeFromResumeWatchingPressed()
    }
    deinit {
        print("Resume Watch deinit called")
    }
}
