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

protocol TimerController {
    func setTimerSeconds(_ seconds: UInt)
}

private class CurrentTimeMarkerView: UIView {
    private let pointerRadius: CGFloat
    private var markerLength: CGFloat
    private var markerWidth: CGFloat
    private var originRadius: CGFloat

    public var markerPointLocation: CGPoint {
        get { return CGPoint(x: self.center.x, y: self.center.y - self.markerLength) }
    }

    public init(pointerRadius: CGFloat, markerLength: CGFloat, markerWidth: CGFloat,
                originRadius: CGFloat, frame: CGRect) {
        self.pointerRadius = pointerRadius
        self.markerLength = markerLength
        self.markerWidth = markerWidth
        self.originRadius = originRadius
        super.init(frame: frame)
        self.isOpaque = false
        self.backgroundColor = UIColor(white: 1, alpha: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var maxRadius: CGFloat {
        get { return min(self.bounds.width, self.bounds.height) / 2.0 }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.saveGState()
        ctx.translateBy(x: maxRadius, y: maxRadius)
        ctx.scaleBy(x: 1, y: -1)

        ctx.setStrokeColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        ctx.setLineWidth(self.markerWidth)
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addLine(to: CGPoint(x: 0, y: self.markerLength))
        ctx.strokePath()

        ctx.setFillColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        ctx.addArc(center: CGPoint(x: 0, y: self.markerLength),
                   radius: self.pointerRadius,
                   startAngle: 0.0, endAngle: 2*CGFloat.pi, clockwise: false)
        ctx.fillPath()

        ctx.setFillColor(gray: 0, alpha: 1)
        ctx.addArc(center: CGPoint(x: 0, y: 0), radius: self.originRadius,
                   startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: false)
        ctx.fillPath()
        
        ctx.restoreGState()
    }
}

class TimerView: UIView {
    public var controller: TimerController!

    public let maxSeconds: UInt = 60*60
    public let displayStep: UInt = 5

    private let labelFont = UIFont(name: "HelveticaNeue-CondensedBold", size: 32.0)!
    private var _currentSeconds: UInt = 0

    var maxMinutes: UInt {
        get { return maxSeconds / 60 }
    }
    var unitSecAngle: CGFloat {
        get { return 2*CGFloat.pi / CGFloat(maxSeconds) }
    }
    var unitMinAngle: CGFloat {
        get { return unitSecAngle * 60.0 }
    }

    public var currentSeconds: UInt {
        get { return _currentSeconds }
        set {
            _currentSeconds = min(newValue, maxSeconds)

            if self.markerPointView != nil {
                let tm = CGAffineTransform.identity.rotated(by: unitSecAngle * CGFloat(_currentSeconds))
                self.markerPointView!.transform = tm
            }
        }
    }

    private var markerPointView: CurrentTimeMarkerView!

    let markerPointRadius: CGFloat = 5.0

    var maxRadius: CGFloat {
        get { return min(self.bounds.width, self.bounds.height) / 2.0 }
    }
    var tickMarkerRadius: CGFloat {
        get { return maxRadius - 45.0 }
    }
    var currentTimeRadius: CGFloat {
        get { return tickMarkerRadius }
    }

    let originRadius: CGFloat = 25.0
    let longTickMarkerLength: CGFloat = 45.0
    let longTickMarkerWidth: CGFloat = 3.0
    let shortTickMarkerLength: CGFloat = 20.0
    let shortTickMarkerWidth: CGFloat = 2.0

    override func awakeFromNib() {
        self.markerPointView = CurrentTimeMarkerView(pointerRadius: markerPointRadius,
                                                     markerLength: currentTimeRadius,
                                                     markerWidth: shortTickMarkerWidth,
                                                     originRadius: originRadius,
                                                     frame: self.bounds)
        self.addSubview(self.markerPointView)
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

        ctx.translateBy(x: maxRadius, y: maxRadius)
        ctx.scaleBy(x: 1, y: -1)

        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .center
        let textAttributes = [
            NSAttributedStringKey.font: labelFont,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ] as [NSAttributedStringKey: Any]

        for i in 0..<maxMinutes {
            ctx.saveGState()
            ctx.rotate(by: -CGFloat(i)*unitMinAngle)

            // Number label

            if i % 5 == 0 {
                // TODO: Make magic numbers constants
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
        ctx.setFillColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addArc(center: CGPoint(x: 0, y: 0), radius: currentTimeRadius,
                   startAngle: CGFloat.pi/2.0,
                   endAngle: CGFloat.pi/2.0 - CGFloat(currentSeconds)*(2.0*CGFloat.pi/3600.0),
                   clockwise: true)
        ctx.fillPath()

        ctx.restoreGState()
    }

    var markerMoving: Bool = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = self.controller,
              let touch = touches.first
        else { return }
        let touchPoint = touch.location(in: self.markerPointView)
        let distanceFromMarkerPoint = (touchPoint - self.markerPointView.markerPointLocation).length
        if distanceFromMarkerPoint < 20.0 {
            markerMoving = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !markerMoving { return }
        guard let touch = touches.first,
              let controller = self.controller
        else { return }

        let currTouchPoint = touch.location(in: self)
        let currDirection = currTouchPoint - self.center
        let angle = currDirection.angleFrom(CGPoint(x: 0, y: -1))
        let seconds = UInt(angle / unitSecAngle)
        controller.setTimerSeconds(seconds)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.markerMoving = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.markerMoving = false
    }
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func * (lhs: CGPoint, rhs: CGPoint) -> CGFloat {
    return lhs.x * rhs.x + lhs.y * rhs.y
}

func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    return rhs * lhs
}

func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

extension CGPoint {
    var length: CGFloat {
        get { return sqrt(self.x * self.x + self.y * self.y) }
    }
    var unit: CGPoint {
        get { return self / self.length }
    }
    func angleFrom(_ point: CGPoint) -> CGFloat {
        return acos(fmin(fmax(self * point / (self.length * point.length), -1.0), 1.0))
    }
}
