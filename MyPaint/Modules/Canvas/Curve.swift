//
//  Curve.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 01.11.2024.
//

import UIKit

struct Curve: CustomStringConvertible {
    struct Settings: CustomStringConvertible {
        var width: CGFloat
        var color: CGColor
        var mode: Mode

        static let `default` = Settings(
            width: 5,
            color: UIColor.black.cgColor,
            mode: .draw
        )

        var description: String {
            "\(color == UIColor.black.cgColor ? "black" : "blue")"
        }
    }

    enum Mode {
        case draw, erase
    }

    var points: [CGPoint]
    let settings: Settings

    static let empty = Curve(points: [], settings: .default)
    var description: String {
        "\(settings)"
    }
}
