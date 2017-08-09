//
//  RJILPendingTask.swift
//  iosjiotv
//
//  Created by Kaustubh Kushte on 07/02/17.
//  Copyright © 2017 Reliance Jio Infocomm Limited . All rights reserved.
//

import UIKit

class RJILPendingTask: NSObject {
    var request:URLRequest?
    var completionHandler:RequestCompletionBlock?
}
