//
//  favoriteView.swift
//  tubeTV
//
//  Created by しゅ いりん on 2019/7/28.
//  Copyright © 2019年 ChuWeiLun. All rights reserved.
//

import UIKit
import GoogleMobileAds

class favoriteView: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBOutlet weak var favoriteTableView: UITableView!
    @IBOutlet weak var cmView: GADBannerView!
    @IBOutlet weak var topCMView: GADBannerView!
    
    
    var favorite = [Dictionary<String, String>]()
    
    let notificationName = Notification.Name(rawValue: "favoriteRefresh")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadFavorite()
        initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favoriteToPlaySegue"{
            if let toViewController = segue.destination as? ViewController{
                toViewController.thisSongInfo = sender as? songInfo
                toViewController.isRepeat = "favorite"
                toViewController.favorite = favorite
            }
        }
    }
    
    //////////////////////////////tableview 処理/////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorite.count
    }
    
    let viewColor = UIColor(hexString: "#FFCC00")
    let checkViewColor = UIColor(hexString: "#CC9933")
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songViewCell", for: indexPath)
        guard let imageView = cell.contentView.viewWithTag(1) as? UIImageView else { return cell }
        guard let title = cell.contentView.viewWithTag(2) as? UILabel else { return cell }
        guard let channelTitle = cell.contentView.viewWithTag(3) as? UILabel else { return cell }
        guard let cellView = cell.contentView.viewWithTag(4) else { return cell }
        guard let heartButton = cell.contentView.viewWithTag(6) as? UIButton else { return cell }
        
        let row = indexPath.row
        cellView.backgroundColor = viewColor
        
        heartButton.tintColor = viewColor
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        cellView.layer.shadowOpacity = 0.5
        tableView.separatorColor = UIColor.clear
        
        //讓網路圖片下載時不會卡卡（異步處理）
        DispatchQueue.global().async {
            let data = NSData.init(contentsOf: NSURL.init(string: self.favorite[row]["imageURL"]!)! as URL)
            DispatchQueue.main.async {
                let image = UIImage.init(data: data! as Data)
                imageView.image = image
            }
        }
        
        if favorite[row]["title"]!.components(separatedBy: "_").count == 1{
            title.text = changeCode(text: favorite[row]["title"]!)
        }else{
            let Chinese = changeCode(text: favorite[row]["title"]!.components(separatedBy: "_")[0])
            let Japanese = changeCode(text: favorite[row]["title"]!.components(separatedBy: "_")[1])
            title.text = Chinese + "\n" + Japanese
        }
        channelTitle.text = changeCode(text: favorite[row]["time"]!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let like = favorite[indexPath.row]
        let data = songInfo(videoId: like["videoId"]!, title: like["title"]!, lyric: like["lyric"]!, imageURL: like["imageURL"]!, time: like["time"]!, singerId: "", singerName: "", sex_flg: "", keyinDate: "", buttonTitle: "❤️")
        performSegue(withIdentifier: "favoriteToPlaySegue", sender: data)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellView = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(4)
        
        let cellButton = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(6)
        
        cellView?.backgroundColor = checkViewColor
        cellButton?.tintColor = checkViewColor
        return true
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cellView = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(4)
        
        let cellButton = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(6)
        
        cellView?.backgroundColor = viewColor
        cellButton?.tintColor = viewColor
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favoriteData = favorite[indexPath.row]
        let delete = UITableViewRowAction(style: .normal, title: "削除") { (action, index) in
            coreDataSaveDelete(checkSaveDelete: "D", videoId: favoriteData["videoId"]!, title: "", time: "", lyric: "", imageURL: "")
            self.favorite.remove(at: indexPath.row)
            self.favoriteTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.middle)
        }
        return [delete]
    }
    
    //////////////////////////////tableview 処理/////////////////////////////////////
    
    func loadFavorite(){
        favorite.removeAll()
        var core = coreDataQuery()
        for check in core{
            var dic = [String : String]()
            dic["videoId"] = check.videoId!
            dic["title"] = check.title!
            dic["time"] = check.time!
            dic["lyric"] = check.lyric!
            dic["imageURL"] = check.imageURL!
            favorite.append(dic)
            DispatchQueue.main.async { self.favoriteTableView.reloadData() }
        }
        if core.isEmpty{ self.favoriteTableView.reloadData() }
        core.removeAll()
    }
    
    
    func initView(){
        let image = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = image
        let AD = "ca-app-pub-2739057954665163/2093015027"
        DispatchQueue.main.async {
            self.cmView.adUnitID = AD
            self.cmView.rootViewController = self
            self.cmView.load(GADRequest())
        }
        
        DispatchQueue.main.async {
            self.topCMView.adUnitID = AD
            self.topCMView.rootViewController = self
            self.topCMView.load(GADRequest())
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
