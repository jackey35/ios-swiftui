//
//  PaletterEditor.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/6/7.
//

import SwiftUI

struct PaletterEditor: View {
    @Binding var paletter :Palette
    var body: some View {
//        Form{
//            TextField("Name",text: $paletter.name)
//        }
        Form{
            nameSection
            addEmojiSection
            removeEmojiSection
        }
        .navigationTitle("Editor,\(paletter.name)")
        .frame(minWidth: 300, minHeight: 350)
    }
    
    var nameSection : some View {
        Section(header: Text("Name")){
            TextField("Name",text: $paletter.name)
        }
    }
    
    @State private var emojisToadd = ""
    
    var addEmojiSection : some View {
        Section(header:Text("Add Emojis")){
            TextField("",text: $emojisToadd)
                
                .onChange(of: emojisToadd){ emojis in
                    addEmojis(emojis)
                    
                }
        }
    }
    
    //删除点击的表情
        var removeEmojiSection: some View {
            Section(header: Text("删除表情")) {
                //通过扩展里的 removingDuplicateCharacters 删除重复的字符
                let emojis = paletter.emojis.withNoRepeatedCharacters.map { String($0) }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                    //在LG上遍历所有的表情
                    ForEach(emojis, id: \.self) { emoji in
                        Text(emoji)
                            .onTapGesture {
                                //点击被删除的表情调用VM相关功能s
                                withAnimation {
                                    paletter.emojis.removeAll(where: { String($0) == emoji })
                                }
                            }
                    }
                }
                .font(.system(size: 40))
            }
        }
    
    func addEmojis(_ emojis: String){
        withAnimation{
            paletter.emojis = (emojis + paletter.emojis)
                .filter{ $0.isEmoji }
                .withNoRepeatedCharacters
                //.removiingDuplicateCharacters
        }
    }
}

struct PaletterEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletterEditor(paletter: .constant(PaletteStore(named: "preview").palette(at: 4)))
    }
}
