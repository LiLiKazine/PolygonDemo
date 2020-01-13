//
//  PolygonView.swift
//  PolygonDemo
//
//  Created by Li Sheng on 2020/1/13.
//  Copyright © 2020 Li Sheng. All rights reserved.
//

import UIKit

class PolygonView: UIView {
    
    private(set) var contentRect: CGRect!
//    private(set) var pointsSubject = BehaviorSubject<[CGPoint]>(value: [])
    private var pentagonCenter: CGPoint!
    private var centerX: CGFloat!
    private var centerY: CGFloat!
    private var radius: CGFloat!
    private var mine: [CGFloat] = Array<CGFloat>(repeating: 1.0, count: 0)
    private var avrg: [CGFloat] = Array<CGFloat>(repeating: 1.0, count: 0)
    
    func set(mine: [CGFloat], avrg: [CGFloat]) {
        self.mine = mine
        self.avrg = avrg
        setNeedsDisplay()
    }
    
    private func initialize() {
        backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func draw(_ rect: CGRect) {
        let padding: CGFloat = 5.0
        let rh = (rect.width - 2 * padding) * 0.5 / cosin(18.0)
        let rv = (rect.height - 2 * padding) / (cosin(36.0) + 1.0)
        radius = min(rh, rv)
        centerX = rect.midX
        centerY = rect.minY + rv + padding
        contentRect = CGRect(x: centerX - radius * cosin(18.0), y: centerY - radius, width: radius * cosin(18.0) * 2, height: radius + radius * cosin(36.0))
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        context.restoreGState()
        for i in 0...4 {
            let r = radius - CGFloat(i) / 5.0 * radius
            drawPentagon(context, radius: Array(repeating: r, count: 5),
                         colorBegin: UIColor.hex(0x586685).withAlphaComponent(0.1).cgColor,
                         colorEnd: UIColor.hex(0x2D3952).withAlphaComponent(0.1).cgColor)
        }
        drawSprayLine(context)
        let r = radius!
        drawPentagon(context, radius: avrg.map { $0 * r }, colorBegin: .hex(0x366F5A, alpha: 0.4),
                     colorEnd: .hex(0x366F5A, alpha: 0.4),
                     lineColor: .hex(0x366F5A),
                     pointsColor: Array(repeating: .hex(0x366F5A), count: 5))
        let dotsColor: [CGColor] = (mine - avrg)
            .map { b -> CGColor in
                return b ? .hex(0xFFAC1E) : .hex(0xFF3A79)
        }
        drawPentagon(context, radius: mine.map { $0 * r },
                     colorBegin: .hex(0x4EFFFB, alpha: 0.4),
                     colorEnd: .hex(0x2678FF, alpha: 0.4),
                     lineColor: .hex(0x57D0FF),
                     pointsColor: dotsColor)
    }
    
    private func drawSprayLine(_ context: CGContext) {
        context.saveGState()
        let path = UIBezierPath()
        let points = makePoints(Array(repeating: radius, count: 5))
        for i in 0...4 {
            path.move(to: CGPoint(x: centerX, y: centerY))
            path.addLine(to: points[i])
        }
        context.setLineWidth(1.0)
        context.addPath(path.cgPath)
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.1).cgColor)
        context.strokePath()
        context.restoreGState()
    }
    
    private func drawPentagon(_ context: CGContext, radius: [CGFloat], colorBegin: CGColor, colorEnd: CGColor, lineColor: CGColor? = nil, pointsColor: [CGColor] = []) {
        guard radius.count == 5  else { return }
        
        let points = makePoints(radius)
        let path = UIBezierPath()
        for i in 0..<points.count {
            if i == 0 {
                path.move(to: points[i])
            } else {
                path.addLine(to: points[i])
            }
        }
        path.close()
        if lineColor != nil {
            context.saveGState()
            context.addPath(path.cgPath)
            context.clip()
            context.addPath(path.cgPath)
            context.setLineWidth(6.0)
            context.setStrokeColor(lineColor!)
            context.strokePath()
            context.restoreGState()
        }
        context.saveGState()
        context.addPath(path.cgPath)
        context.clip()
        let colors = [colorBegin, colorEnd]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocation: [CGFloat] = [0.0, 1.0]
        let gradiant = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocation)!
        let startPoint = CGPoint(x: contentRect.midX, y: contentRect.minY)
        let endPoint = CGPoint(x: contentRect.midX, y: contentRect.maxY)
        context.drawLinearGradient(gradiant, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
        if pointsColor.count == 5 {
            let ps = makePoints(radius.map({ $0-1.5 }))
            for i in 0..<pointsColor.count {
                context.saveGState()
                let p = ps[i]
                let dot = UIBezierPath(ovalIn: CGRect(x: p.x - 5, y: p.y - 5, width: 10, height: 10))
                context.addPath(dot.cgPath)
                context.setFillColor(pointsColor[i])
                context.fillPath()
                context.restoreGState()
            }
        }
    }
    
    private func makePoints(_ rs: [CGFloat]) -> [CGPoint] {
        guard rs.count == 5 else { return [] }
        let points = [top(rs[0]), topRight(rs[1]), bottomRight(rs[2]), bottomLeft(rs[3]), topLeft(rs[4])]
        if rs.reduce(0, +) == radius * 5 {
//            pointsSubject.onNext(points)
        }
        return points
    }
    
    func top(_ r: CGFloat) -> CGPoint {
        return CGPoint(x: centerX, y: centerY - r)
    }
    
    func topRight(_ r: CGFloat) -> CGPoint {
        return CGPoint(x: centerX + r * cosin(18.0), y: centerY - r * cosin(72.0))
    }
    
    func bottomRight(_ r: CGFloat) -> CGPoint {
        return CGPoint(x: centerX + r * cosin(54.0), y: centerY + r * cosin(36.0))
    }
    
    func bottomLeft(_ r: CGFloat) -> CGPoint {
        return CGPoint(x: centerX - r * cosin(54.0), y: centerY + r * cosin(36.0))
    }
    
    func topLeft(_ r: CGFloat) -> CGPoint {
        return CGPoint(x: centerX - r * cosin(18.0), y: centerY - r * cosin(72.0))
    }
    
    func cosin(_ c: Double ) -> CGFloat {
        return CGFloat(cos(c * Double.pi / 180.0))
    }
}

fileprivate func -(l: Array<CGFloat>, r: Array<CGFloat>) -> Array<Bool> {
    return l.enumerated()
        .map { (i, val) -> Bool in
            if i < r.count {
                return l[i] > r[i]
            }
            return true
    }
}
