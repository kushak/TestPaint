//
//  MainContextManager.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 02.11.2024.
//

import Foundation

final class MainContextManager {
    private var canvasContexts: [CanvasViewController.Context] = []
    private let concurentQueue = DispatchQueue(label: "com.shipulin.mypaint.contextManager", qos: .userInitiated, attributes: .concurrent)

    func numberCanvasContextItems() -> Int {
        concurentQueue.sync {
            canvasContexts.count
        }
    }

    func getLastCanvasContext() -> CanvasViewController.Context {
        concurentQueue.sync {
            canvasContexts[canvasContexts.count - 1]
        }
    }

    func getPrevLastCanvasContext() -> CanvasViewController.Context {
        concurentQueue.sync {
            canvasContexts[canvasContexts.count - 2]
        }
    }

    func getCanvasContext(atIndex index: Int) -> CanvasViewController.Context {
        concurentQueue.sync {
            canvasContexts[index]
        }
    }

    func append(canvasContext: CanvasViewController.Context) {
        concurentQueue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            canvasContexts.append(canvasContext)
        }
    }

    func append(canvasContexts: [CanvasViewController.Context], fromF: String = #function) {
        print("append(canvasContexts:) \(fromF)")
        concurentQueue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            self.canvasContexts += canvasContexts
        }
    }

    func removeLastCanvasContext() {
        concurentQueue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            canvasContexts.removeLast()
        }
    }

    func removeAllCanvasContexts(fromF: String = #function) {
        print("removeAllCanvasContexts \(fromF)")
        concurentQueue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            canvasContexts.removeAll()
        }
    }

    func reserve(capacity: Int) {
        concurentQueue.sync { [weak self] in
            guard let self else { return }
            canvasContexts.reserveCapacity(capacity)
        }
    }

    func update(lastCanvasContext: CanvasViewController.Context) {
        concurentQueue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            canvasContexts[canvasContexts.count - 1] = lastCanvasContext
        }
    }
}
