//
//  PaletteChooserView.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/6/3.
//

import SwiftUI

struct PaletteChooserView: View {
    var emojFontSize : CGFloat = 40
    var emojFont : Font{.system(size: emojFontSize)}
    
    @EnvironmentObject var store : PaletteStore
    
    @State private var chosePaletteIndex = 0
    var body: some View {
        
        HStack{
            paletterButton
            body(for :store.palette(at: chosePaletteIndex))
        }
        .clipped()
    }
    
    var paletterButton : some View{
        Button {
            withAnimation{
                chosePaletteIndex = (chosePaletteIndex + 1)%store.palettes.count
            }
            
        }
        label:{
            Image(systemName: "paintpalette")
        }
        .font(emojFont)
        .contextMenu{contextMenu}
    }
    
    @ViewBuilder
    var contextMenu : some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil"){
            //editing = true
            paletterToEditor = store.palette(at: chosePaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus"){
            store.insertPalette(named: "New",emojis: "",at: chosePaletteIndex)
            //editing = true
            paletterToEditor = store.palette(at: chosePaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle"){
            chosePaletteIndex = store.removePalette(at: chosePaletteIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slide.vertical.3"){
            managing = true
        }
        
        gotoMenu
    }
    
    var gotoMenu : some View{
        Menu {
            ForEach (store.palettes){palette in
                AnimatedActionButton(title: palette.name){
                    if let index = store.palettes.index(matching: palette){
                        chosePaletteIndex = index
                    }
                    
                }
            }
        } label: {
            Label("Go To",systemImage: "text.insert")
        }
    }
    func body(for palette : Palette) -> some View{
        HStack{
            Text(palette.name)
            //使用横向滚动视图展示测试表情
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojFont)
        }
        .id(palette.id)
        .transition(rollTransiztion)
//        .popover(isPresented: $editing){
//            PaletterEditor(paletter: $store.palettes[chosePaletteIndex])
//        }
        .popover(item: $paletterToEditor){ palette in
                  PaletterEditor(paletter: $store.palettes[palette])
              }
        .sheet(isPresented: $managing){
                  PaletteManager()
              }
    }
    
    //@State private var editing : Bool = false
    @State private var managing : Bool = false
    @State private var paletterToEditor : Palette?
    
    var rollTransiztion : AnyTransition{
        AnyTransition.asymmetric(
            insertion: .offset(x: 0,y: emojFontSize),
            removal: .offset(x: 0, y: -emojFontSize))
    }
}

//横向滚动视图
struct ScrollingEmojisView:View {
    let emojis:String
    var body: some View{
        ScrollView(.horizontal){
            HStack{
                //emojis.map是学习知识点
                //通过map{ $0 }将字符串映射成一个字符串数组
                //let $0: String.Element所以需要String($0)
                ForEach(emojis.map{ String($0) },id: \.self){ emoji in
                    Text(emoji)
                        .onDrag{NSItemProvider(object:emoji as NSString)}
                }
            }
        }
    }
    
}

