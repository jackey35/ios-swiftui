//
//  UtilityExtensions.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI


//在一个可识别的集合中（Collection）
//我们通常想要找到id相同的元素
//作为我们已经在手边的可识别对象
//我们命名这个index(matching:)而不是firstIndex(matching:)
//因为我们假设某人创建了一个集合的可识别
//通常只有每个可标识事物中的一个
//(虽然没有限制它们这样做;这只是一个命名选择)
extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}

//当移除一个元素时，我们可以做同样的事情
//但我们必须把它添加到一个不同的协议(RangeReplaceableCollection)
//因为集合适用于不可变的集合(Collection)
//可变的是RangeReplaceableCollection
//我们不仅可以添加删除
//我们还可以添加一个下标，它接受一个元素的副本
//并使用它的可识别性下标到集合中
//这是在视图模型中创建绑定到数组的一种很棒的方法
//(因为ObservableObject中的Published变量可以通过$绑定到)
//(即使是publish变量上的变量或该变量上的下标)
//(或该变量上的下标，等等)

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(_ element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        }
    }

    subscript(_ element: Element) -> Element {
        get {
            if let index = index(matching: element) {
                return self[index]
            } else {
                return element
            }
        }
        set {
            if let index = index(matching: element) {
                replaceSubrange(index...index, with: [newValue])
            }
        }
    }
}

//如果你在HW5中使用Set来表示选择的表情
//那么你可能会发现这个语法糖函数是有用的

extension Set where Element: Identifiable {
    mutating func toggleMembership(of element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        } else {
            insert(element)
        }
    }
}


//字符串和字符的一些扩展
//帮助我们管理我们的表情符号串
//我们希望它们“只有表情符号”
//(如下为isEmoji)
//我们不希望他们有重复的表情符号
//(下面是withNoRepeatedCharacters)
extension String {
    var withNoRepeatedCharacters: String {
        var uniqued = ""
        for ch in self {
            if !uniqued.contains(ch) {
                uniqued.append(ch)
            }
        }
        return uniqued
    }
}

extension Character {
    var isEmoji: Bool {
        // Swift没有办法问一个字符是不是emoji
        //但它确实让我们检查我们的组件标量是否为emoji
        //很不幸的是unicode允许特定的标量(比如1)
        //被另一个标量修改成为表情符号(例如1️⃣)
        //因此标量“1”将报告isEmoji = true
        //我们不能检查第一个标量是否为emoji
        //这里的快速和肮脏的是看看标量是否至少是我们知道的第一个真正的表情符号
        //(“miscellaneous items”部分的开头)
        //或检查这是否是一个多标量unicode序列
        //(例如，一个带有unicode修饰符的1将被显示为emoji 1️⃣)
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

//从包含其他信息的url中提取实际的url到图像
//寻找imgurl键
// imgurl是一个“众所周知”的键，可以嵌入到一个url中，表示实际的图像url是什么
extension URL {
    var imageURL: URL {
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        return baseURL ?? self
    }
}

//添加/减去cgpoint和cgsize的方便函数
//在做手势处理时可能会派上用场
//因为我们做了很多坐标系统之间的转换
//注意LHS和RHS参数的类型类型如下所示
//因此，你可以通过CGSize的宽度和高度来偏移CGPoint

extension DragGesture.Value {
    var distance: CGSize { location - startLocation }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

extension CGPoint {
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }
    static func +(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    static func -(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

extension CGSize {
    //面积和我们一样大的区域的中心点
    var center: CGPoint {
        CGPoint(x: width/2, y: height/2)
    }
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
}

//在CGSize和CGFloat中添加RawRepresentable协议一致性
//这样就可以和@SceneStorage一起使用
//首先提供rawValue和init的默认实现(rawValue:)
//在RawRepresentable中，当有问题的东西是可编码的(CGFloat和CGSize都是)
//如果要使某个可编程的东西成为raw具象的，只需要声明它是这样的
//(它将得到RawRepresentable的默认实现)

extension RawRepresentable where Self: Codable {
    public var rawValue: String {
        if let json = try? JSONEncoder().encode(self), let string = String(data: json, encoding: .utf8) {
            return string
        } else {
            return ""
        }
    }
    public init?(rawValue: String) {
        if let value = try? JSONDecoder().decode(Self.self, from: Data(rawValue.utf8)) {
            self = value
        } else {
            return nil
        }
    }
}

extension CGSize: RawRepresentable { }
extension CGFloat: RawRepresentable { }


// NSItemProvider的方便函数(即NSItemProvider数组)
//使从提供程序加载对象的代码更简单
// NSItemProvider是来自Objective-C(即前swift)世界的一个延续
//你可以通过它的名字来判断(以NS开头)
//很不幸，处理这个API有点麻烦
//因此，我建议你接受这些loadObjects函数将工作，并继续前进
//尝试深入了解这里发生了什么是一种罕见的情况
//可能不会很有效地利用你的时间
//(尽管我肯定不会说你不应该!)
//(只是想帮你优化这个季度的宝贵时间)

extension Array where Element == NSItemProvider {
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            provider.loadObject(ofClass: theType) { object, error in
                if let value = object as? T {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            let _ = provider.loadObject(ofClass: theType) { object, error in
                if let value = object {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
}
