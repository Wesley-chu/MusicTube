//
//  versionManager.swift
//  tubeTV
//
//  Created by しゅ いりん on 2019/8/13.
//  Copyright © 2019年 ChuWeiLun. All rights reserved.
//

import Foundation
import CloudKit
struct VersionInfo {
    var url:String //下载应用URL
    var title:String //title
    var message:String //提示内容
    var must_update:Bool //是否强制更新
    var version:String //版本
}

class VersionManager:NSObject {
    //本地版本
    private static func localVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static func versionUpdate(ver:String) {
        //1 请求服务端数据，并进行解析,得到需要的数据
        guard let url1 = URL(string: "https://itunes.apple.com/lookup?id=1491120880") else { return }
        var request = URLRequest(url: url1); request.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        var dicData = [String:String]()
        let task = session.dataTask(with: request) { (data, respose, error) in
            if error != nil{
                debugPrint(error!.localizedDescription); print("bad"); return
            }
            guard let DLdata = data else {return}
            do{
                let json = try JSONSerialization.jsonObject(with: DLdata, options: []) as! Dictionary<String, AnyObject>
                
                
                
                if (json["results"] as! Array<AnyObject>).isEmpty == false{
                    let dic_results = (json["results"] as! Array<AnyObject>)[0] as! Dictionary<String,String>
                    dicData["trackViewUrl"] = dic_results["trackViewUrl"]
                    dicData["version"] = dic_results["version"]
                    
                    guard let version = dicData["version"] else { return }
                    guard let trackViewUrl = dicData["trackViewUrl"] else { return }
                    guard let localVersion = localVersion() else { return }
                    var update = false
                    if version.components(separatedBy: ".")[0] ==  localVersion.components(separatedBy: ".")[0]{ update = false }
                    else{ update = true }
                    
                    let database = CKContainer.default().publicCloudDatabase
                    let query = CKQuery(recordType: "versionWord", predicate: NSPredicate(value: true))
                    let operation = CKQueryOperation(query: query)
                    var text = ""
                    operation.queuePriority = .veryHigh; operation.resultsLimit = 300
                    operation.recordFetchedBlock = {(records:CKRecord?) in
                        guard let record = records else { return }
                        if ver == record["version"] as! String{
                            text = record["text"] as! String
                            //2 版本更新
                            handleUpdate(VersionInfo(url: trackViewUrl, title: "ニューバージョン！", message: text, must_update: update, version: version))
                        }
                    }
                    database.add(operation)
                }else{
                    print("no data")
                }
                
                
                
                
            }catch{
                debugPrint(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    /// 版本更新
    private static func handleUpdate(_ info: VersionInfo) {
        guard let localVersion = localVersion()else { return }
        if isIgnoreCurrentVersionUpdate(info.version) { return }
        if versionCompare(localVersion: localVersion, serverVersion: info.version) {
            let alert = UIAlertController(title: info.title, message: info.message, preferredStyle: .alert)
            let update = UIAlertAction(title: "AppStoreに行く", style: .default, handler: { action in
                UIApplication.shared.open(URL(string: info.url)!, options: [ : ], completionHandler: { (_) in })
            })
            alert.addAction(update)
            if !info.must_update { //是否强制更新
                let cancel = UIAlertAction(title: "やめる", style: .cancel, handler: { action in
                    UserDefaults.standard.set(info.version, forKey: "IgnoreCurrentVersionUpdate")
                })
                alert.addAction(cancel)
            }
            
            if let vc = UIApplication.shared.keyWindow?.rootViewController {
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // 版本比较
    private static func versionCompare(localVersion: String, serverVersion: String) -> Bool {
        
        if localVersion.components(separatedBy: ".")[0] ==  serverVersion.components(separatedBy: ".")[0] && localVersion.components(separatedBy: ".")[1] ==  serverVersion.components(separatedBy: ".")[1]{
            return false
        }else{
            let result = localVersion.compare(serverVersion, options: .numeric, range: nil, locale: nil)
            if result == .orderedDescending || result == .orderedSame{
                return false
            }
            return true
        }
        
    }
    
    // 是否忽略当前版本更新
    private static func isIgnoreCurrentVersionUpdate(_ version: String) -> Bool {
        return UserDefaults.standard.string(forKey: "IgnoreCurrentVersionUpdate") == version
    }
}
