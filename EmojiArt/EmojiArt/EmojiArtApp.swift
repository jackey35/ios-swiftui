//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/23.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let viewModel : EmojiArtDocument = EmojiArtDocument()
    private let paletteStore = PaletteStore(named: "Default")//palette的ViewModel与View的接口
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: viewModel)
        }
    }
}
