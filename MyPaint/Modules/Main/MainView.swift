//
//  MainView.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 30.10.2024.
//

import UIKit

final class MainView: UIView {
    private(set) lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "paperBackground2")
        imageView.contentMode = .scaleToFill

        return imageView
    }()

    private(set) lazy var undoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrow.uturn.backward.circle.fill"), for: .normal)
        button.isEnabled = false
        button.tintColor = .white

        return button
    }()

    private(set) lazy var redoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrow.uturn.forward.circle.fill"), for: .normal)
        button.isEnabled = false
        button.tintColor = .white

        return button
    }()

    private(set) lazy var deleteLayerButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.isEnabled = false
        button.tintColor = .white

        return button
    }()

    private(set) lazy var deleteAllLayersButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "xmark.bin.fill"), for: .normal)
        button.isEnabled = false
        button.tintColor = .white

        return button
    }()

    private(set) lazy var addLayerButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "rectangle.stack.fill.badge.plus"), for: .normal)
        button.tintColor = .white

        return button
    }()

    private(set) lazy var addSameLayerButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "photo.badge.plus.fill"), for: .normal)
        button.tintColor = .white

        return button
    }()

    private(set) lazy var addRandomLayerButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "dice.fill"), for: .normal)
        button.tintColor = .white

        return button
    }()

    private(set) lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .selected)
        button.isEnabled = true
        button.tintColor = .white

        return button
    }()

    private(set) lazy var actionsStackView: UIStackView = {
        let spacing1View = UIView()
        let spacing2View = UIView()
        let spacing3View = UIView()
        let stackView = UIStackView(arrangedSubviews: [
            undoButton,
            redoButton,
            spacing1View,
            deleteAllLayersButton,
            deleteLayerButton,
            spacing2View,
            addLayerButton,
            addSameLayerButton,
            addRandomLayerButton,
            spacing3View,
            playPauseButton
        ])
        stackView.axis = .horizontal
        stackView.spacing = 8

        spacing1View.widthAnchor.constraint(equalTo: spacing2View.widthAnchor).isActive = true
        spacing1View.widthAnchor.constraint(equalTo: spacing3View.widthAnchor).isActive = true

        return stackView
    }()

    private(set) lazy var pencilButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "applepencil.and.scribble"), for: .normal)
        button.tintColor = .green

        return button
    }()

    private(set) lazy var eraserButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "eraser.line.dashed"), for: .normal)
        button.tintColor = .white

        return button
    }()

    private(set) lazy var lineweightButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "lineweight"), for: .normal)
        button.tintColor = .white

        return button
    }()

    private(set) lazy var colorButton: UIColorWell = {
        let button = UIColorWell()
        button.selectedColor = .black
        return button
    }()

    private(set) lazy var instrumentsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pencilButton, eraserButton, lineweightButton, colorButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12

        return stackView
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateAllButtonsEnabled(_ isEnabled: Bool) {
        let buttons: [UIControl] = [
            undoButton,
            redoButton,
            deleteLayerButton,
            deleteAllLayersButton,
            addLayerButton,
            addSameLayerButton,
            addRandomLayerButton,
            playPauseButton,
            pencilButton,
            eraserButton,
            lineweightButton,
            colorButton,
        ]

        buttons.forEach { $0.isEnabled = isEnabled }
    }
}

private extension MainView {
    func setupView() {
        backgroundColor = .black
        addSubview(backgroundImageView)
        addSubview(actionsStackView)
        addSubview(instrumentsStackView)

        actionsStackView.translatesAutoresizingMaskIntoConstraints = false

        var constraints: [NSLayoutConstraint] =
        [
            actionsStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            actionsStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            actionsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            instrumentsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ]

        let buttonSize: CGFloat = 24
        constraints += instrumentsStackView.bottomToSafeArea(inset: 12)
        constraints += undoButton.size(buttonSize)
        constraints += redoButton.size(buttonSize)
        
        constraints += deleteAllLayersButton.size(buttonSize)
        constraints += deleteLayerButton.size(buttonSize)

        constraints += addLayerButton.size(buttonSize)
        constraints += addSameLayerButton.size(buttonSize)
        constraints += addRandomLayerButton.size(buttonSize)

        constraints += playPauseButton.size(buttonSize)

        constraints += pencilButton.size(buttonSize)
        constraints += eraserButton.size(buttonSize)

        constraints += backgroundImageView.horizontalEdges(to: self)
        constraints += backgroundImageView.bottom(to: instrumentsStackView.topAnchor, inset: 12)
        constraints += backgroundImageView.top(to: actionsStackView.bottomAnchor, inset: 12)

        NSLayoutConstraint.activate(constraints)
    }
}
