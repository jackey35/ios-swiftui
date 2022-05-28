//
//  CardifyViewModify.swift
//  memorized
//
//  Created by 彭婷 on 2022/5/21.
//

import SwiftUI
struct CardifyViewModify : AnimatableModifier{
    
    init(isFaceUp : Bool){
        rotation = isFaceUp ? 0 : 180
    }
    
    
    var animatableData: Double {
        get { rotation }
        set {rotation = newValue}
    }
    
    var rotation : Double
    
    
    func body( content : Content ) -> some View{
        ZStack{
            let shap = RoundedRectangle(cornerRadius:CardViewConstant.cornerRaius)
            
            if rotation < 90 {
                
                shap.fill().foregroundColor(.white)
                shap.strokeBorder(lineWidth: CardViewConstant.lineWidth)
                
                
            }else{
                shap.fill()
            }
            content.opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation ), axis: (0,1,0))
    }
    private struct CardViewConstant{
        static let cornerRaius : CGFloat = 10
        static let lineWidth : CGFloat = 3
       // static let fontScale : CGFloat = 0.7
    }
}


