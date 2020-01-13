//
//  Tools.swift
//  PolygonDemo
//
//  Created by Li Sheng on 2020/1/13.
//  Copyright © 2020 Li Sheng. All rights reserved.
//
import UIKit

extension UIColor {
    static func hex(_ hex: Int, alpha: CGFloat = 1) -> UIColor {
        return UIColor(hex: hex, alpha: alpha)
    }
    convenience init(hex: Int, alpha: CGFloat = 1) {
        func f(_ hex: Int) -> CGFloat { return CGFloat(hex % 0x100) / CGFloat(0xFF) }
        let b = f(hex)
        let g = f(hex >> 8)
        let r = f(hex >> 16)
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    convenience init(string s: String) {
        self.init(hex: Int(s, radix: 16) ?? 0)
    }
}

extension CGColor {
    static func hex(_ hex: Int) -> CGColor {
        return UIColor(hex: hex).cgColor
    }
    
    static func hex(_ hex: Int, alpha: CGFloat) -> CGColor {
        return UIColor(hex: hex).withAlphaComponent(alpha).cgColor
    }
}
