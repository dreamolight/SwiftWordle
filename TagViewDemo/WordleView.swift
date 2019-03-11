//
//  WordleView.swift
//  TagViewDemo
//
//  Created by Stan Wu on 3/8/19.
//  Copyright © 2019 Stan Wu. All rights reserved.
//

import UIKit

class WordleView: UIView {
    private let canvas = UIImageView()
    
    var tags = [String]() {
        didSet {
            reTypeSetting()
        }
    }
    let minTextSize: CGFloat = 4
    
    let primaryTagStrokeWidth: CGFloat = 0.5
    let primaryTagColor = UIColor(white: 0.2, alpha: 1)
    
    let secondaryTagStrokeWidth: CGFloat = 2
    let secondaryTagColor = UIColor(white: 0.6, alpha: 1)
    
    var myregion: Region?
    
    private func reTypeSetting() {
        if !tags.isEmpty && frame.width > 0 && frame.size.height > 0 {
            typeSetting()
        }
    }
    
    override var frame: CGRect {
        didSet {
            reTypeSetting()
        }
    }
    
    private func typeSetting() {
        canvas.frame = self.bounds
        if canvas.superview == nil {
            self.addSubview(canvas)
        }
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        
        let region = myregion ?? Region(0, 0, self.frame.width, self.frame.height)
        
        var tagModels = [TagModel]()
        
        tagModels.append(contentsOf: primaryTypeSetting(region))
        tagModels.append(contentsOf: secondaryTypeSetting(region))
        tagModels.append(contentsOf: edgeTypeSetting(region))
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        for model in tagModels {
            drawTag(ctx, model)
        }
        
        if let img = UIGraphicsGetImageFromCurrentImageContext() {
            canvas.image = img
        }
        
        UIGraphicsEndImageContext()
    }
    
    private func primaryTypeSetting(_ region: Region) -> [TagModel] {
        var result = [TagModel]()
        let textMaxSize = calcMaxTextSize(self.frame.size)
        for (i, tag) in tags.enumerated() {
            var textSize = 0 == i ? textMaxSize : (textMaxSize - minTextSize)
            while textSize >= minTextSize {
                if let tagModel = innerTypeSetting(region, textSize, primaryTagStrokeWidth, primaryTagColor, tag) {
                    result.append(tagModel)
                    break
                }
                
                textSize -= minTextSize
            }
        }
        
        return result
    }
    
    func secondaryTypeSetting(_ region: Region) -> [TagModel] {
        var result = [TagModel]()
        
        var textSize = calcMaxTextSize(self.frame.size) - minTextSize * 2
        if textSize < minTextSize {
            textSize = minTextSize
        }
        
        while true {
            var added = false
            for tag in tags {
                if let tagModel = innerTypeSetting(region, textSize, 0, secondaryTagColor, tag) {
                    added = true
                    result.append(tagModel)
                }
            }
            if !added {
                textSize -= minTextSize
            }
            if textSize < minTextSize {
                break
            }
        }
        
        return result
    }
    
    func edgeTypeSetting(_ region: Region) -> [TagModel] {
        var result = [TagModel]()
        
        for rect in region.rects {
            let w = rect.size.width
            let h = rect.size.height
            
            if w >= minTextSize && h >= minTextSize {
                var maxDrawTextLength = max(w, h) / minTextSize
                var text: String!
                while maxDrawTextLength >= 1 && text == nil {
                    text = tags.filter { $0.lengthOfBytes(using: .utf8)  == Int(maxDrawTextLength) }.first
                    maxDrawTextLength -= 1
                }
                
                if text != nil {
                    result.append(TagModel(rect: rect, textColor: secondaryTagColor, textSize: minTextSize, strokeWidth: 0, text: text, isVertical: false))
                }
            }
        }
        
        return result
    }
    
    func innerTypeSetting(_ region: Region, _ textSize: CGFloat, _ strokeWidth: CGFloat, _ color: UIColor, _ text: String) -> TagModel? {
        var result: TagModel?
        
        let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: textSize)])
        let w, h : CGFloat
        
        var isVertical = false
        if arc4random() % 3 == 0 {
            w = size.height
            h = size.width
            isVertical = true
        } else {
            w = size.width
            h = size.height
        }
        
        for rect in region.rects {
            if rect.size.width >= w && rect.size.height >= h {
                let left, top: CGFloat
                if rect.width - w < minTextSize {
                    left = rect.minX
                } else {
                    left = CGFloat(arc4random() % UInt32((rect.width - w) / minTextSize) + 1) * minTextSize + rect.minX
                }
                
                if rect.height - h < minTextSize {
                    top = rect.minY
                } else {
                    top = CGFloat(arc4random() % UInt32((rect.height - h) / minTextSize) + 1) * minTextSize + rect.minY
                }
                
                let r = CGRect(x: left, y: top, width: w, height: h)
                region.op(r, .DIFFERENCE)
                result = TagModel(rect: r, textColor: color, textSize: textSize, strokeWidth: 0, text: text, isVertical: isVertical)
                
                break
            }
        }
        
        return result
    }
    
    func calcMaxTextSize(_ size: CGSize) -> CGFloat {
        var len = 0
        for tag in tags {
            let _l = tag.characters.count
            if _l > len {
                len = _l
            }
        }
        
        let _min = min(size.width, size.height)
        let tempSize = _min * 0.8 / CGFloat(len)
        
        return tempSize - CGFloat(Int(tempSize) % Int(minTextSize))
    }
    
    private func drawTag(_ ctx: CGContext, _ tag: TagModel) {
         //Debug only
//        let drawRect = tag.rect
//        let colors = [UIColor.black, UIColor.red, UIColor.green, UIColor.blue]
//        let c = colors[Int(arc4random()) % colors.count]
//        ctx.setStrokeColor(c.cgColor)
//        ctx.stroke(drawRect)
 
        tag.text.drawAt(ctx, rect: tag.rect, angle: !tag.isVertical ? 0 : CGFloat.pi / 2, font: UIFont.systemFont(ofSize: tag.textSize), color: tag.textColor)
        
        /* Draw with point
        var pt = drawRect.origin
//        pt.x = frame.width - pt.x
        pt.y = frame.height - pt.y
        
        tag.text.drawAt(ctx, pt: pt, angle: drawRect.width > drawRect.height ? 0 : -CGFloat.pi / 2, font: UIFont.systemFont(ofSize: tag.textSize), color: c)
 */
    }
}

struct TagModel {
    var rect: CGRect
    var textColor: UIColor
    var textSize: CGFloat
    var strokeWidth: CGFloat
    var text: String
    var isVertical = false
}

extension String {
    func drawAt(_ ctx: CGContext, pt: CGPoint, angle: CGFloat, font: UIFont, color: UIColor) {
        let textSize = (self as NSString).size(withAttributes: [.font: font])
        ctx.saveGState()
        
        let t = CGAffineTransform(translationX: pt.x, y: pt.y)
        let r = CGAffineTransform(rotationAngle: angle)
        ctx.concatenate(t)
        ctx.concatenate(r)
        
        (self as NSString).draw(at: CGPoint(x: -textSize.width/2, y: -textSize.height/2), withAttributes: [.font: font, .foregroundColor: color])
        
        ctx.restoreGState()
    }
    
    func drawAt(_ ctx: CGContext, rect: CGRect, angle: CGFloat, font: UIFont, color: UIColor) {
        let textSize = (self as NSString).size(withAttributes: [.font: font])
        ctx.saveGState()
        
        let t = CGAffineTransform(translationX: rect.minX + rect.width / 2, y: rect.minY + rect.height / 2)
        let r = CGAffineTransform(rotationAngle: angle)
        ctx.concatenate(t)
        ctx.concatenate(r)
        
        var _rect = rect
        if angle > 0 {
            _rect.origin = CGPoint(x: -rect.height / 2, y: -rect.width / 2)
        } else {
            _rect.origin = CGPoint(x: -rect.width / 2, y: -rect.height / 2)
        }
        
        _rect.size.width *= 5
        _rect.size.height *= 5
        
        (self as NSString).draw(in: _rect, withAttributes: [.font: font, .foregroundColor: color])
        
        ctx.restoreGState()
    }
}
