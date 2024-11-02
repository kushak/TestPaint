//
//  CanvaasViewController.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 28.10.2024.
//

import UIKit

protocol CanvasModuleDelegate: AnyObject {
    func canvasModuleDidUpdateCanvas(_ canvas: CanvasViewController)
}

final class CanvasViewController: UIViewController {

    struct Context {
        let currentSettings: Curve.Settings
        let prevCurves: [Curve]
        let nextCurves: [Curve]

        static let initial = Context(
            currentSettings: .default,
            prevCurves: [],
            nextCurves: []
        )
    }

    var currentContext: Context {
        .init(currentSettings: currentSettings, prevCurves: prevCurves, nextCurves: nextCurves)
    }

    weak var delegate: CanvasModuleDelegate?
    var currentSettings = Curve.Settings.default

    private var imagePainter = ImagePainter()

    private(set) var prevCurves = [Curve]()
    private(set) var nextCurves = [Curve]()

    private let mainImageView = UIImageView()

    private var isPaintingInProgress = false
    private var lastPoint: CGPoint? {
        prevCurves.last?.points.last
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        mainImageView.accessibilityIdentifier = "mainImageView"
        view.addSubview(mainImageView)


        NSLayoutConstraint.activate(
            mainImageView.edgesToSuperview()
        )
    }
}

// MARK: - CanvasModuleInput

extension CanvasViewController {

    func undo() {
        guard !prevCurves.isEmpty else {
            assertionFailure()
            return
        }
        let curve = prevCurves.removeLast()
        nextCurves.append(curve)
        repaint(curves: prevCurves)
        delegate?.canvasModuleDidUpdateCanvas(self)
    }

    func redo() {
        guard !nextCurves.isEmpty else {
            assertionFailure("Redo is not possible")
            return
        }
        let curve = nextCurves.removeLast()
        prevCurves.append(curve)
        mainImageView.image = imagePainter.paint(curves: [curve], in: mainImageView.bounds.size, with: mainImageView.image)
        delegate?.canvasModuleDidUpdateCanvas(self)
    }

    func updateState(with context: Context) {
        print("+++ \(#function), \(context.prevCurves)")
        currentSettings = context.currentSettings
        prevCurves = context.prevCurves
        nextCurves = context.nextCurves
        repaint(curves: prevCurves)
    }
}

// MARK: - Touches

extension CanvasViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: mainImageView)
        guard mainImageView.point(inside: currentPoint, with: nil) else { return }

        isPaintingInProgress = false

        prevCurves.append(
            Curve(
                points: [currentPoint],
                settings: currentSettings
            )
        )
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let lastPoint, let touch = touches.first else { return }
        let currentPoint = touch.location(in: mainImageView)
        guard mainImageView.point(inside: currentPoint, with: nil) else { return }

        isPaintingInProgress = true
        drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint, settings: currentSettings)
        prevCurves[prevCurves.count - 1].points.append(currentPoint)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        if !isPaintingInProgress, let lastPoint {
            prevCurves[prevCurves.count - 1].points.append(lastPoint)
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint, settings: currentSettings)
        }

        isPaintingInProgress = false
        nextCurves.removeAll()

        delegate?.canvasModuleDidUpdateCanvas(self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        prevCurves.removeLast()
        repaint(curves: prevCurves)
        delegate?.canvasModuleDidUpdateCanvas(self)
    }
}

// MARK: - Private

private extension CanvasViewController {
    private func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint, settings: Curve.Settings) {
        mainImageView.image = imagePainter.paintLine(
            fromPoint: fromPoint,
            toPoint: toPoint,
            in: mainImageView.bounds.size,
            with: mainImageView.image,
            settings: settings
        )
    }

    func repaint(curves: [Curve]) {
        let size = mainImageView.bounds.size
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let image = imagePainter.paint(curves: curves, in: size, with: nil)
            DispatchQueue.main.async {[weak self] in
                self?.mainImageView.image = image
            }
        }
    }
}
