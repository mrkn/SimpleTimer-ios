//
//  TimerView.swift
//  SimpleTimer
//
//  Created by Kenta Murata on 2018/08/25.
//  Copyright © 2018 mrkn.jp. All rights reserved.
//

import UIKit

enum TimerViewError: Error {
    case valueOutOfBounds
}

class TimerView: UIView {
    public let maxSeconds: UInt = 60*60
    public let displayStep: UInt = 5

    private let labelFont = UIFont(name: "HelveticaNeue-CondensedBold", size: 32.0)
    private var _currentSeconds: UInt = 0

    public var currentSeconds: UInt {
        get { return _currentSeconds }
        set(newValue) {
            _currentSeconds = min(newValue, maxSeconds)
        }
    }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        // bounding box guide
        // ctx.addRect(self.bounds)
        // ctx.strokePath()

        // diagonal line guide
        // ctx.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: self.bounds.width, y: self.bounds.height)])
        // ctx.addLines(between: [CGPoint(x: 0, y: self.bounds.height), CGPoint(x: self.bounds.width, y: 0)])
        // ctx.strokePath()

        let originRadius = 25.0 as CGFloat
        let maxRadius = min(self.bounds.width, self.bounds.height) / 2.0
        let tickMarkerRadius = maxRadius - 45.0
        let longTickMarkerLength = 45.0 as CGFloat
        let longTickMarkerWidth = 3.0 as CGFloat
        let shortTickMarkerLength = 20.0 as CGFloat
        let shortTickMarkerWidth = 2.0 as CGFloat
        let currentTimeRadius = tickMarkerRadius + 1.0

        ctx.translateBy(x: maxRadius, y: maxRadius)
        ctx.scaleBy(x: 1, y: -1)

        let maxMinutes = maxSeconds / 60
        let unitSecAngle = 2*CGFloat.pi / CGFloat(maxSeconds)
        let unitMinAngle = unitSecAngle * 60.0

        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .center
        let textAttributes = [
            NSAttributedStringKey.font: labelFont,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]

        for i in 0..<maxMinutes {
            ctx.saveGState()
            ctx.rotate(by: -CGFloat(i)*unitMinAngle)

            // Number label

            if i % 5 == 0 {
                ctx.saveGState()
                ctx.translateBy(x: 0.0, y: self.bounds.height/2 - 20.0)

                let path = CGMutablePath()
                path.addRect(CGRect(x: -20.0, y: -20.0, width: 40.0, height: 40.0))

                // text bounding box guide
                // ctx.saveGState()
                // ctx.addPath(path)
                // ctx.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                // ctx.strokePath()
                // ctx.restoreGState()

                let text = String(i)
                let attributedText = NSAttributedString(string: text, attributes: textAttributes)
                let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
                let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedText.length), path, nil)
                CTFrameDraw(frame, ctx)
                ctx.restoreGState()
            }
            
            // Tick marker

            ctx.translateBy(x: 0.0, y: tickMarkerRadius)
            ctx.move(to: CGPoint(x: 0, y: 0))
            if i % 5 == 0 {
                ctx.addLine(to: CGPoint(x: 0.0, y: -longTickMarkerLength))
                ctx.setLineWidth(longTickMarkerWidth)
            }
            else {
                ctx.addLine(to: CGPoint(x: 0.0, y: -shortTickMarkerLength))
                ctx.setLineWidth(shortTickMarkerWidth)
            }
            ctx.strokePath()

            ctx.restoreGState()
        }

        // remaining time area
        ctx.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addArc(center: CGPoint(x: 0, y: 0), radius: currentTimeRadius,
                   startAngle: CGFloat.pi/2.0,
                   endAngle: CGFloat.pi/2.0 - CGFloat(currentSeconds)*(2.0*CGFloat.pi/3600.0),
                   clockwise: true)
        ctx.fillPath()

        // current time bar
        ctx.saveGState()
        ctx.rotate(by: -CGFloat(currentSeconds)*unitSecAngle)
        ctx.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        ctx.setLineWidth(shortTickMarkerWidth)
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addLine(to: CGPoint(x: 0, y: currentTimeRadius + 5.0))
        ctx.strokePath()
        ctx.restoreGState()

        // origin point guide
        ctx.setFillColor(gray: 0.1, alpha: 1.0)
        ctx.addArc(center: CGPoint(x: 0, y: 0), radius: originRadius,
                   startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: false)
        ctx.fillPath()

        ctx.restoreGState()
    }

}
