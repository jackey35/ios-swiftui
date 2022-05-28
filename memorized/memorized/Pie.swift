//
//  Pie.swift
//  memorized
//
//  Created by 彭婷 on 2022/5/20.
//

import SwiftUI
struct Pie:Shape {
    
    //设置被动画化数据为2组Double
    var animatableData: AnimatablePair<Double,Double>{
        get{
            //通过AnimatablePair返回开始角度的弧度与结束角度的弧度值
            AnimatablePair(startAngle.radians,endAngle.radians)
        }
        set{
            //通过newValue里被动画化的值不断为startAngle与endAngle赋值
            startAngle = Angle.radians(newValue.first)
            endAngle = Angle.radians(newValue.second)
        }
    }

    
    var startAngle:Angle //开始角度
    var endAngle:Angle//结束角度
    var clockwise = false //是否顺时针
    //使用path画图
    func path(in rect:CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)//定义中心
        let radius = min(rect.width,rect.height) / 2 //定义半径
        //定义开始的坐标点
        let start = CGPoint(
            x:center.x + radius * CGFloat(cos(startAngle.radians)),//使用cos找到x坐标
            y: center.y + radius * CGFloat(sin(startAngle.radians))//使用sin找到y坐标
        )
        var p = Path()//定义p为路径
        p.move(to: center)//p移到中心
        p.addLine(to: start)//从中心画一条线到开始位置
        //添加一个圆弧的路径，指定一个半径和角度。
        p.addArc(
            center: center,//圆弧中心
            radius: radius,//半径大小
            startAngle: startAngle,//开始位置角度
            endAngle: endAngle,//结束位置角度
            clockwise: !clockwise//按哪个时针方向（反转适应语义）
        )
        p.addLine(to: center)//画到中心位置
        return p
    }
}
