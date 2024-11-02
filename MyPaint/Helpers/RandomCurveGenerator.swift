//
//  RandomCurveGenerator.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 01.11.2024.
//

import Foundation
import UIKit

final class RandomCurveGenerator {

    var isGenerationInProgress = false

    func generateRandomCurves(count: Int, in size: CGSize, batchSize: Int, batchCompletion: @escaping (Int, [[Curve]]) -> Void) {
        var remainingCount = count
        isGenerationInProgress = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            var results: [[Curve]] = []
            let batchCount = Int((Double(count) / Double(batchSize)).rounded(.up))
            results.reserveCapacity(batchSize)

            // count -> batchCount
            for batchNumber in (0..<batchCount) {
                let batchSize = min(batchSize, remainingCount)
                (0..<batchSize).forEach { _ in
                    let randomCurve = self.generateRandomCurve(in: size)
                    results.append([randomCurve])
                }

                guard isGenerationInProgress else { return }
                batchCompletion(count - remainingCount, results)
                remainingCount -= batchSize
//                print("+++ batchNumber: \(batchNumber), remainingCount: \(remainingCount)")
            }
        }
    }

    func stopGeration() {
        isGenerationInProgress = false
    }
}

private extension RandomCurveGenerator {
    private func generateRandomPoints(in size: CGSize) -> [CGPoint] {
        var randomPoints: [CGPoint] = []

        for _ in 1...10 {
            let randomX = Int.random(in: 0...Int(size.width))
            let randomY = Int.random(in: 0...Int(size.height))
            let randomPoint = CGPoint(x: randomX, y: randomY)

            randomPoints.append(randomPoint)
        }

        return randomPoints
    }

    private func generateRandomCurve(in size: CGSize) -> Curve {
        var settings = Curve.Settings.default
        settings.color = UIColor.systemBlue.cgColor
        return Curve(
            points: generateRandomPoints(in: size),
            settings: settings
        )
    }
}

func timeElapsedInSecondsWhenRunningCode(operation: ()->()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

    print("+++++ \(timeElapsed) seconds elapsed ++++")
}
