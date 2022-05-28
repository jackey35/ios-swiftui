//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/23.
//

import SwiftUI
class EmojiArtDocument : ObservableObject{
    
    @Published private(set) var model : EmojiArtModel{
        didSet{
            if model.backgroud != oldValue.backgroud{
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    @Published var backgroundImage: UIImage?
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
//
    func fetchBackgroundImageDataIfNecessary(){
        backgroundImage = nil//假如上一次抓取还未完成，则立即初始化重新来过
        switch model.backgroud {
                // 检测到是URL开始尝试抓取工作
                case .url(let url):
                backgroundImageFetchStatus = .fetching //将状态设置为抓取中
                DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)//使用Data完成远程下载工作(此步耗时)
                print(imageData)
                DispatchQueue.main.async {[weak self] in
                    if self?.model.backgroud == EmojiArtModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil{
                            self?.backgroundImage = UIImage(data: imageData!)//self?为弱引用
                        }
                    }
                }
                
            }
                    
                   // backgroundImageFetchStatus = .fetching //将状态设置为抓取中

//                    //使用后台队列的userInitiated(上一课结尾理论有讲)优先等级异步处理
//                    DispatchQueue.global(qos: .userInitiated).async {
//
//                        DispatchQueue.main.async { [weak self] in //当抓取完成后切换到主队列异步
//                            //判断被下载的地址与用户最新发新的地址是否一致(用户可能会放很多进来)
//                            if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
//                                self?.backgroundImageFetchStatus = .idle//更新抓取状态（弱引用）
//                                //上面使用了try?说明imageData是有可能失败的
//                                if imageData != nil {
//                                    //图片抓取成功后将其保存到backgroundImage变量(使用UIImage转换数据)
//                                    self?.
//                                }
//                            }
//                        }
                   // }
                    //检测到是Data数据
                case .imageData(let data):
                    backgroundImage = UIImage(data: data)
                    //未设置背影的情况
                case .blank:
                break
            }

    }
    init(){
        model = EmojiArtModel()
        model.addEmoji( "😇", at:( -200, 100), size: 40)
        model.addEmoji( "🤬", at : (50, 100), size: 20)
        
    }
    
    var emojis : [EmojiArtModel.Emoji] {model.emojis}
    var background : EmojiArtModel.Background {model.backgroud}
    
    func setBackground(_ background : EmojiArtModel.Background){
        model.backgroud = background
        print("background set to  \(background)")
    }
    
    func addEmojis(_ emoj: String,at location: (x: Int,y: Int), size: CFloat){
        model.addEmoji(emoj, at: location, size: Int(size))
    }
    
}
