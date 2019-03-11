//
//  Region.swift
//  TagViewDemo
//
//  Created by Stan Wu on 3/9/19.
//  Copyright © 2019 Stan Wu. All rights reserved.
//

import UIKit

class Region: NSObject {
    var rects = [CGRect]()
    
    override init() {
        super.init()
    }
    
    convenience init(_ region: Region) {
        self.init()
        
        rects = region.rects
    }
    
    convenience init(_ rect: CGRect) {
        self.init()
        
        rects = [rect]
    }
    
    convenience init(_ left: CGFloat, _ top: CGFloat, _ right: CGFloat, _ bottom: CGFloat) {
        self.init()
        
        rects = [CGRect(x: left, y: top, width: right - left, height: bottom - top)]
    }
}

// MARK: - Operators
extension Region {
    func contains(_ x: CGFloat, _ y: CGFloat) -> Bool {
        return true
    }
    
    @discardableResult 
    func op(_ rect: CGRect, _ op: Region.Op) -> Bool {
        switch op {
        case .DIFFERENCE:
            var _rects = [CGRect]()
            for container in self.rects {
                _rects.append(contentsOf: difference(container, rect))
            }
            rects = _rects
            
            return rects.isEmpty
        default: ()
        }
        return false
    }
    
    private func difference(_ container: CGRect, _ rect: CGRect) -> [CGRect] {
        let intersect = container.intersection(rect)
        
        guard !intersect.isNull && intersect.size.width > 0 && intersect.size.height > 0 else {
            return [container]
        }
        
        let xs = [container.origin.x, intersect.origin.x, intersect.origin.x + intersect.size.width, container.origin.x + container.size.width]
        let ys = [container.origin.y, intersect.origin.y, intersect.origin.y + intersect.size.height, container.origin.y + container.size.height]
        
        var results = [CGRect]()
        
        for ix in 0 ..< 3 {
            for iy in 0 ..< 3 {
                if 1 == ix && 1 == iy {
                    continue
                }
                
                let r = CGRect(x: xs[ix], y: ys[iy], width: xs[ix+1] - xs[ix], height: ys[iy+1] - ys[iy])
                if r.width > 0 && r.height > 0 {
                    results.append(r)
                }
            }
        }
        
        return results
    }
}

// MARK: - Enum
extension Region {
    enum Op {
        case DIFFERENCE
        case INTERSECT
        case REPLACE
        case REVERSE_DIFFERENCE
        case UNION
        case XOR
    }
}
