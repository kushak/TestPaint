//
//  LoadingView.swift
//  MyPaint
//
//  Created by Oleg Shipulin on 01.11.2024.
//

import UIKit

final class LoadingView: UIView {
    private let backgroundView = UIView()
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented", file: "", line: 0)
    }

    func show() {
        layer.removeAllAnimations()
        activityIndicatorView.startAnimating()
        isHidden = false
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: { [self] in
                backgroundView.alpha = 1
                activityIndicatorView.alpha = 1
            },
            completion: nil
        )
    }

    func hide() {
        layer.removeAllAnimations()
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: { [self] in
                backgroundView.alpha = 0
                activityIndicatorView.alpha = 0
            },
            completion: { [self] _ in
                isHidden = true
                activityIndicatorView.stopAnimating()
            }
        )
    }
}

// MARK: - Private methods

private extension LoadingView {
    func commonInit() {
        layer.zPosition = 1000
        setupSubviews()
        setupConstraints()
    }

    func setupSubviews() {
        backgroundView.alpha = 0
        backgroundView.backgroundColor = .white.withAlphaComponent(0.5)

        activityIndicatorView.alpha = 0
        activityIndicatorView.color = .lightGray

        addSubview(backgroundView)
        addSubview(activityIndicatorView)
    }

    func setupConstraints() {
        let constraints = backgroundView.edgesToSuperview() + activityIndicatorView.centerToSuperview()
        constraints.activate()
    }
}

// MARK: - LoadingViewPresentable

 protocol LoadingViewPresentable: AnyObject {
    func showLoadingView()
    func hideLoadingView()
 }

// MARK: - UIViewController + LoadingViewPresentable

extension UIViewController: LoadingViewPresentable {
    public func showLoadingView() {
        view.showLoadingView()
    }

    public func hideLoadingView() {
        view.hideLoadingView()
    }
}

// MARK: - UIView + LoadingViewPresentable

extension UIView: LoadingViewPresentable {
    private var loadingView: LoadingView {
        if let loadingView = subviews.compactMap({ $0 as? LoadingView }).first {
            return loadingView
        }
        let loadingView = LoadingView()
        addSubview(loadingView)

        loadingView.edgesToSuperview().activate()
        return loadingView
    }

    public func showLoadingView() {
        bringSubviewToFront(loadingView)
        loadingView.show()
    }

    public func hideLoadingView() {
        loadingView.hide()
    }
}
