//
//  UIView+layout.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 28.10.2024.
//

import UIKit

extension UIView {
    func centerToSuperview() -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview else { return [] }
        
        return [
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        ]
    }

    func edgesToSuperview(inset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview else { return [] }

        return [
            leftAnchor.constraint(equalTo: superview.leftAnchor, constant: inset.left),
            rightAnchor.constraint(equalTo: superview.rightAnchor, constant: inset.right),

            topAnchor.constraint(equalTo: superview.topAnchor, constant: inset.top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: inset.bottom),
        ]
    }

    func horizontalEdges(to view: UIView, inset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false

        return [
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: inset.left),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: inset.right),
        ]
    }

    func edges(to view: UIView, inset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false

        return [
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: inset.left),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: inset.right),

            topAnchor.constraint(equalTo: view.topAnchor, constant: inset.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: inset.bottom),
        ]
    }

    func bottomToSafeArea(inset: CGFloat) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview else { return [] }

        return [bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -inset)]
    }

    func bottom(to anchor: NSLayoutYAxisAnchor, inset: CGFloat) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false

        return [bottomAnchor.constraint(equalTo: anchor, constant: -inset)]
    }

    func top(to anchor: NSLayoutYAxisAnchor, inset: CGFloat) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false

        return [topAnchor.constraint(equalTo: anchor, constant: inset)]
    }

    func size(_ size: CGSize) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        return [widthAnchor.constraint(equalToConstant: size.width), heightAnchor.constraint(equalToConstant: size.height)]
    }

    func size(_ size: CGFloat) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        return [widthAnchor.constraint(equalToConstant: size), heightAnchor.constraint(equalToConstant: size)]
    }
}


extension Array where Element == NSLayoutConstraint {
    func activate() {
        NSLayoutConstraint.activate(self)
    }
}
