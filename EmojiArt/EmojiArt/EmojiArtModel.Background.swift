//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/23.
//

import Foundation

extension EmojiArtModel{
    //背影只有3个选项，要么是空白，要么来源URL的图片、本地存储的图片数据
    enum Background : Equatable,Codable{
            case blank//无背影
            case url(URL)//背影来源的URL
            case imageData(Data)//被保存的图片（JPEG、PNG等被数据化后）
            
            //初始化init实现Decoder以符合Codable协议
            init(from decoder: Decoder) throws {
                //try 尝试将已编码的数据CodingKeys解码
                let container = try decoder.container(keyedBy: CodingKeys.self)
                //先假设被编码的数据是URL类型
                if let url = try? container.decode(URL.self, forKey: .url){
                    self = .url(url) //当前枚举的值为.url
                } else if let imageData = try? container.decode(Data.self, forKey: .imageData){
                    //再假设被编辑的数据是Data类型
                    self = .imageData(imageData)
                }else{
                    self = .blank //以上都不对的情况
                }
            }
            //实现Encoder以符合Codable协议
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                    case .url(let url):try container.encode(url, forKey: .url)
                    case .imageData(let data):try container.encode(data, forKey: .imageData)
                    case .blank: break
                }
            }
            //定义一个CodingKeys方便编码调用
            private enum CodingKeys: String,CodingKey {
                case url = "theURL"
                case imageData
            }

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
