//
//  ViewController.swift
//  tubeTV
//
//  Created by しゅ いりん on 2018/12/19.
//  Copyright © 2018年 ChuWeiLun. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController,YTPlayerViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var myWebView: YTPlayerView!
    @IBOutlet weak var lyricTableView: UITableView!
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var isRepeatButton: UIButton!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var speedView: UIView!
    @IBOutlet weak var quickView: UIView!
    @IBOutlet weak var slowView: UIView!
    @IBOutlet weak var playPauseView: UIView!
    @IBOutlet weak var isRepeatView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    let playerVars = [
        "playsinline" : 1,
        "showinfo" : 0,
        "controls" : 0,
        "autohide" : 1,
        "modestbranding" : 1,
        "rel" : 0,
        "autoplay" : 1
        ]
    
    var dicSongInfo = [String:String]()
    
    var thisSongInfo:songInfo?
    
    var keyId = ""
    var arrIndex = [String]()
    
    var favorite = [Dictionary<String, String>]()
    var isRepeat = ""
    
    //　『恋愛は、それ自身一つのおきてのようなものであり、その人間の進路を定めてしまう。 林語堂（中国）』
    //"SX_ViT4Ra7k","HIB8RBhPkBA","5wmfXve11rM"
    
    var timer:Timer?
    
    
    //我的最愛ＩＤ清單
    var videoIdList = [String]()
    //這首歌的順位
    var countOrder = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setLockView()
        guard let thisSongInfo = thisSongInfo else { return }
        keyId = thisSongInfo.videoId!
        arrIndex = thisSongInfo.lyric!.components(separatedBy: "|")
        
        //放入清單&
        //帶過來的我的最愛清單中，這首是第幾首
        var flg = 0
        //如果不是從我的最愛頁進來的話favorite為空所以此迴圈不成立
        for check in favorite{
            videoIdList.append(check["videoId"]!)
            if keyId == check["videoId"]{
                countOrder = flg
                favoriteButton.setTitle("❤️", for: .normal)
            }
            flg += 1
        }
        
        if isRepeat == "top"{
            readCoreData()
            for check in favorite{
                if keyId == check["videoId"]{
                    favoriteButton.setTitle("❤️", for: .normal)
                }
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playInBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        myWebView.delegate = self
        
        play(webURL: keyId)
        showSpeed.text = String(speed)
        
        startTime.text = "0:00"
        endTime.text = thisSongInfo.time!
        
    }
    
    
    func play(webURL:String){
        myWebView.load(withVideoId: webURL, playerVars: playerVars)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        myWebView.playVideo()
    }
    
    var setPlay = 0
    var setBufferingPlay = 0
    var screenBrightness = UIScreen.main.brightness
    @objc func playInBackground(){
        setPlay = 1
        setBufferingPlay = 1
        setInfoCenterCredentials(rate: 0)
        setupRemoteControlButtonStatus()
        checkIfInBack = "back"
        
        NotificationCenter.default.addObserver(self, selector: #selector(intoForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch(state) {
        case YTPlayerState.playing:
            print("Video playing")
            playPauseButton.setImage(UIImage(named:"pause")!, for: .normal)
            setInfoCenterCredentials(rate: 1)
            //後台按上下一首設定為1，若沒跳出ＣＭ，播放音樂則設回0
            checkBackCMCome = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { (Timer) in
                MusicTube.selectLyric(playLyric: self.arrIndex, myWebView: self.myWebView, lyricTableView: self.lyricTableView)
                
                let perOfTime = self.myWebView.currentTime() / Float(timeToNum(time: self.endTime.text!))
                self.timeSlider.setValue(perOfTime, animated: true)
                self.startTime.text = numToTime(num: Int(self.myWebView.currentTime()))
            })
            //在後台按暫停跳到前台時，會直接播放（此問題有待解決），所以判斷是否停這設為0
            letStopInBack = 0
         
        case YTPlayerState.paused:
            print("Video paused")
            playPauseButton.setImage(UIImage(named:"play")!, for: .normal)
            setInfoCenterCredentials(rate: 0)
            if timer != nil{ timer!.invalidate() }
            //進入背景後
            if setPlay == 1 && letStopInBack == 0{
                myWebView.playVideo()
                setPlay = 0
            }
        case YTPlayerState.unstarted:
            print("Video unstarted")
            setInfoCenterCredentials(rate: 0)
            //在後台第二首開始不會執行ended所以用此判斷
            if checkIfInBack == "back"{
                if checkRepeat == "1"{
                    myWebView.playVideo()
                    lyricTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                //後台按上下一首設定為1，先判斷在後台ＣＭ有無跳出，若跳出則不執行此代碼
                }else if checkBackCMCome == 0{
                    if checkRepeat == "A"{
                        AllRepeat(track: "next", checkUnstart: "unstart")
                    }else if checkRepeat == "R"{
                        RandomRepeat(checkUnstart: "unstart")
                    }
                }
            }else{
                playPauseButton.setImage(UIImage(named:"play")!, for: .normal)
            }
        case YTPlayerState.queued:
            print("Video queued")
            playPauseButton.setImage(UIImage(named:"play")!, for: .normal)
            setInfoCenterCredentials(rate: 0)
        case YTPlayerState.buffering:
            //直接黑頻後台時，如果setBufferingPlay是1時
            if setBufferingPlay == 1{
                myWebView.playVideo();setBufferingPlay = 0
            }
            print("Video buffering")
            setInfoCenterCredentials(rate: 0)
        case YTPlayerState.ended:
            print("Video ended")
            if checkRepeat == "1"{
                myWebView.playVideo()
                lyricTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }else if checkRepeat == "A"{
                //以防第一首結束後跳出ＣＭ，所以設1，等確定沒ＣＭ時play轉0
                checkBackCMCome = 1
                AllRepeat(track: "next", checkUnstart: "NO")
            }else if checkRepeat == "R"{
                //以防第一首結束後跳出ＣＭ，所以設1，等確定沒ＣＭ時play轉0
                checkBackCMCome = 1
                RandomRepeat(checkUnstart: "NO")
            }
            setInfoCenterCredentials(rate: 0)
        default:
            print("Video others")
            break
        }
    }
    
    @IBAction func checkSlider(_ sender: UISlider) {
        let numTime = timeSlider.value * Float(timeToNum(time: endTime.text!))
        myWebView.seek(toSeconds: numTime, allowSeekAhead: true)
        myWebView.playVideo()
        
        sliderTimeJumpToThatLyric(playLyric: arrIndex, sliderTime: Int(numTime), lyricTableView: lyricTableView)
    }
    
    @IBAction func pointSlider(_ sender: UISlider) {
        myWebView.pauseVideo()
    }
    
    @IBAction func slideSlider(_ sender: UISlider) {
        let numOfTime = numToTime(num: Int(timeSlider.value * Float(timeToNum(time: endTime.text!))))
        startTime.text = numOfTime
    }
    
    //如果零的話，進背景後就不會是停的
    var letStopInBack = 0
    @IBAction func play_pause(_ sender: UIButton) {
        let image1:UIImage = UIImage(named:"pause")!
        let image2:UIImage = UIImage(named:"play")!
        if myWebView.playerState() == YTPlayerState.playing{
            sender.setImage(image2, for: .normal)
            myWebView.pauseVideo()
        }else if myWebView.playerState() == YTPlayerState.paused{
            sender.setImage(image1, for: .normal)
            myWebView.playVideo()
        }else if myWebView.playerState() == YTPlayerState.queued{
            sender.setImage(image1, for: .normal)
            myWebView.playVideo()
        }
        if letStopInBack == 0{ letStopInBack = 1 }
        else{ letStopInBack = 0 }
    }
    
    @IBOutlet weak var showSpeed: UILabel!
    
    var speed:Float = 1
    @IBOutlet weak var slowButton: UIButton!
    @IBAction func slow(_ sender: UIButton) {
        if speed != 0.25{
            speed -= 0.25
            myWebView.setPlaybackRate(speed)
        }
        showSpeed.text = String(speed)
    }
    
    @IBOutlet weak var quickButton: UIButton!
    @IBAction func quick(_ sender: UIButton) {
        if speed != 2{
            speed += 0.25
            myWebView.setPlaybackRate(speed)
        }
        showSpeed.text = String(speed)
    }
    
    @IBAction func favoriteButton(_ sender: UIButton) {
        guard let thisSongInfo = thisSongInfo else { return }
        if favoriteButton.titleLabel?.text == "💛"{
            favoriteButton.setTitle("❤️", for: .normal)
            coreDataSaveDelete(checkSaveDelete: "S", videoId: thisSongInfo.videoId!, title: thisSongInfo.title!, time: thisSongInfo.time!, lyric: thisSongInfo.lyric!, imageURL: thisSongInfo.imageURL!)
        }else{
            favoriteButton.setTitle("💛", for: .normal)
            coreDataSaveDelete(checkSaveDelete: "D", videoId: thisSongInfo.videoId!, title: thisSongInfo.title!, time: thisSongInfo.time!, lyric: thisSongInfo.lyric!, imageURL: thisSongInfo.imageURL!)
        }
        
    }
    
    
    //////////////////////////////tableview 処理/////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrIndex.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedCellView = UIView()
        selectedCellView.backgroundColor = UIColor.darkGray
        
        let cell = lyricTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectedBackgroundView = selectedCellView
        tableView.separatorColor = UIColor.clear
        
        guard let textLabel = cell.contentView.subviews[0] as? UILabel else { return cell }
        textLabel.text = String(arrIndex[indexPath.row].components(separatedBy: "_")[1]) + "\n"
            + String(arrIndex[indexPath.row].components(separatedBy: "_")[2])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if timer != nil{ timer!.invalidate() }
        
        
        clickToSeconds(myWebView: myWebView, arrLyric: arrIndex, indexPath: indexPath)
        
        let lyricTime = arrIndex[indexPath.row].components(separatedBy: "_")[0]
        let perOfTime = Float(lyricTime)! / Float(timeToNum(time: endTime.text!))
        self.timeSlider.setValue(perOfTime, animated: true)
        self.startTime.text = numToTime(num: Int(lyricTime)!)
    }
    
    //////////////////////////////tableview 処理/////////////////////////////////////
    
    var checkRepeat = "N"
    @IBAction func isRepeat(_ sender: UIButton) {
        let imageNo:UIImage = UIImage(named:"noRepeat")!
        let imageOne:UIImage = UIImage(named:"repeat")!
        let imageAll:UIImage = UIImage(named:"repeatAll")!
        let imageRandom:UIImage = UIImage(named: "repeatRandom")!
        if isRepeat == "favorite"{
            switch checkRepeat{
            case "N": isRepeatButton.setImage(imageOne, for: .normal); checkRepeat = "1"
            case "1": isRepeatButton.setImage(imageAll, for: .normal); checkRepeat = "A"
            case "A": isRepeatButton.setImage(imageRandom, for: .normal); checkRepeat = "R"
            default: isRepeatButton.setImage(imageNo, for: .normal); checkRepeat = "N"
            }
        }else{
            switch checkRepeat{
            case "N": isRepeatButton.setImage(imageOne, for: .normal); checkRepeat = "1"
            default:  isRepeatButton.setImage(imageNo, for: .normal); checkRepeat = "N"
            }
        }
    }
    
    func setSongInfo(){
        play(webURL: favorite[countOrder]["videoId"]!)
        arrIndex = favorite[countOrder]["lyric"]!.components(separatedBy: "|")
        endTime.text = favorite[countOrder]["time"]!
    }
    
    func AllRepeat(track:String,checkUnstart:String){
        if track == "next"{
            //如果這首歌不是最後一首
            if countOrder != favorite.count - 1{ countOrder += 1 }
            else{ countOrder = 0 }
        }else if track == "last"{
            //如果這首歌不是第一首
            if countOrder != 0{ countOrder -= 1 }
            else{ countOrder = favorite.count - 1 }
        }
        if checkIfInBack != "back"{
            setSongInfo()
        }else{
            //如果在後台第二首以後會到unstart
            if checkUnstart == "unstart"{ setInfoCenterCredentials(rate: 0) }
            else{ backSetSongInfo() }
            arrIndex = favorite[countOrder]["lyric"]!.components(separatedBy: "|")
            endTime.text = favorite[countOrder]["time"]!
        }
        lyricTableView.reloadData()
        lyricTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func RandomRepeat(checkUnstart:String){
        var testNumber = Int(arc4random_uniform(UInt32(favorite.count)))
        while countOrder == testNumber {
            testNumber = Int(arc4random_uniform(UInt32(favorite.count)))
        }
        countOrder = testNumber
        if checkIfInBack != "back"{
            setSongInfo()
        }else{
            //如果在後台第二首以後會到unstart
            if checkUnstart == "unstart"{ setInfoCenterCredentials(rate: 0) }
            else{ backSetSongInfo() }
            arrIndex = favorite[countOrder]["lyric"]!.components(separatedBy: "|")
            endTime.text = favorite[countOrder]["time"]!
        }
        lyricTableView.reloadData()
        lyricTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func backButton(){
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.popViewController(animated: true)
    }
    
    //是否能成为第一响应对象
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func initView(){
        speedView.clipsToBounds = true
        speedView.layer.cornerRadius = 18
        quickButton.clipsToBounds = true
        slowButton.clipsToBounds = true
        playPauseView.layer.cornerRadius = 20
        isRepeatView.layer.cornerRadius = 18
  //      lyricTableView.layer.cornerRadius = 20
        //navigation bar變透明
        let image = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = image
        //----------------
        //狀態列變白色
        self.navigationController?.navigationBar.barStyle = .black
        //Back按鈕
        let leftBarBtn = UIBarButtonItem(title: "◀︎戻る", style: .plain, target: self,action: #selector(backButton))
        leftBarBtn.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarBtn
    }
    
    var checkIfInBack = "front"
    @objc func intoForeground(){
        checkIfInBack = "front"
        print(checkIfInBack)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        print(letStopInBack)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
        //停止接受远程响应事件
        UIApplication.shared.endReceivingRemoteControlEvents()
        
        if timer != nil{ timer!.invalidate() }
      
        print("disappear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        print("appear")
    }
    
    func setLockView(){
        //啟動背景播放功能
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // 使用指定的選項啟動或停用 APP 的 Audio Session。
            try audioSession.setActive(true)
            // 設置 audioSession 類別為 AVAudioSessionCategoryPlayback
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: .default)
        } catch {
            print(error)
        }
    }
    
    func setupRemoteControlButtonStatus(){
        //是我的最愛頁面，背景才設置這兩個按鈕
        if isRepeat == "favorite"{
            let next = MPRemoteCommandCenter.shared().nextTrackCommand
            next.addTarget { (event) -> MPRemoteCommandHandlerStatus in
                return .success
            }
            let last = MPRemoteCommandCenter.shared().previousTrackCommand
            last.addTarget { (event) -> MPRemoteCommandHandlerStatus in
                return .success
            }
            
        }
    }
    
    //后台操作
    var checkBackCMCome = 0
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else {
            print("no event\n")
            return
        }
        if event.type == UIEvent.EventType.remoteControl {
            switch event.subtype {
            case .remoteControlTogglePlayPause:
                print("暂停/播放")
            case .remoteControlPreviousTrack:
                print("上一首")
                myWebView.stopVideo()
                checkBackCMCome = 1
                if checkRepeat == "R"{ RandomRepeat(checkUnstart: "NO") }
                else{ AllRepeat(track: "last", checkUnstart: "NO") }
            case .remoteControlNextTrack:
                print("下一首")
                myWebView.stopVideo()
                checkBackCMCome = 1
                if checkRepeat == "R"{ RandomRepeat(checkUnstart: "NO") }
                else{ AllRepeat(track: "next", checkUnstart: "NO") }
            case .remoteControlPlay:
                print("播放")
                myWebView.playVideo()
                setInfoCenterCredentials(rate: 0)
                
            case .remoteControlPause:
                print("暂停")
                myWebView.pauseVideo()
                setInfoCenterCredentials(rate: 0)
            
            default:
                break
            }
        }
    }
    
    func backSetSongInfo(){
        setInfoCenterCredentials(rate: 0)
        if checkRepeat == "A" || checkRepeat == "R"{
            myWebView.loadPlaylist(byVideos: videoIdList, index: 0, startSeconds: 0.0, suggestedQuality: .auto)
            myWebView.playVideo(at: Int32(countOrder))
        }else if checkRepeat == "1"{
            myWebView.loadPlaylist(byPlaylistId: favorite[countOrder]["videoId"]!, index: 0, startSeconds: 0.0, suggestedQuality: .auto)
            myWebView.playVideo(at: Int32(countOrder))
        }else if checkRepeat == "N"{
            myWebView.cuePlaylist(byPlaylistId: favorite[countOrder]["videoId"]!, index: 0, startSeconds: 0.0, suggestedQuality: .auto)
            
        }
    }
    
    // 设置后台播放显示信息
    func setInfoCenterCredentials(rate:Int) {
        guard let thisSongInfo = thisSongInfo else { return }
        let mpic = MPNowPlayingInfoCenter.default()
        var image = UIImage()
        var ChineseTitle = ""
        var JapaneseTitle = ""
        var startTime = ""
        var endTime = ""
        
        do{
            //如果不是我的最愛進來的話
            if favorite.isEmpty {
                image = UIImage(data: try Data(contentsOf: URL(string: thisSongInfo.imageURL!)!))!
                ChineseTitle = thisSongInfo.title!.components(separatedBy: "_")[0]
                JapaneseTitle = thisSongInfo.title!.components(separatedBy: "_")[1]
                startTime = "\(Int(timeSlider.value * Float(timeToNum(time: thisSongInfo.time!))))"
                
                endTime = "\(timeToNum(time: thisSongInfo.time!))"
                
            }else{
                image = UIImage(data: try Data(contentsOf: URL(string: favorite[countOrder]["imageURL"]!)!))!
                ChineseTitle = favorite[countOrder]["title"]!.components(separatedBy: "_")[0]
                JapaneseTitle = favorite[countOrder]["title"]!.components(separatedBy: "_")[1]
                startTime = "\(Int(timeSlider.value * Float(timeToNum(time: favorite[countOrder]["time"]!))))"
                endTime = "\(timeToNum(time: favorite[countOrder]["time"]!))"
                
            }
        }catch{
            debugPrint(error.localizedDescription)
        }
        
        //专辑封面
        let mySize = CGSize(width: 400, height: 400)
        let albumArt = MPMediaItemArtwork(boundsSize:mySize) { sz in
            return image
        }
        
        mpic.nowPlayingInfo = [
            MPMediaItemPropertyTitle: ChineseTitle,
            MPMediaItemPropertyArtist: JapaneseTitle,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: startTime,
            MPMediaItemPropertyPlaybackDuration: endTime,
            MPMediaItemPropertyArtwork: albumArt,
            MPNowPlayingInfoPropertyPlaybackRate: "\(rate)"
        ]
        
    }
    
    func readCoreData(){
        favorite.removeAll()
        //讀取用戶歌曲數據
        var core = coreDataQuery()
        for check in core{
            var dic = [String : String]()
            dic["videoId"] = check.videoId!
            dic["title"] = check.title!
            dic["time"] = check.time!
            dic["lyric"] = check.lyric!
            dic["imageURL"] = check.imageURL!
            favorite.append(dic)
        }; core.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

