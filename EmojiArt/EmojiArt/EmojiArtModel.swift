//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/23.
//

import Foundation
import UIKit

struct EmojiArtModel : Codable{
    var backgroud = Background.blank
    
    var emojis = [Emoji]()
    
    
    
    
    struct Emoji : Identifiable,Hashable,Codable {
        let text : String
        var x : Int
        var y : Int
        var size : Int
        let id : Int
        
        
        fileprivate init(text:String,x : Int, y : Int, size : Int, id : Int){
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    init(){
       
        
    }
    
    //初始化时传入 Data 格式 并可能抛出错误
    init(json: Data) throws {
        //尝试将Data 解码成功的数据恢复给 self
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    //初始化时传入本地URL路径（并可能抛出错误）
    init(url: URL) throws {
        let data = try Data(contentsOf: url) //尝试从本地的 url 路径获取(这里将阻塞主线程时间极短)
        self = try EmojiArtModel(json: data)//然后再调用上面的init(json: Data)初始化 解码
    }
    
    func json() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    private var uniqueEmojiId = 0
    mutating func addEmoji(_ text : String, at location:(x: Int,y : Int), size : Int){
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text,x: location.x,y: location.y,size: size,id : uniqueEmojiId))
    }
    
    
}
