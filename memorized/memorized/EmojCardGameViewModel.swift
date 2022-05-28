//
//  EmojCardGameViewModel.swift
//  memorized
//
//  Created by 彭婷 on 2022/5/14.
//

import Foundation
class EmojCardGameViewModel : ObservableObject{
    static let emojs = ["✈️","🚇","🚗","🛻","🚑","🚔","🚲","🚝","🚁","🚀","🏍","🚚"
                         ,"🚤","🛶","🛩"]
    static func createMemoryGameModel() -> MemoryGameModel<String>{
            MemoryGameModel<String>(numberOfPairCard: 6){ pairindex in
                emojs[pairindex]
            }
    }
    
    @Published var model : MemoryGameModel<String> = createMemoryGameModel()//发布事件
    
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
