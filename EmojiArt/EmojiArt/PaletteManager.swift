//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/6/9.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var store : PaletteStore
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationModel
    
    @State private var editMode : EditMode = .inactive
    var body: some View {
        NavigationView{
            List{
                ForEach(store.palettes){palette in
                    NavigationLink(destination: PaletterEditor(paletter: $store.palettes[palette])){
                        VStack(alignment: .leading){
                            Text(palette.name).font(editMode == .active ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete{ indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove{indexSet,newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem{EditButton()}
                ToolbarItem(placement: .navigationBarLeading){
                    if presentationModel.wrappedValue.isPresented,
                       UIDevice.current.userInterfaceIdiom != .pad{
                        Button("Close"){
                            presentationModel.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .environment(\.editMode,$editMode)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
    }
}
