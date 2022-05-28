//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/23.
//

import Foundation

extension EmojiArtModel{
    //背影只有3个选项，要么是空白，要么来源URL的图片、本地存储的图片数据
    enum Background : Equatable{
            case blank//无背影
            case url(URL)//背影来源的URL
            case imageData(Data)//被保存的图片（JPEG、PNG等被数据化后）
            
            //处理url的方式，类似Optional处理方式
            var url:URL?{
                switch self {
                    //如果url里有值(使用let url判断的)则返回
                    case .url(let url): return url
                    //默认返回nil
                    default: return nil
                }
            }
            //和上面URL做了同样的事
            var imageData:Data?{
                switch self {
                    case .imageData(let data): return data
                    default:  return nil
                }
            }
        }

}
