//
//  SwiftUIView.swift
//  EmojiArt
//
//  Created by 彭婷 on 2022/5/23.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    var defaultEmojFontSize : CGFloat = 40
    //从ViewModel获取要更新的值
    @ObservedObject var document:EmojiArtDocument
    var body: some View {
        VStack{
            docmentBody//画布主体
            PaletteChooserView(emojFontSize: defaultEmojFontSize)//可选择的表情
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
            .alert(item: $alertToShow) { alertToShow in
                
                alertToShow.alert()//闭包里必须返回一个alert，默认情况alertToShow == nil
            }
            //当backgroundImageFetchStatus状态发生变化时开始检测是否需要触发警告弹出
            .onChange(of: document.backgroundImageFetchStatus) { status in
                //当状态为failed时
                switch status {
                    case .failed(let url):
                        showBackgroundImageFetchFailedAlert(url)//调用此方法显示警告,这里alertToShow被赋值了，所以警告将显示
                    default:
                        break
                }
            }

        }
    }
    
    @State private var alertToShow: IdentifiableAlert?//定义一个空的IdentifiableAlert来源于扩展的警告弹出格式
     //警告内容格式
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        //alertToShow的值将不是nil，这里将触发alert()
        alertToShow = IdentifiableAlert(id: "抓取失败: " + url.absoluteString, alert: {
            Alert(
                title: Text("背景图像获取"),
                message: Text("无法加载图像:(url)."),
                dismissButton: .default(Text("OK"))
            )
        })
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

}


private struct DrawingConstants{
    static let defaultEmojiFontSize: CGFloat = 40//Emoji缩放比例

}
