//
//  ImagePainter.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 01.11.2024.
//

import Foundation
import UIKit

final class ImagePainter {

    func paintLine(fromPoint: CGPoint, toPoint: CGPoint, in size: CGSize, with image: UIImage?, settings: Curve.Settings) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
        paintLineInCurrentContext(
            fromPoint: fromPoint,
            toPoint: toPoint,
            in: size,
            settings: settings
        )


        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage
    }

    private func paintLineInCurrentContext(
        fromPoint: CGPoint,
        toPoint: CGPoint,
        in size: CGSize,
        settings: Curve.Settings
    ) {
        guard let context = UIGraphicsGetCurrentContext() else { return }


        // 2
        context.move(to: fromPoint)
        context.addLine(to: toPoint)

        // 3
        context.setLineCap(.round)
        context.setLineWidth(settings.width)
        context.setStrokeColor(settings.color)
        context.setBlendMode(settings.mode == .draw ? .normal : .clear)

        // 4
        context.strokePath()
    }

    func paint(curves: [Curve], in size: CGSize, with image: UIImage?) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
        for curve in curves {
            paintCurveInCurrentContext(curve: curve, with: size)
        }

        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage
    }

    private func paintCurveInCurrentContext(curve: Curve, with size: CGSize) {
        guard
            curve.points.count > 1
        else {
            assertionFailure()
            return
        }

        var i = 1
        var fromPoint = curve.points[0]
        var toPoint = curve.points[i]


        while i < curve.points.count {
            paintLineInCurrentContext(
                fromPoint: fromPoint,
                toPoint: toPoint,
                in: size,
                settings: curve.settings
            )

            fromPoint = toPoint
            toPoint = curve.points[i]
            i += 1
        }

        paintLineInCurrentContext(
            fromPoint: fromPoint,
            toPoint: toPoint,
            in: size,
            settings: curve.settings
        )
    }
}
