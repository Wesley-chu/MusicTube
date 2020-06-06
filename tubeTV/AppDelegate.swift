//
//  AppDelegate.swift
//  tubeTV
//
//  Created by しゅ いりん on 2018/12/19.
//  Copyright © 2018年 ChuWeiLun. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let currentYear = Calendar.current.component(.year, from: Date())
    let currentMonth = Calendar.current.component(.month, from: Date())
    let currentDay = Calendar.current.component(.day, from: Date())
    let currentHour = Calendar.current.component(.hour, from: Date())
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //將今天日期記錄下來
        let date = UserDefaults.standard.string(forKey: "date")
        let overSix = UserDefaults.standard.string(forKey: "overSix")
        let today = "\(currentYear)\(dayToDay(day: currentMonth))\(dayToDay(day: currentDay))"
        let today_Hour = today + "\(dayToDay(day: currentHour))"
        
        //let today = "20191112"
        //let today_Hour = "2019111218"
        //如果隔一天了，將廣告播放flg歸零並重設日期
        if date != today {
            UserDefaults.standard.set(today, forKey: "date")
            UserDefaults.standard.set("0", forKey: "singer")
            UserDefaults.standard.set("0", forKey: "favorite")
            UserDefaults.standard.set("0", forKey: "overSix")
        }
        
        //如果到18點重設flg並設定18點flg為1（廣告彈出）
        if today_Hour >= today + "18"{
            if overSix != "1"{
                UserDefaults.standard.set("0", forKey: "singer")
                UserDefaults.standard.set("0", forKey: "favorite")
                UserDefaults.standard.set("1", forKey: "overSix")
            }
        }
        
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        Thread.sleep(forTimeInterval: 2.0)
        SKStoreReviewController.requestReview()
        
        VersionManager.versionUpdate(ver: "1.0")
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(UIBackgroundTaskIdentifier.invalid)
        })
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let notificationName = Notification.Name(rawValue: "checkIfForeground")
        NotificationCenter.default.post(name: notificationName, object: self, userInfo: [:])
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "tubeTV")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
//    override func remoteControlReceived(with event: UIEvent?) {
//        guard let event = event else { print("no event\n"); return }
//        switch event.subtype {
//        case UIEvent.EventSubtype.remoteControlPause:
//            print("play")
//        default:
//            break
//        }
//    }
    
    
    
    

}

