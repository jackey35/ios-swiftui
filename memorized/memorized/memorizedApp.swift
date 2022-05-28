//
//  memorizedApp.swift
//  memorized
//
//  Created by 彭婷 on 2022/5/9.
//

import SwiftUI

@main
struct memorizedApp: App {
    let game : EmojCardGameViewModel = EmojCardGameViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(emojCardGameViewModel:game)
        }
    }
}
