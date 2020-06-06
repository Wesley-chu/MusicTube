//
//  songInfoClass.swift
//  tubeTV
//
//  Created by しゅ いりん on 2019/10/22.
//  Copyright © 2019年 ChuWeiLun. All rights reserved.
//

import Foundation
import UIKit
class songInfo {
    var videoId:String?
    var title:String?
    var lyric:String?
    var imageURL:String?
    var time:String?
    var singerId:String?
    var singerName:String?
    var sex_flg:String?
    var keyinDate:String?
    var buttonTitle:String?
    
    init(videoId:String,title:String,lyric:String,imageURL:String,time:String,
         singerId:String,singerName:String,sex_flg:String,
         keyinDate:String,buttonTitle:String) {
        self.videoId = videoId
        self.title = title
        self.lyric = lyric
        self.imageURL = imageURL
        self.time = time
        self.singerId = singerId
        self.singerName = singerName
        self.sex_flg = sex_flg
        self.keyinDate = keyinDate
        self.buttonTitle = buttonTitle
    }
    
    
    
    
}




















