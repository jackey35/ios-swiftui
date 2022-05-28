//
//  CustomCardView.swift
//  memorized
//
//  Created by 彭婷 on 2022/5/20.
//

import SwiftUI

//自定义view
struct CustomCardView<Item,ItemView>: View where ItemView:View,Item:Identifiable {
    var cardItems : [Item]
    var aspectRation : CGFloat
    var content : (Item) -> ItemView
    
    init(cardItems:[Item],aspectRation:CGFloat,@ViewBuilder content:@escaping (Item) -> ItemView) {
        self.cardItems = cardItems
        self.aspectRation = aspectRation
        self.content = content
    }
    
    var body: some View {
        GeometryReader{geometry in
            VStack{
                Spacer()
                let width = widthThatFits(itemCount: cardItems.count, in: geometry.size, itemAspectRatio: aspectRation)
                LazyVGrid(columns: [adaptiveGridItem(width:width)]){
                    ForEach(cardItems){cardItem in
                        content(cardItem).aspectRatio(aspectRation,contentMode: .fit)
                        
                    }
                }
                Spacer()
            }
           
            
        }
    }
    
    private func adaptiveGridItem(width : CGFloat) -> GridItem{
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    //卡片宽度计算(符合屏幕宽度)
        private func widthThatFits(itemCount:Int,in size:CGSize,itemAspectRatio:CGFloat) -> CGFloat{
            var columnCount = 1 //一行显示几列？
            var rowCount = itemCount //格子数(一格一个卡片）
            //通过循环对比算出来显示让一行显示几列需要的合适宽度
            repeat{
                let itemWidth = size.width / CGFloat(columnCount)//根据上级容器的宽得出单个卡片的宽
                let itemHeight = itemWidth / itemAspectRatio//根据显示比较得出卡片的高
                if CGFloat(rowCount) * itemHeight < size.height{
                    break //格子数*卡片高的情况下小于了容器高度
                }
                columnCount += 1 //满足条件 +1
                //重新计算格子数量
                rowCount = (itemCount + (columnCount - 1)) / columnCount
            } while columnCount < itemCount //满足列 > 卡片数则继续循环
                //防止列数大于实际的卡片数量
                if columnCount > itemCount{ //如果 列 > 卡片数
                    columnCount = itemCount //列数与卡片一样多(单行显示)
                }
            //返回单个卡片需要的宽度 (整体宽度 / 计算后的列数)
            return floor(size.width / CGFloat(columnCount))//核心就是要算出来一行显示几列的宽度
        }

}

//struct CustomCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomCardView()
//    }
//}
