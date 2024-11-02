//
//  AnimationViewController.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 01.11.2024.
//

import UIKit

protocol AnimationModuleDataSource: AnyObject {
    func numberOfSlides() -> Int
    func slide(atIndex index: Int) -> [Curve]
}

final class AnimationViewController: UIViewController {
    private var timer: Timer?
    private let imagePainter = ImagePainter()
    private let mainImageView = UIImageView()
//    private var animationSlides: [[Curve]] = []
    private let queue = DispatchQueue.global(qos: .userInitiated)
    private var isAnimationInProgress: Bool = false
    weak var dataSource: AnimationModuleDataSource?
    private var size = CGSize.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        mainImageView.accessibilityIdentifier = "AnimationViewController.mainImageView"
        view.addSubview(mainImageView)


        NSLayoutConstraint.activate(
            mainImageView.edgesToSuperview()
        )
    }
}

extension AnimationViewController {
    func startAnimation() {
        print("\(#function), animationSlides: \(dataSource?.numberOfSlides())")
        guard let dataSource, dataSource.numberOfSlides() > 2 else { return }
        isAnimationInProgress = true
        size = mainImageView.bounds.size

        repaint(curves: dataSource.slide(atIndex: 1))
        var i = 2
        let timer = Timer(timeInterval: 0.5, repeats: true, block: { [weak self] _ in
            guard let self, isAnimationInProgress else { return }
            let curves = dataSource.slide(atIndex: i)
            i += 1
            if i >= dataSource.numberOfSlides() { i = 1 }
            repaint(curves: curves)
        })

        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

//    func addAnimation(slides: [[Curve]]) {
//        print(#function)
//        print("\(#function), slides: \(slides.count), animationSlides: \(animationSlides.count)")
//        animationSlides += slides
//    }

//    func reserveSlidesCapacity(_ capacity: Int) {
//        animationSlides.reserveCapacity(capacity)
//    }

    func stopAnimating() {
        isAnimationInProgress = false
        mainImageView.image = nil
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Private

private extension AnimationViewController {
    func repaint(curves: [Curve]) {
        print(#function)
        queue.async { [weak self] in
            guard let self else { return }
            let image = imagePainter.paint(curves: curves, in: size, with: nil)
            DispatchQueue.main.async {[weak self] in
                self?.mainImageView.image = image
            }
        }
    }
}
