//
//  singerView.swift
//  tubeTV
//
//  Created by しゅ いりん on 2019/7/15.
//  Copyright © 2019年 ChuWeiLun. All rights reserved.
//
import UIKit
import GoogleMobileAds
import CloudKit

class singerView: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var songTableView: UITableView!
    @IBOutlet weak var girlSingerButton: UIButton!
    @IBOutlet weak var groupSingerButton: UIButton!
    @IBOutlet weak var boySingerButton: UIButton!
    
    @IBOutlet weak var cmView: GADBannerView!
    
    let buttonColor = UIColor.white
    let buttonCheckedColor = UIColor(hexString: "#FFCC00")
    
    //每一首最愛曲
    var favorite = [Dictionary<String, String>]()
    
    //section的標題
    var songSectionTitle = [String]()
    //每一組代表不同歌手的歌組
    var songSectionSet = [[songInfo]]()
    //按鈕確認
    var songButton = [String]()
    
    let notificationName = Notification.Name(rawValue: "singerRefresh")
    
    override func viewWillAppear(_ animated: Bool) {
        if sex_flg == 0{ initView(button: "girl") }
        else if sex_flg == 1{ initView(button: "boy") }
        else if sex_flg == 2{ initView(button: "group") }
        
        var arr = [Dictionary<String, String>]()
        for check in coreDataQuery(){
            //add sentence 20201020
            var sentence = ""
            if check.sentence != nil{ sentence = check.sentence! }
            var dic = [String : String]()
            dic["videoId"] = check.videoId!
            dic["title"] = check.title!
            dic["time"] = check.time!
            dic["lyric"] = check.lyric!
            dic["imageURL"] = check.imageURL!
            //add sentence 20201020
            dic["sentence"] = sentence
            arr.append(dic)
        }
        
        //1.如果原先讀取的我的最愛有變動就會不相等＆2.我的最愛頁刪除後，歌手頁也要更新
        if favorite.count != arr.count {
            favorite.removeAll()
            favorite = arr
            loadSingerSong(conds: "\(sex_flg)")
        }; arr.removeAll()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readCoreData()
        loadSingerSong(conds: "\(sex_flg)")
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "singerToPlaySegue"{
            if let toViewController = segue.destination as? ViewController{
                toViewController.thisSongInfo = sender as? songInfo
                toViewController.favorite = favorite
            }
        }
    }
    
    var sex_flg = 0
    @IBAction func button(_ sender: UIButton) {
        activityIndicatorView(flg: "start")
        switch sender {
        case girlSingerButton:
            initView(button: "girl")
            readCoreData()
            loadSingerSong(conds: "0"); sex_flg = 0
        case boySingerButton:
            initView(button: "boy")
            readCoreData()
            loadSingerSong(conds: "1"); sex_flg = 1
        default:
            initView(button: "group")
            readCoreData()
            loadSingerSong(conds: "2"); sex_flg = 2
        }
    }
    
    //////////////////////////////tableview 処理/////////////////////////////////////
    @objc func click(button:UIButton){
        if songButton[button.tag] == "0"{
            songButton[button.tag] = "1"
            songTableView.reloadData()
        }else{
            songButton[button.tag] = "0"
            songTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let aView = UIView()
        aView.frame = CGRect(x: 5, y: 0, width: 100, height: 34)
        aView.backgroundColor = UIColor.clear
        
        let aButton = UIButton()
        aButton.frame = aView.frame
        aButton.tag = section
        aButton.addTarget(self, action: #selector(click(button:)), for: UIControl.Event.touchUpInside)
        
        let aLabel = UILabel()
        if songButton[section] == "1"{
            aLabel.text = "▼" + songSectionTitle[section]
        }else{
            aLabel.text = "▶︎" + songSectionTitle[section]
        }
        
        aLabel.frame = aView.frame
        aLabel.textAlignment = NSTextAlignment.center
        aLabel.backgroundColor = UIColor.lightGray
        aLabel.font = UIFont.boldSystemFont(ofSize: 18)
        aLabel.clipsToBounds = true
        aLabel.layer.cornerRadius = 17
        
        aButton.addSubview(aLabel)
        aView.addSubview(aButton)
        return aView
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return songSectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songButton[section] == "1"{
            return songSectionSet[section].count
        }else{
            return 0
        }
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
        
        cellView.backgroundColor = viewColor
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        cellView.layer.shadowOpacity = 0.5
        tableView.separatorColor = UIColor.clear
        
        //讓網路圖片下載時不會卡卡（異步處理）
        DispatchQueue.global().async {
            if let data = NSData.init(contentsOf: NSURL.init(string: self.songSectionSet[indexPath.section][indexPath.row].imageURL!)! as URL) {
                
                DispatchQueue.main.async {
                    let image = UIImage.init(data: data as Data)
                    imageView.image = image
                }
                
            }
        }
        
        if songSectionSet[indexPath.section][indexPath.row].title!.components(separatedBy: "_").count == 1{
            title.text = changeCode(text: songSectionSet[indexPath.section][indexPath.row].title!)
        }else{
            let Chinese = songSectionSet[indexPath.section][indexPath.row].title!.components(separatedBy: "_")[0]
            let Japanese = songSectionSet[indexPath.section][indexPath.row].title!.components(separatedBy: "_")[1]
            title.text = Chinese + "\n" + Japanese
        }
        channelTitle.text = changeCode(text: songSectionSet[indexPath.section][indexPath.row].time!)
        
        heartButton.tintColor = viewColor
        heartButton.setTitle(songSectionSet[indexPath.section][indexPath.row].buttonTitle!, for: .normal)
        heartButton.accessibilityIdentifier = "\(indexPath.section)" + "_" + "\(indexPath.row)"
        heartButton.addTarget(self, action: #selector(test(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    @objc func test(sender:UIButton){
        guard let section = Int(sender.accessibilityIdentifier!.components(separatedBy: "_")[0]) else{ return }
        guard let row = Int(sender.accessibilityIdentifier!.components(separatedBy: "_")[1]) else{ return }
        let videoId = songSectionSet[section][row].videoId!
        let title = songSectionSet[section][row].title!
        let time = songSectionSet[section][row].time!
        let lyric = songSectionSet[section][row].lyric!
        let imageURL = songSectionSet[section][row].imageURL!
        //add sentence 20201020
        let sentence = songSectionSet[section][row].sentence!
        if sender.titleLabel?.text == "💛"{
            sender.setTitle("❤️", for: .normal)
            //add sentence 20201020
            coreDataSaveDelete(checkSaveDelete: "S", videoId: videoId, title: title, time: time, lyric: lyric, imageURL: imageURL, sentence: sentence)
            songSectionSet[section][row].buttonTitle = "❤️"
            readCoreData()
        }else{
            sender.setTitle("💛", for: .normal)
            //add sentence 20201020
            coreDataSaveDelete(checkSaveDelete: "D", videoId: videoId, title: title, time: time, lyric: lyric, imageURL: imageURL, sentence: sentence)
            songSectionSet[section][row].buttonTitle = "💛"
            readCoreData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "singerToPlaySegue", sender: songSectionSet[indexPath.section][indexPath.row])
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
    
    //////////////////////////////tableview 処理/////////////////////////////////////
    
    func loadSingerSong(conds:String){
        let database = CKContainer.default().publicCloudDatabase
        var query:CKQuery
        let pre = NSPredicate(value: true)
        switch conds {
        case "0": query = CKQuery(recordType: "femaleSinger", predicate: pre)
        case "1": query = CKQuery(recordType: "maleSinger", predicate: pre)
        default:  query = CKQuery(recordType: "groupSinger", predicate: pre)
        }
        query.sortDescriptors = [NSSortDescriptor(key: "singerId", ascending: true),NSSortDescriptor(key: "keyinDate", ascending: true)]
        let operation = CKQueryOperation(query: query)
        operation.queuePriority = .veryHigh; operation.resultsLimit = 300
        //songSectionSet.removeAll();songButton.removeAll()
        
        //每一組代表不同歌手的歌組
        var set = [[songInfo]]()
        //按鈕確認
        var button = [String]()
        
        operation.recordFetchedBlock = {(records:CKRecord?) in
            guard let record = records else { return }
            var sen = ""
            if record["sentence"] != nil{ sen = record["sentence"] as! String }
            let data = songInfo(videoId: record["videoId"] as! String, title: record["title"] as! String, lyric: record["lyric"] as! String, imageURL: record["imageURL"] as! String, time: record["time"] as! String, singerId: record["singerId"] as! String, singerName: record["singerName"] as! String, sex_flg: record["sex_flg"] as! String, keyinDate: record["keyinDate"] as! String, buttonTitle: "", sentence: sen)
            var checkIf = false
            var count = 0
            var checkButton = false
            //先判斷有沒有在我的最愛
            for checkFavorite in self.favorite{
                if checkFavorite["videoId"] == data.videoId{
                    checkButton = true; data.buttonTitle = "❤️"; break
                }
            }
            if checkButton == false{ data.buttonTitle = "💛" }
            //先判斷這筆資料的歌手有沒有出現過
            for checkSet in set{
                if data.singerId == checkSet[0].singerId{
                    checkIf = true
                    set[count].append(data); break
                }; count += 1
            }
            //如果沒出現過新增一個區加新歌手
            if checkIf == false{
                button.append("1")
                set.append([data])
            }
            
            
            var countSet = 0
            //其の他的位置
            var checkElse = 0
            var checkElseExist = false
            //暫時的ＴＩＴＬＥ數組
            var title = [String]()
            //將歌組總數存到數組並標記出“其他”的位置
            for checkSet in set{
                if checkSet[0].singerId == "F00000"{
                    checkElseExist = true
                    checkElse = countSet; break
                }; countSet += 1
            }
            //把“其他”存起來
            let saveElse = set[checkElse]
            if checkElseExist == true{
                //先把set的其他移掉然後排序，再把在歌組總數的"其他"移到最後
                set.remove(at: checkElse)
            }
            set.sort(by: { (a1, a2) -> Bool in
                return a1.count > a2.count
            })
            if checkElseExist == true{
                set.insert(saveElse, at: set.endIndex)
            }
            
            for setTitle in set{
                title.append(setTitle[0].singerName!)
            }
            self.songSectionTitle = title
            title.removeAll()
            self.songSectionSet = set
            self.songButton = button
            DispatchQueue.main.async { self.songTableView.reloadData() }
        }
        operation.queryCompletionBlock = {(cursor,error) in
            if self.songSectionSet.isEmpty{
                DispatchQueue.main.async { self.songTableView.reloadData() }
            }
            DispatchQueue.main.async {
                self.songTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.activityIndicatorView(flg: "end")
            }
            
        }
        database.add(operation)
    }
    
    
    
    //等待的小圈圈
    var activityIndicator = UIActivityIndicatorView()
    func activityIndicatorView(flg:String){
        if flg == "start"{
            UIApplication.shared.beginIgnoringInteractionEvents()
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        }else if flg == "end"{
            UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator.stopAnimating()
        }
    }
    
    func initView(button:String){
        boySingerButton.backgroundColor = buttonColor
        groupSingerButton.backgroundColor = buttonColor
        girlSingerButton.backgroundColor = buttonColor
        if button == "girl"{ girlSingerButton.backgroundColor = buttonCheckedColor }
        else if button == "group"{ groupSingerButton.backgroundColor = buttonCheckedColor }
        else if button == "boy"{ boySingerButton.backgroundColor = buttonCheckedColor }
        let AD = "ca-app-pub-2739057954665163/2093015027"
        DispatchQueue.main.async {
            self.cmView.adUnitID = AD
            self.cmView.rootViewController = self
            self.cmView.load(GADRequest())
        }
    }
    
    func readCoreData(){
        favorite.removeAll()
        //讀取用戶歌曲數據
        var core = coreDataQuery()
        for check in core{
            //add sentence 20201020
            var sentence = ""
            if check.sentence != nil{ sentence = check.sentence! }
            var dic = [String : String]()
            dic["videoId"] = check.videoId!
            dic["title"] = check.title!
            dic["time"] = check.time!
            dic["lyric"] = check.lyric!
            dic["imageURL"] = check.imageURL!
            //add sentence 20201020
            dic["sentence"] = sentence
            favorite.append(dic)
        }; core.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
