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
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: viewModel)
        }
    }
}
