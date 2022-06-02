import SwiftUI

//定义 调色板Model
struct Palette: Identifiable, Codable {
    var name: String //调色板名称
    var emojis: String //调色板里有哪些表情(多个)
    let id: Int //符合 Identifiable 协议
    //初始化
    fileprivate init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}
//定义调色板ViewModel
class PaletteStore: ObservableObject {
    let name: String //调色板名称（动物、万圣节、交通工具这样的主题名称）
    //我们的调色板有多个，所以使用数组
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()//更改后将自动保存到UserDefaults
        }
    }
    //返回userDefaultsKey
    private var userDefaultsKey: String {
        "PaletteStore:" + name //保存格式为PaletteStore:调色板名
    }
    //自动将编码后的数据保存到UserDefaults
    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
        //UserDefaults.standard.set(palettes.map { [$0.name,$0.emojis,String($0.id)] }, forKey: userDefaultsKey)//没有使用Codable就需要这样的方式去存，视频（1:34:39）
    }
    //从UserDefaults自动恢复数据
    private func restoreFromUserDefaults() {
        //使用Codable后代码变少更易读
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedPalettes = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData) {
            palettes = decodedPalettes
        }
        //未使用Codable所以下面的代码需要转化而代码量多，视频(1:37:16)
        //        if let palettesAsPropertyList = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String]] {
        //            for paletteAsArray in palettesAsPropertyList {
        //                if paletteAsArray.count == 3, let id = Int(paletteAsArray[2]), !palettes.contains(where: { $0.id == id }) {
        //                    let palette = Palette(name: paletteAsArray[0], emojis: paletteAsArray[1], id: id)
        //                    palettes.append(palette)
        //                }
        //            }
        //        }
    }
    //初始化
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults() //自动恢复
        //如果没有调色板就导入默认的数据
        if palettes.isEmpty {
            insertPalette(named: "Vehicles", emojis: "🚙🚗🚘🚕🚖🏎🚚🛻🚛🚐🚓🚔🚑🚒🚀✈️🛫🛬🛩🚁🛸🚲🏍🛶⛵️🚤🛥🛳⛴🚢🚂🚝🚅🚆🚊🚉🚇🛺🚜")
            insertPalette(named: "Sports", emojis: "🏈⚾️🏀⚽️🎾🏐🥏🏓⛳️🥅🥌🏂⛷🎳")
            insertPalette(named: "Music", emojis: "🎼🎤🎹🪘🥁🎺🪗🪕🎻")
            insertPalette(named: "Animals", emojis: "🐥🐣🐂🐄🐎🐖🐏🐑🦙🐐🐓🐁🐀🐒🦆🦅🦉🦇🐢🐍🦎🦖🦕🐅🐆🦓🦍🦧🦣🐘🦛🦏🐪🐫🦒🦘🦬🐃🦙🐐🦌🐕🐩🦮🐈🦤🦢🦩🕊🦝🦨🦡🦫🦦🦥🐿🦔")
            insertPalette(named: "Animal Faces", emojis: "🐵🙈🙊🙉🐶🐱🐭🐹🐰🦊🐻🐼🐻‍❄️🐨🐯🦁🐮🐷🐸🐲")
            insertPalette(named: "Flora", emojis: "🌲🌴🌿☘️🍀🍁🍄🌾💐🌷🌹🥀🌺🌸🌼🌻")
            insertPalette(named: "Weather", emojis: "☀️🌤⛅️🌥☁️🌦🌧⛈🌩🌨❄️💨☔️💧💦🌊☂️🌫🌪")
            insertPalette(named: "COVID", emojis: "💉🦠😷🤧🤒")
            insertPalette(named: "Faces", emojis: "😀😃😄😁😆😅😂🤣🥲☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🥸🤩🥳😏😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤯😳🥶😥😓🤗🤔🤭🤫🤥😬🙄😯😧🥱😴🤮😷🤧🤒🤠")
        }
    }
    
    // MARK: - Intent 用户意图
    //通过索引 找到 调色板
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    //移除一个调色板
    @discardableResult //可废弃的结果
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    //插入一个调色板
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}
