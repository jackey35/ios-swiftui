//
//  SwiftUIView.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/23.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    //从ViewModel获取要更新的值
    @ObservedObject var document:EmojiArtDocument
    var body: some View {
        VStack{
            docmentBody//画布主体
            palette//可选择的表情
        }
    }
    //先使用一个黄色填充画布
    var docmentBody: some View{
        
        GeometryReader {geometry in
            ZStack{
                //Color.yellow//这里将使用ForEach遍历Model里的表情并根据信息展示出来
                Color.white.overlay{
                    //使用背影图片覆盖，图片来源VM
                    OptionalImage(uiImage: document.backgroundImage).scaleEffect(zoomScale)
                    //将背影图片定位到画布中间
                        .position(convertPointToCGPoint((0,0), in: geometry))
                }
                .gesture(doubleTapToZoom(in: geometry.size))
                         
                if document.backgroundImageFetchStatus == .fetching{
                    ProgressView().scaleEffect(2)
                } else{
                    ForEach(document.emojis) { emoj in
                        Text(emoj.text).scaleEffect(zoomScale)
                            .font(.system(size: fontSize(for : emoj)))
                            .position(positionSize(for : emoj,geometry : geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText,.url,.image ], isTargeted: nil){providers,location in
                drop(providers: providers, at: location, in: geometry)
                
            }
            .gesture(zoomPanGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    @State var steadyPanOffSet : CGSize = CGSize.zero
    @GestureState var gesturePanOffSet : CGSize = CGSize.zero
    private var panOffSet : CGSize {
        (steadyPanOffSet + gesturePanOffSet) * zoomScale
    }
    
    //拖动手势
    private func zoomPanGesture() -> some Gesture {
        DragGesture().updating($gesturePanOffSet) { latestPanOffSet,gesturePanOffSet,transaction in
            gesturePanOffSet = latestPanOffSet.translation / zoomScale
        }
        .onEnded() { finalDragOffSet in
            steadyPanOffSet = steadyPanOffSet + (finalDragOffSet.translation / zoomScale)
        }
    }
    @State var steadyZoomScale : CGFloat = 1
    @GestureState var gestureZoomScale : CGFloat = 1
    private var zoomScale : CGFloat {
        steadyZoomScale * gestureZoomScale
    }
    
    //双指拖动背景图改变大小
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale){ latestZoomGesture, gestureZoomScale,transaction in
                gestureZoomScale = latestZoomGesture
            }//拖动过程一直要改变位置
            .onEnded { gestureScaleAtEnd in
                steadyZoomScale *= gestureScaleAtEnd
            }
    }
    
    //双击改变背景图大小
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded{
                withAnimation{
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    private func zoomToFit(_ image : UIImage?,in size : CGSize){
        if let image = image ,image.size.width > 0 ,image.size.height > 0 ,size.width > 0, size.height > 0 {
            let hZoom = size.height / image.size.height
            let wZoom = size.width / image.size.width
            steadyZoomScale = min(hZoom, wZoom)
        }
    }
    
//    private func drop(providers: [NSItemProvider],at location: CGPoint,geometry: GeometryProxy) -> Bool{
//        return providers.loadObjects(ofType: String.self){string in
//            if let emoji = string.first,emoji.isEmoji {
//                docment.addEmojis(String（emoji), at:convertToEmojiCoordinate(location, in: geometry), size:40)
//            }
//        }
//    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self){url in
            
            document.setBackground(.url(url.imageURL))
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self){image in
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(imageData))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmojis(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: CFloat(DrawingConstants.defaultEmojiFontSize / zoomScale)
                    )
                }
            }
        }
        
        return found
    }

    private func convertToEmojiCoordinates(_ location:CGPoint,in geometry : GeometryProxy) -> (x: Int,y: Int){
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x:(location.x - panOffSet.width - center.x) * zoomScale,
            y:(location.y - panOffSet.height - center.y) * zoomScale
        )
        
        return (Int(location.x),Int(location.y))
    }
    
    private func positionSize(for emoji : EmojiArtModel.Emoji,geometry : GeometryProxy) -> CGPoint{
        return convertPointToCGPoint((emoji.x,emoji.y), in : geometry)
    }
    
    private func convertPointToCGPoint(_ location:(x:Int, y: Int),in geometry : GeometryProxy) -> CGPoint{
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x:center.x + CGFloat(location.x) * zoomScale + panOffSet.width,
            y:center.y + CGFloat(location.y) * zoomScale + panOffSet.height
        )
    }
    private func fontSize(for emoj : EmojiArtModel.Emoji) -> CGFloat{
        return CGFloat(emoj.size)
    }
    //使用横向滚动视图展示测试表情
    var palette: some View{
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: 40))
    }
    let testEmojis = "😀😷🦠💉👻👀🐶🌲🌎🌞🔥🍎⚽️🚗🚓🚲🛩🚁🚀🛸🏠⌚️🎁🗝🔐❤️⛔️❌❓✅⚠️🎶➕➖🏳️"
}
//横向滚动视图
struct ScrollingEmojisView:View {
    let emojis:String
    var body: some View{
        ScrollView(.horizontal){
            HStack{
                //emojis.map是学习知识点
                //通过map{ $0 }将字符串映射成一个字符串数组
                //let $0: String.Element所以需要String($0)
                ForEach(emojis.map{ String($0) },id: \.self){ emoji in
                    Text(emoji)
                        .onDrag{NSItemProvider(object:emoji as NSString)}
                }
            }
        }
    }
    
}

private struct DrawingConstants{
    static let defaultEmojiFontSize: CGFloat = 40//Emoji缩放比例

}
