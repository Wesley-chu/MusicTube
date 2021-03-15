//
//  songViewList.swift
//  tubeTV
//
//  Created by しゅ いりん on 2019/6/3.
//  Copyright © 2019年 ChuWeiLun. All rights reserved.
//

import UIKit
import CloudKit
import GoogleMobileAds

class songViewList: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var songTableView: UITableView!
    
    var songData = [songInfo]()
    
    var calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: -15, to: Date())
    
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var headCMView1: GADBannerView!
    @IBOutlet weak var headCMView2: GADBannerView!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var CMView1: GADBannerView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        initView()
        
    }
    /*debug
    func update(videoId:String,sentence:String,flg:String){
        let database = CKContainer(identifier: "iCloud.CHUWEILUN1.tubeTV").publicCloudDatabase
        var query:CKQuery?
        
        if flg == "S"{ query = CKQuery(recordType: "songInfo", predicate: NSPredicate(value: true)) }
        else if flg == "female" { query = CKQuery(recordType: "femaleSinger", predicate: NSPredicate(value: true)) }
        else if flg == "male" { query = CKQuery(recordType: "maleSinger", predicate: NSPredicate(value: true)) }
        else if flg == "group" { query = CKQuery(recordType: "groupSinger", predicate: NSPredicate(value: true)) }
        else { query = CKQuery(recordType: "modifyInfo", predicate: NSPredicate(value: true)) }
        
        
        let operation = CKQueryOperation(query: query!)
        operation.queuePriority = .veryHigh; operation.resultsLimit = 300
        operation.recordFetchedBlock = {(records:CKRecord?) in
            guard let record = records else { return }
            if record["videoId"] as! String == videoId{
                record["sentence"] = sentence as CKRecordValue
                //print(record["title"] as! String)
                database.save(record, completionHandler: { (_, _) in })
            }
        }; database.add(operation)
    }
    
    func insertToProductionCore(){
        var aa = 0
        for check in coreDataQuery(){
            //print(check.title)
            update(videoId: check.videoId!, sentence: check.sentence!, flg: "m")
        }
    }
    debug*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageDisplay()
        
        loadSongFromRecent()
        //insertToProductionCore()   //debug
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlaySegue"{
            if let toViewController = segue.destination as? ViewController{
                toViewController.thisSongInfo = sender as? songInfo
                toViewController.isRepeat = "top"
            }
        }
    }
    
    //////////////////////////////tableview 処理/////////////////////////////////////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    let viewColor = UIColor(hexString: "#FFCC00")
    let checkViewColor = UIColor(hexString: "#CC9933")
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "songViewCell", for: indexPath)
        guard let imageView = cell.contentView.viewWithTag(1) as? UIImageView else { return cell }
        guard let title = cell.contentView.viewWithTag(2) as? UILabel else { return cell }
        guard let channelTitle = cell.contentView.viewWithTag(3) as? UILabel else { return cell }
        guard let cellView = cell.contentView.viewWithTag(4) else { return cell }
        
        cellView.backgroundColor = viewColor
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        
        cellView.layer.shadowOpacity = 0.5
        tableView.separatorColor = UIColor.clear
        
        //讓網路圖片下載時不會卡卡（異步處理）
        DispatchQueue.global().async {
            let data = NSData.init(contentsOf: NSURL.init(string: self.songData[row].imageURL!)! as URL)
            DispatchQueue.main.async {
                let image = UIImage.init(data: data! as Data)
                imageView.image = image
            }
        }
        
        if songData[row].title!.components(separatedBy: "_").count == 1{
            title.text = changeCode(text: songData[row].title!)
        }else{
            let Chinese = songData[row].title!.components(separatedBy: "_")[0]
            let Japanese = songData[row].title!.components(separatedBy: "_")[1]
            title.text = Chinese + "\n" + Japanese
        }
        channelTitle.text = changeCode(text: songData[row].time!)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toPlaySegue", sender: songData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellView = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(4)
        cellView?.backgroundColor = checkViewColor
        return true
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cellView = tableView.cellForRow(at: indexPath)?.contentView.viewWithTag(4)
        cellView?.backgroundColor = viewColor
    }
    
    //////////////////////////////tableview 処理/////////////////////////////////////

    
    var timer:Timer?
    func messageDisplay(){
        let arr = ["ハートを押したらお気に入りに追加できる\nもう一回押すとキャンセルできるよ",
                   "曲をスピードアップしてもいいし\nスピードダウンしてもいいよ",
                   "アプリに入ってない興味のある曲があれば\n是非ご連絡下さい",
                   "⚪️🔵を押したら動画も飛んで行く",
                   "お気に入り削除方法その一：\n歌手のハートをもう一度押してみよう",
                   "お気に入り削除方法その二：\nお気に入りのデータを左に滑らせてみよう"]
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { (Timer) in
            let num = Int(arc4random_uniform(UInt32(arr.count)))
            self.messageLabel.text = arr[num]
        })
    }
    
    func initView(){
        let image = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = image
        
        messageView.layer.shadowOpacity = 0.5
        let AD = "ca-app-pub-2739057954665163/2093015027"
        let request = GADRequest()
        
        DispatchQueue.main.async {
            self.headCMView1.adUnitID = AD
            self.headCMView1.rootViewController = self
            self.headCMView1.load(request)
            self.CMView1.adUnitID = AD
            self.CMView1.rootViewController = self
            self.CMView1.load(request)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadSongFromRecent(){
        let database = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "songInfo", predicate: NSPredicate(value: true))
        //ascending: false -> 新から旧
        query.sortDescriptors = [NSSortDescriptor(key: "keyinDate", ascending: false)]
        let operation = CKQueryOperation(query: query)
        operation.queuePriority = .veryHigh; operation.resultsLimit = 10
        operation.recordFetchedBlock = {(records:CKRecord?) in
            guard let record = records else { return }
            var sentence = ""
            if record["sentence"] != nil { sentence = record["sentence"] as! String }
            let data = songInfo(videoId: record["videoId"] as! String, title: record["title"] as! String, lyric: record["lyric"] as! String, imageURL: record["imageURL"] as! String, time: record["time"] as! String, singerId: record["singerId"] as! String, singerName: record["singerName"] as! String, sex_flg: record["sex_flg"] as! String, keyinDate: record["keyinDate"] as! String, buttonTitle: "", sentence: sentence)
            self.songData.append(data)
            
            DispatchQueue.main.async {
                self.songTableView.reloadData()
            }
            
        }
        database.add(operation)
    }
    
    
    func deveToCoredata(){
        
        
        
        
        
    }
    
    
    
    
    
}
