//
//  ContentView.swift
//  memorized
//
//  Created by 彭婷 on 2022/5/9.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var emojCardGameViewModel : EmojCardGameViewModel
    @State private var deal = Set<Int>()
    
    func dealCard(_ card : MemoryGameModel<String>.Card){
        deal.insert(card.id)
    }
    
    func isUnDeal(_ card : MemoryGameModel<String>.Card) -> Bool{
        !deal.contains(card.id)
    }
  
    //@State var emojiCount = 4
    var body: some View {
        
        ZStack(alignment: .bottom){
            VStack{
                gameBodyView
                
                HStack{
                    restartView
                    Spacer()
                    shuffleView
                }.padding(.horizontal)
                
            }
            deckCardView
        }
        
        .padding()
        
    
        
    }
    
    @Namespace private var dealCardNameSpace
    
    var gameBodyView : some View {
        CustomCardView(cardItems: emojCardGameViewModel.cards, aspectRation: 2/3 ){card in
            if isUnDeal(card) || ( card.isMatched && !card.isFaceUp ) {
                Color.clear
            } else {
                CardView(card:card).padding(4)
                    .zIndex(zIndex(for:card))//控制重叠视图的显示顺序。
                    .matchedGeometryEffect(id: card.id, in: dealCardNameSpace)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 1)){
                                    emojCardGameViewModel.choose(card)
                                }
                                
                            }
            }
        }
//        .onAppear(){
//            withAnimation{
//                for card in emojCardGameViewModel.cards{
//                    dealCard(card)
//                }
//            }
//
//        }
        .foregroundColor(.red)
            
    }
    
    var shuffleView : some View{
        Button("Shuffel") {
            withAnimation{
                emojCardGameViewModel.shuffle()
            }
        }
    }
    
    var deckCardView : some View {
        ZStack {
            ForEach(emojCardGameViewModel.cards.filter(isUnDeal)){card in
                CardView(card: card)
                    .zIndex(zIndex(for:card))//控制重叠视图的显示顺序。
                    .matchedGeometryEffect(id: card.id, in: dealCardNameSpace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
            }
        }
        .frame(width: DrawingConstants.undealWidth, height: DrawingConstants.undealHight)
        .foregroundColor(.red)
        .onTapGesture {
            for card in emojCardGameViewModel.cards{
                    withAnimation(delayCard(for: card)){ //通过当前card计算出需要延时多久
                        dealCard(card)//通过延时做为计时器，让卡片慢慢进入集合
                    }
                }
            
        }
    }
    
    var restartView : some View{
        Button("Restart") {
            withAnimation{
                deal = []
                emojCardGameViewModel.restart()
            }
        }
    }
    func delayCard(for card: MemoryGameModel<String>.Card) -> Animation{
        var delay : Double = 0.0
        if let index = emojCardGameViewModel.cards.firstIndex(where: {$0.id == card.id}){
                //算出当前卡片需要延时多少
                delay = Double(index) * (DrawingConstants.totalDealDuration / Double(emojCardGameViewModel.cards.count))
        }
                
        return Animation.easeInOut(duration: DrawingConstants.cardDuration).delay(delay)
    }
    
    //计算出当前卡片的合适zIndex值
    private func zIndex(for card:MemoryGameModel<String>.Card) -> Double{
        -Double(emojCardGameViewModel.cards.firstIndex(where: {$0.id == card.id}) ?? 0)
    }

}


struct CardView : View{
    let card:MemoryGameModel<String>.Card
    @State private var animatedBonusRemaining:Double = 0//初始化为0
    
        var body: some View{
            
            
            GeometryReader{ geometry in
                ZStack{
                    //这里的判断卡片是否被翻转已被移除，将应用在Cardify里
                    
                    
                    Group{
                        if card.isConsumingBonusTime{
                            Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-animatedBonusRemaining)*360-90))
                                .onAppear{
                                    animatedBonusRemaining = card.bonusRemaining//剩余奖金时间的百分比
                                    //利用duration时间切片的属性，实现倒计时机制(还有多少时间奖金就到期了)
                                    withAnimation(.linear(duration: card.bonusTimeRemaining)){
                                        animatedBonusRemaining = 0
                                    }
                                }
                        }else{
                            Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-card.bonusRemaining)*360-90))
                        }
                    }.padding(5).opacity(0.5)

                    Text(card.content)
                        .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                        .font(font(in: geometry.size))
                        .scaleEffect(scale(thatFits: geometry.size))
                }
                //引用自己定义的Cardify并传入判断参数
                .modifier(CardifyViewModify(isFaceUp: card.isFaceUp))
            }
        }
        //返回Emoji的大小设置
        private func font(in size:CGSize) -> Font{
            Font.system(size: DrawingConstants.fontSize)
        }
    
        //计算出当前字体需要缩放的比例
        private func scale(thatFits size:CGSize) -> CGFloat{
            min(size.width,size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
        }
       
    
}
//参数控制器移出Cardify部分
private struct DrawingConstants{
    static let fontScale: CGFloat = 0.7//Emoji缩放比例
    static let fontSize: CGFloat = 32//固定Emoji的字体大小
    static let undealHight: CGFloat = 90
    static let undealWidth: CGFloat = undealHight * 2/3
    static let totalDealDuration :Double = 6
    static let cardDuration :Double = 1
}

struct ContentView_Previews: PreviewProvider {
   
    static var previews: some View {
        let game = EmojCardGameViewModel()
        game.choose(game.cards.first!)
        return ContentView(emojCardGameViewModel: game)
    }
}

