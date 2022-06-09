//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/23.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject private var viewModel : EmojiArtDocument = EmojiArtDocument()
    @StateObject private var paletteStore = PaletteStore(named: "Default")//palette的ViewModel与View的接口
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: viewModel).environmentObject(paletteStore)
        }
    }
}
