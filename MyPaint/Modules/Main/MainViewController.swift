//
//  ViewController.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 28.10.2024.
//

import UIKit

final class MainViewController: UIViewController {
    private var customView: MainView { return view as! MainView }
    private let backCanvasModule = CanvasViewController()
    private let frontCanvasModule = CanvasViewController()
    private let animatinonModule = AnimationViewController()

    private var contextManager = MainContextManager()
    private let randomCurveGenerator = RandomCurveGenerator()

    override func loadView() {
        view = MainView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.undoButton.addTarget(self, action: #selector(undo), for: .touchUpInside)
        customView.redoButton.addTarget(self, action: #selector(redo), for: .touchUpInside)

        customView.deleteAllLayersButton.addTarget(self, action: #selector(deleteAllLayers), for: .touchUpInside)
        customView.deleteLayerButton.addTarget(self, action: #selector(deleteLayer), for: .touchUpInside)

        customView.addLayerButton.addTarget(self, action: #selector(addLayer), for: .touchUpInside)
        customView.addSameLayerButton.addTarget(self, action: #selector(addSameLayer), for: .touchUpInside)
        customView.addRandomLayerButton.addTarget(self, action: #selector(addRandomLayers), for: .touchUpInside)

        customView.playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)

        customView.pencilButton.addTarget(self, action: #selector(didTapPencil), for: .touchUpInside)
        customView.eraserButton.addTarget(self, action: #selector(didTapReraser), for: .touchUpInside)
        customView.colorButton.addTarget(self, action: #selector(didSelectColor), for: .valueChanged)

        backCanvasModule.delegate = self
        setup(module: backCanvasModule)
        backCanvasModule.view.alpha = 0.5
        contextManager.append(canvasContext: .initial)

        frontCanvasModule.delegate = self
        setup(module: frontCanvasModule)
        contextManager.append(canvasContext: .initial)

        setup(module: animatinonModule)
        animatinonModule.dataSource = self
        animatinonModule.view.isHidden = true
    }
}

// MARK: - Actions

private extension MainViewController {

    @objc func undo() {
        print(#function)
        frontCanvasModule.undo()
        updateButtonsState()
    }

    @objc func redo() {
        print(#function)
        frontCanvasModule.redo()
        updateButtonsState()
    }

    @objc func deleteAllLayers() {
        print(#function)
        stopAnimation()
        randomCurveGenerator.stopGeration()
        contextManager.removeAllCanvasContexts()
        contextManager.append(canvasContext: .initial)
        contextManager.append(canvasContext: .initial)
        backCanvasModule.updateState(with: .initial)
        frontCanvasModule.updateState(with: .initial)

        // stop generating
        updateButtonsState()
    }

    @objc func deleteLayer() {
        print(#function)
        contextManager.removeLastCanvasContext()
        backCanvasModule.updateState(with: contextManager.getPrevLastCanvasContext())
        frontCanvasModule.updateState(with: contextManager.getLastCanvasContext())
        updateButtonsState()
    }

    @objc func addLayer() {
        print(#function)
        backCanvasModule.updateState(with: contextManager.getLastCanvasContext())
        contextManager.append(canvasContext: .initial)
        frontCanvasModule.updateState(with: .initial)
        updateButtonsState()
    }

    @objc func addSameLayer() {
        print(#function)
        let lastContext = contextManager.getLastCanvasContext()
        backCanvasModule.updateState(with: lastContext)
        contextManager.append(canvasContext: lastContext)
        frontCanvasModule.updateState(with: lastContext)
        updateButtonsState()
    }

    @IBAction func addRandomLayers(){
        let alertController = UIAlertController(
            title: "Add random layers",
            message: "How many random layers do you want to add?",
            preferredStyle: .alert
        )
        alertController.addTextField { (textField: UITextField) -> Void in
            textField.placeholder = "Enter Number"
            textField.keyboardType = .numberPad
        }

        let addAction = UIAlertAction(title: "Add", style: .default, handler: { [weak self] alert -> Void in
            guard let self else { return }
            CATransaction.commit()
            let firstTextField = alertController.textFields![0] as UITextField
            let numberOfLayers = min(Int(firstTextField.text!) ?? 0, 100000)

            guard numberOfLayers > 0 else { return }

            showLoadingView()

            contextManager.reserve(capacity: contextManager.numberCanvasContextItems() + numberOfLayers * 2)
            randomCurveGenerator.generateRandomCurves(
                count: numberOfLayers,
                in: frontCanvasModule.view.bounds.size,
                batchSize: 10000
            ) { [weak self] offset, slidesBatch in
                guard let self else { return }

                let canvasContexts = slidesBatch.map { curves in
                    CanvasViewController.Context(currentSettings: .default, prevCurves: curves, nextCurves: [])
                }

                guard randomCurveGenerator.isGenerationInProgress else { return }
                contextManager.append(canvasContexts: canvasContexts)

//                print("+++ \(offset)")

//                DispatchQueue.main.async { [weak self] in
//                    guard let self else { return }
//                    updateButtonsState()
//                }

                if offset == 0 {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        backCanvasModule.updateState(with: contextManager.getPrevLastCanvasContext())
                        frontCanvasModule.updateState(with: contextManager.getLastCanvasContext())
                        updateButtonsState()
                        hideLoadingView()
                    }
                }
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    @objc func didTapPlayPause() {
        let isPlayAction = !customView.playPauseButton.isSelected
        customView.playPauseButton.isSelected.toggle()

        if isPlayAction {
            print("play")
            customView.updateAllButtonsEnabled(false)
            customView.playPauseButton.isEnabled = true
            frontCanvasModule.view.isUserInteractionEnabled = false
            backCanvasModule.view.isHidden = true
            frontCanvasModule.view.isHidden = true
            animatinonModule.view.isHidden = false

            animatinonModule.startAnimation()
        } else {
            print("pause")
            stopAnimation()
        }
    }

    @objc func didTapPencil() {
        print(#function)
        customView.instrumentsStackView.arrangedSubviews.forEach {
            $0.tintColor = $0 == customView.pencilButton ? .green : .white
        }
        frontCanvasModule.currentSettings.mode = .draw
    }

    @objc func didTapReraser() {
        print(#function)
        customView.instrumentsStackView.arrangedSubviews.forEach {
            $0.tintColor = $0 == customView.eraserButton ? .green : .white
        }
        frontCanvasModule.currentSettings.mode = .erase
    }

    @objc func didSelectColor() {
        guard let color = customView.colorButton.selectedColor else { return }
        frontCanvasModule.currentSettings.color = color.cgColor
    }
}

// MARK: - Privates

private extension MainViewController {

    func setup(module: UIViewController) {
        module.willMove(toParent: self)
        addChild(module)
        view.addSubview(module.view)

        let constraints = module.view.edges(to: customView.backgroundImageView)

        NSLayoutConstraint.activate(constraints)

        module.didMove(toParent: self)
    }

    func updateButtonsState(from function: String = #function) {
//        print("updateButtonsState(\(function)), \(contextManager.numberCanvasContextItems())")
        customView.updateAllButtonsEnabled(true)

        let canvasContextsCount = contextManager.numberCanvasContextItems()
        print("updateButtonsState(\(function)), canvasContextsCount: \(canvasContextsCount)")
        customView.addLayerButton.isEnabled = canvasContextsCount < Int.max
        customView.deleteLayerButton.isEnabled = canvasContextsCount > 2
        customView.deleteAllLayersButton.isEnabled = canvasContextsCount > 2

        let lastContext = contextManager.getLastCanvasContext()
        print("updateButtonsState(\(function)), lastContext.prevCurves: \(lastContext.prevCurves.count)")

        customView.undoButton.isEnabled = !lastContext.prevCurves.isEmpty
        customView.redoButton.isEnabled = !lastContext.nextCurves.isEmpty
    }

    func stopAnimation() {
        print(#function)
        frontCanvasModule.view.isUserInteractionEnabled = true
        updateButtonsState()
        backCanvasModule.view.isHidden = false
        frontCanvasModule.view.isHidden = false
        animatinonModule.view.isHidden = true

        animatinonModule.stopAnimating()
    }
}

// MARK: - CanvasModuleDelegate

extension MainViewController: CanvasModuleDelegate {
    func canvasModuleDidUpdateCanvas(_ canvas: CanvasViewController) {
//        print(#function)
        guard canvas == frontCanvasModule else { return }
//        print("\(#function), \(frontCanvasModule.currentContext)")

        contextManager.update(lastCanvasContext: frontCanvasModule.currentContext)
//        print("\(#function), \(contextManager.getLastCanvasContext())")
        updateButtonsState()
    }
}


// MARK: - AnimationModuleDataSource

extension MainViewController: AnimationModuleDataSource {
    func numberOfSlides() -> Int {
        contextManager.numberCanvasContextItems()
    }

    func slide(atIndex index: Int) -> [Curve] {
        contextManager.getCanvasContext(atIndex: index).prevCurves
    }
}
