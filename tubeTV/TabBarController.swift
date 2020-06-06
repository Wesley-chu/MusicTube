//
//  TabBarController.swift
//  tubeTV
//
//  Created by しゅ いりん on 2019/7/28.
//  Copyright © 2019年 ChuWeiLun. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TabBarController: UITabBarController,GADInterstitialDelegate {
    
    var interstitial: GADInterstitial?
    var key_favorite = ""
    var key_singer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item.tag)
        guard let singer = UserDefaults.standard.string(forKey: "singer") else { return }
        guard let favorite = UserDefaults.standard.string(forKey: "favorite")else{ return }
        key_singer = singer
        key_favorite = favorite
        if item.tag == 2{
            let notificationName = Notification.Name(rawValue: "favoriteRefresh")
            NotificationCenter.default.post(name: notificationName, object: self, userInfo: [:])
            
            if key_favorite != "1"{
                interstitial = createAndLoadInterstitial()
                UserDefaults.standard.set("1", forKey: "favorite")
            }
            
        }else if item.tag == 1{
            let notificationName = Notification.Name(rawValue: "singerRefresh")
            NotificationCenter.default.post(name: notificationName, object: self, userInfo: [:])
            
            if key_singer != "1"{
                interstitial = createAndLoadInterstitial()
                UserDefaults.standard.set("1", forKey: "singer")
            }
            
        }
    }
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2739057954665163/7108401852")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial loaded successfully")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
