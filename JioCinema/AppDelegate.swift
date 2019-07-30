//
//  AppDelegate.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 10/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

//http://dev.media.jio.com/apidocSit/html/#api-Appkey-Resumewatch_Add


import UIKit
import Crashlytics
import Fabric
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //var topShelfContentModel: ContentModel? //Used when topshelf image is clicked

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //Sending event for Internal Analytics
        
        Fabric.with([Crashlytics.self])
        
        Utility.sharedInstance.addIndicator()
        return true
    }

        func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if let playerVc = UIApplication.topViewController() as? PlayerViewController{
            if playerVc.viewforplayer?.player?.rate == 1 {
                playerVc.viewforplayer?.stateOfPlayerBeforeGoingInBackgroundWasPaused = false
            } else {
                playerVc.viewforplayer?.stateOfPlayerBeforeGoingInBackgroundWasPaused = true
            }
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if let playerVc = UIApplication.topViewController() as? PlayerViewController{
            if !(playerVc.viewforplayer?.stateOfPlayerBeforeGoingInBackgroundWasPaused ?? true) {
                playerVc.viewforplayer?.changePlayerPlayingStatus(shouldPlay: true)
            } else {
                playerVc.viewforplayer?.changePlayerPlayingStatus(shouldPlay: false)
            }
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        JCAnalyticsEvent.sharedInstance.sendAppLaunchEvent()
//        if let _ = topShelfContentModel{
//            if let navVc = window?.rootViewController as? UINavigationController, let tabVc = navVc.viewControllers[0] as? JCTabBarController {
//                    tabVc.selectedIndex = 0
//            }
//        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        //Sending media_end analytics event when media_ends & app_killed
        JCAnalyticsEvent.sharedInstance.sendAppKilledEvent()
        if let playerVc = UIApplication.topViewController() as? PlayerViewController{
            playerVc.viewWillDisappear(true)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlString = url.absoluteString
        
        //TODO: Top-shelf item tapped
        if urlString.contains("jCApp:?identifier="){
            if let urlSubString = urlString.dropFirst(18).removingPercentEncoding{
                //topShelfContentModel = VODTopShelfModel.getModel(urlSubString)
            }
        }
        if urlString.contains("jCApp:?contentId="){
            var tappeditem = Item()
            if let url = URL(string: urlString){
            let urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: true)
                
            //Don't change the sequence (Very confidential)
            let queryItems = urlComponent?.queryItems
                tappeditem.id = queryItems?[0].value
                tappeditem.latestId = queryItems?[1].value
                tappeditem.isPlaylist = Bool(queryItems?[2].value ?? "false")
                tappeditem.playlistId = queryItems?[3].value
                var appType = App()
                appType.type = Int(queryItems?[4].value ?? "0")
                tappeditem.app = appType

                
            }
        }
        return false
    }
    
    func handlerUncaughtException() -> Void {
        
        NSSetUncaughtExceptionHandler { (exception) in
            Log.DLog(message: Thread.callStackSymbols as AnyObject)
        }
        signal(SIGABRT) { (_) in
            Log.DLog(message: Thread.callStackSymbols as AnyObject)
        }
        signal(SIGILL) { (_) in
            Log.DLog(message: Thread.callStackSymbols as AnyObject)
        }
        
        signal(SIGSEGV) { (_) in
            Log.DLog(message: Thread.callStackSymbols as AnyObject)
        }
        signal(SIGFPE) { (_) in
            Log.DLog(message: Thread.callStackSymbols as AnyObject)
        }
        signal(SIGBUS) { (_) in
            Log.DLog(message: Thread.callStackSymbols as AnyObject)
        }
        signal(SIGPIPE) { (_) in
            Log.DLog(message: Thread.callStackSymbols as AnyObject)
        }
    }
    
}

