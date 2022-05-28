//
//  MemoryGameModel.swift
//  memorized
//
//  Created by 彭婷 on 2022/5/14.
//

import Foundation
struct MemoryGameModel<CardContent> where CardContent : Equatable{
    private(set) var cards : Array<Card>
    
    private var theOnlyOneIsFaceUp: Int?{
        get {cards.indices.filter({cards[$0].isFaceUp }).oneAndOnly}
        set {cards.indices.forEach{cards[$0].isFaceUp = ($0 == newValue)}}
    }
        
    mutating func choose(_ card : Card){
        if let choosedIndex = cards.firstIndex(where: {$0.id == card.id}),
           !cards[choosedIndex].isFaceUp,
           !cards[choosedIndex].isMatched
        {
            if let poententIndex = theOnlyOneIsFaceUp {
                if cards[theOnlyOneIsFaceUp!].content == cards[choosedIndex].content {
                    cards[choosedIndex].isMatched = true
                    cards[poententIndex].isMatched = true
                }
                
                cards[choosedIndex].isFaceUp = true
            }else{
                theOnlyOneIsFaceUp = choosedIndex
            }
        }
    }
    
    mutating func shuffle(){
        cards.shuffle()
    }
    
    init(numberOfPairCard:Int,createCardContent:(Int) -> CardContent){
        cards = Array<Card>()
        for pairIndex in 0..<numberOfPairCard {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content,id: pairIndex * 2))
            cards.append(Card(content: content,id: pairIndex * 2+1))
        }
        
        cards.shuffle()
    }
 
    struct Card : Identifiable{
        var isFaceUp = false {
                didSet {
                    if isFaceUp {
                        startUsingBonusTime()
                    } else {
                        stopUsingBonusTime()
                    }
                }
            }
            //增加属性观察者，一但匹配停止计时
            var isMatched = false {
                didSet {
                    stopUsingBonusTime()
                }
            }

        var content : CardContent
        var id : Int
        
        // MARK: - 计时器算法
            
            //额外的时间限制，超时后奖励为0
            var bonusTimeLimit: TimeInterval = 6
            
            // 这张牌朝上多久了
            private var faceUpTime: TimeInterval {
                if let lastFaceUpDate = self.lastFaceUpDate {
                    return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
                } else {
                    return pastFaceUpTime
                }
            }
            // 上次这张牌是面朝上的(现在仍然是面朝上)
            var lastFaceUpDate: Date?
            //这张卡过去的累计时间 (例如，如果当前是正面，则不包含当前时间)
            var pastFaceUpTime: TimeInterval = 0
            
            // 还有多少时间奖金就到期了
            var bonusTimeRemaining: TimeInterval {
                max(0, bonusTimeLimit - faceUpTime)
            }
            // 剩余奖金时间的百分比
            var bonusRemaining: Double {
                (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
            }
            // 是否在奖金期间匹配该卡
            var hasEarnedBonus: Bool {
                isMatched && bonusTimeRemaining > 0
            }
            // 无论我们目前是否正面向上，还是无可匹敌的，奖金窗口还没有用完
            var isConsumingBonusTime: Bool {
                isFaceUp && !isMatched && bonusTimeRemaining > 0
            }
            
            // 当卡片转换为正面状态时调用开始计时
            private mutating func startUsingBonusTime() {
                if isConsumingBonusTime, lastFaceUpDate == nil {
                    lastFaceUpDate = Date()
                }
            }
            // 当牌面朝下(或匹配)时调用 暂时/停止计时
            private mutating func stopUsingBonusTime() {
                pastFaceUpTime = faceUpTime
                self.lastFaceUpDate = nil
            }

       
    }
}
    
extension Array {
    var oneAndOnly : Element? {
        if count == 1 {
            return first
        }else{
            return nil
        }
    }
}
