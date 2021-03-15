//
//  webControl.swift
//  tubeTV
//
//  Created by しゅ いりん on 2019/5/11.
//  Copyright © 2019年 ChuWeiLun. All rights reserved.
//

import Foundation
import UIKit


extension String {
    //返回字数
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }

    //使用正则表达式替换
    func pregReplace(pattern: String, with: String,options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],range: NSMakeRange(0, self.count),withTemplate: with)
    }
}

func changeTimeForm(time:String) -> String{
    var H = false
    var M = false
    var S = false
    var change = time
    for checkTime in time{
        if String(checkTime) == "H"{ H = true }
        if String(checkTime) == "M"{ M = true }
        if String(checkTime) == "S"{ S = true }
    }
    if H == true && M == true && S == true{
        change = change.replacingOccurrences(of: "H", with: ":")
        change = change.replacingOccurrences(of: "M", with: ":")
        change = change.replacingOccurrences(of: "S", with: "")
    }else if H == true && M == true && S == false{
        change = change.replacingOccurrences(of: "H", with: ":")
        change = change.replacingOccurrences(of: "M", with: ":00")
    }else if H == true && M == false && S == false{
        change = change.replacingOccurrences(of: "H", with: ":00:00")
    }else if H == true && M == false && S == true{
        change = change.replacingOccurrences(of: "H", with: ":00:")
        change = change.replacingOccurrences(of: "S", with: "")
    }else if H == false && M == true && S == true{
        change = change.replacingOccurrences(of: "M", with: ":")
        change = change.replacingOccurrences(of: "S", with: "")
    }else if H == false && M == true && S == false{
        change = change.replacingOccurrences(of: "M", with: ":00")
    }else if H == false && M == false && S == true{
        change = change.replacingOccurrences(of: "S", with: "")
        change = "0:\(change)"
    }
    var component = change.components(separatedBy: ":")
    if component.count == 2 && component[0] != "0" && component[1] != "00"{
        if Int(component[1])! < 10{ component[1] = "0\(component[1])" }
        change = component[0] + ":" + component[1]
    }else if component.count == 3 && component[0] != "0" && component[1] != "00"{
        if Int(component[1])! < 10{ component[1] = "0\(component[1])" }
        if Int(component[2])! < 10{ component[2] = "0\(component[2])" }
        change = component[0] + ":" + component[1] + ":" + component[2]
    }
    return change
}

func numToTime(num:Int) -> String{
    let t1 = num / 60
    let t2 = num % 60
    var st2 = ""
    if t2 < 10{
        st2 = "0\(t2)"
    }else{
        st2 = "\(t2)"
    }
    return "\(t1):\(st2)"
}

func timeToNum(time:String) -> Int{
    var total = 0
    let component = time.components(separatedBy: ":")
    if component.count == 3{
        total += Int(component[0])! * 60 * 60
        total += Int(component[1])! * 60
        total += Int(component[2])!
    }else if component.count == 2{
        total += Int(component[0])! * 60
        total += Int(component[1])!
    }
    return total
}



func selectLyric(playLyric: Array<String>, myWebView:WKYTPlayerView, lyricTableView:UITableView){
    //modify in 20201025 start
    myWebView.getCurrentTime { (floatValue, error) in
        if error == nil{
            var count = 0
            for i in playLyric{
                if Int(i.components(separatedBy: "_")[0]) == Int(floatValue){
                    lyricTableView.scrollToRow(at: IndexPath(row: count, section: 0), at: .middle, animated: true)
                    lyricTableView.selectRow(at: IndexPath(row: count, section: 0), animated: true, scrollPosition: .none)
                    
                }
                count += 1
            }
        }
    }
    //modify in 20201025 end
}

func sliderTimeJumpToThatLyric(playLyric:Array<String>, sliderTime:Int, lyricTableView:UITableView){
    var count = 0
    for i in playLyric{
        if Int(i.components(separatedBy: "_")[0])! > sliderTime{
            if count != 0{
                lyricTableView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .middle, animated: true)
                lyricTableView.selectRow(at: IndexPath(row: count - 1, section: 0), animated: true, scrollPosition: .none)
            }else{
                lyricTableView.scrollToRow(at: IndexPath(row: count, section: 0), at: .middle, animated: true)
                lyricTableView.selectRow(at: IndexPath(row: count, section: 0), animated: true, scrollPosition: .none)
            }
            break
        }else if Int((playLyric.last?.components(separatedBy: "_")[0])!)! < sliderTime{
            lyricTableView.scrollToRow(at: IndexPath(row: count, section: 0), at: .middle, animated: true)
            lyricTableView.selectRow(at: IndexPath(row: count, section: 0), animated: true, scrollPosition: .none)
        }
        count += 1
    }
}


func clickToSeconds(myWebView:WKYTPlayerView, arrLyric:Array<String>, indexPath: IndexPath){
    for countArr in 0 ... (arrLyric.count - 1){
        if countArr == indexPath.row{
            if let seconds = Float(arrLyric[countArr].components(separatedBy: "_")[0]){
                myWebView.seek(toSeconds: seconds, allowSeekAhead: true)
                break
            }
        }
    }
}

func changeCode(text:String)->String{
    do{
        let encodedData = text.data(using: String.Encoding.utf8)
        let attributedString = try NSAttributedString(data: encodedData!,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding:String.Encoding.utf8.rawValue],documentAttributes: nil)
        return attributedString.string
    }catch{
        return "\(debugPrint(error.localizedDescription))"
        
    }
}


extension UIColor {
    // Hex String -> UIColor
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    // UIColor -> Hex String
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}

//modify 20201020 add "sentence"
func coreDataSaveDelete(checkSaveDelete:String,videoId:String,title:String,time:String,lyric:String,imageURL:String,sentence:String){
    let appDel = UIApplication.shared.delegate as? AppDelegate
    guard let context = appDel?.persistentContainer.viewContext else{ return }
    if checkSaveDelete == "S"{
        let aSongInfo = SongInfo(context: context)
        aSongInfo.videoId = videoId
        aSongInfo.title = title
        aSongInfo.time = time
        aSongInfo.lyric = lyric
        aSongInfo.imageURL = imageURL
        aSongInfo.sentence = sentence
        appDel?.saveContext()
    }else if checkSaveDelete == "D"{
        for check in coreDataQuery(){
            guard let checkVideoId = check.videoId else { return }
            if checkVideoId == videoId{ context.delete(check) }
            appDel?.saveContext()
        }
    }
}

func coreDataQuery() -> [SongInfo]{
    let appDel = UIApplication.shared.delegate as? AppDelegate
    guard let context = appDel?.persistentContainer.viewContext else{ return [SongInfo()]}
    do{
        let results = try context.fetch(SongInfo.fetchRequest())
        guard let aSongInfo = results as? [SongInfo] else { return [SongInfo()] }
        return aSongInfo
    }catch{ return [SongInfo()] }
}

func dayToDay(day:Int) -> String{
    if day == 1 || day == 2 || day == 3 || day == 4 || day == 5 || day == 6 || day == 7 || day == 8 || day == 9{ return "0\(day)" }else{ return "\(day)" }
}




