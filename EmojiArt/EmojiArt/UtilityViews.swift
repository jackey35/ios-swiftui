//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/24.
//
import SwiftUI

//语法确保能够传递一个可选的UIImage给Image
//(通常它只接受一个不可选的UIImage)
struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}


//语法糖
//很多时候我们想要一个简单的按钮
//只使用文本或标签或systemImage
//但我们希望它执行的动作是动画的
//(即withAnimation)
//这只是使它容易创建这样一个按钮
//从而清理我们的代码
struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if title != nil && systemImage != nil {
                Label(title!, systemImage: systemImage!)
            } else if title != nil {
                Text(title!)
            } else if systemImage != nil {
                Image(systemName: systemImage!)
            }
        }
    }
}

//简单的结构，使它更容易显示可配置的警报
//只是一个可识别的结构体，它可以根据需要创建一个Alert
//使用。alert(item: $alertToShow) {theIdentifiableAlert in…｝
// alertToShow是一个绑定?
//当你想显示一个警告
//设置alertToShow = IdentifiableAlert(id: "my alert") {alert (title:…)}
//当然，字符串标识符对于所有不同类型的警报必须是唯一的

struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
}
