//
//  EmojCardGameViewModel.swift
//  memorized
//
//  Created by ε½­ε©· on 2022/5/14.
//

import Foundation
class EmojCardGameViewModel : ObservableObject{
    static let emojs = ["βοΈ","π","π","π»","π","π","π²","π","π","π","π","π"
                         ,"π€","πΆ","π©"]
    static func createMemoryGameModel() -> MemoryGameModel<String>{
            MemoryGameModel<String>(numberOfPairCard: 6){ pairindex in
                emojs[pairindex]
            }
    }
    
    @Published var model : MemoryGameModel<String> = createMemoryGameModel()//εεΈδΊδ»Ά
    
    var cards : Array<MemoryGameModel<String>.Card>{
        return model.cards
    }
    
    func choose(_ card:MemoryGameModel<String>.Card){
        model.choose(card)
    }
    
    func shuffle(){
        model.shuffle()
    }
    
    func restart(){
        model = EmojCardGameViewModel.createMemoryGameModel()
    }
}
