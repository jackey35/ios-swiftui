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
            schedualAutoSave()
            if model.backgroud != oldValue.backgroud{
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    private var autosaveTimer : Timer?
    private func schedualAutoSave(){
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false){_ in
            self.autoSave()
        }
    }
    
    @Published var backgroundImage: UIImage?
    
    enum BackgroundImageFetchStatus : Equatable{
        case idle
        case fetching
        case failed(URL)
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
                        
                        if self?.backgroundImage == nil {
                            self?.backgroundImageFetchStatus = .failed(url)
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
        //尝试获取路径，并通过路径url初始化Model
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
            model = autosavedEmojiArt //恢复初始化成功的数据
            fetchBackgroundImageDataIfNecessary()//抓取远程图片
        } else {
            model = EmojiArtModel() //原来的初始化
        }

        //model.addEmoji( "😇", at:( -200, 100), size: 40)
        //model.addEmoji( "🤬", at : (50, 100), size: 20)
        
    }
    
    private func autoSave(){
        if let url = Autosave.url {
            save(to: url)
        }
            
    }
    
    //自动保存时获取url路径
    private struct Autosave {
        static let filename = "Autosaved.emojiart"//被保存的默认名称
        //当使用Autosave.url时获取到文档保存的URL路径(Optinal类型)
        static var url: URL? {
            //获取到沙箱里的document目录的url
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first //这是一个跨平台的功能
            return documentDirectory?.appendingPathComponent(filename) //返回将文件名追回进入的URL(有可能是nil)
        }
        //static let coalescingInterval = 5.0 //保存间隔时间
    }
    
    private func save(to url : URL){
        let thisfunction = "(String(describing: self)).(#function)"
        do{
            let data : Data = try model.json()
            print("\(thisfunction) json = \(String(data: data, encoding: .utf8) ?? "nil")") //打印被编码后的json
            try data.write(to : url)
            print("\(thisfunction) is success!")
        }catch let  encodingError where encodingError is EncodingError{
            //EncodingError是一种编码时才出现的错误类型
            print("\(thisfunction) 无法将EmojiArt编码为JSON，因为: \(encodingError.localizedDescription)")
            
        }catch {
            //非EncodingError错误的情况
            print("\(thisfunction) 错误: \(error)")
        }
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
