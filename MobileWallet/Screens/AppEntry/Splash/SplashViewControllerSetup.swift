//  SplashViewControllerSetup.swift

/*
	Package MobileWallet
	Created by Jason van den Berg on 2020/03/03
	Using Swift 5.0
	Running on macOS 10.15

	Copyright 2019 The Tari Project

	Redistribution and use in source and binary forms, with or
	without modification, are permitted provided that the
	following conditions are met:

	1. Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.

	2. Redistributions in binary form must reproduce the above
	copyright notice, this list of conditions and the following disclaimer in the
	documentation and/or other materials provided with the distribution.

	3. Neither the name of the copyright holder nor the names of
	its contributors may be used to endorse or promote products
	derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
	CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import AVFoundation
import Lottie

extension SplashViewController {
    func setupView() {
        view.addSubview(generalContainer)
        generalContainer.translatesAutoresizingMaskIntoConstraints = false

        if UIDevice.current.userInterfaceIdiom == .pad {
            generalContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85).isActive = true
            generalContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.85).isActive = true
            generalContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            generalContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        } else {
            generalContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            generalContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            generalContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            generalContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        }

        setupAnimationContainer()
        setupVideoView()
        setupContraintsVersionLabel()
        setupElementsContainer()
    }

    func loadAnimation() {
        let animation = Animation.named(.splash)
        animationContainer.backgroundBehavior = .stop
        animationContainer.animation = animation
    }

    func setupVideoAnimation() {
        videoView.url = Bundle.main.url(forResource: "purple_orb", withExtension: "mp4")
    }

    func setupAnimationContainer() {
        generalContainer.addSubview(animationContainer)
        animationContainer.translatesAutoresizingMaskIntoConstraints = false
        animationContainer.widthAnchor.constraint(equalToConstant: 145).isActive = true
        animationContainer.heightAnchor.constraint(equalToConstant: 30).isActive = true
        animationContainer.centerXAnchor.constraint(equalTo: generalContainer.centerXAnchor).isActive = true

        if TariLib.shared.isWalletExist {
            animationContainer.centerYAnchor.constraint(equalTo: generalContainer.centerYAnchor).isActive = true
        } else {
            ticketTopLayoutConstraint = animationContainer.topAnchor.constraint(equalTo: generalContainer.topAnchor, constant: 19)
            ticketTopLayoutConstraint?.isActive = true
        }
    }

    func setupVideoView() {
        videoView.isHidden = true
        generalContainer.insertSubview(videoView, belowSubview: animationContainer)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        if TariLib.shared.isWalletExist {
            animationContainerBottomAnchor?.isActive = false
        } else {
            videoView.centerXAnchor.constraint(equalTo: generalContainer.centerXAnchor).isActive = true
            animationContainerBottomAnchor = videoView.topAnchor.constraint(equalTo: animationContainer.bottomAnchor)
            animationContainerBottomAnchor?.isActive = true
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
    }

    func setupElementsContainer() {
        generalContainer.addSubview(elementsContainer)

        setupTitleLabel()
        setupCreateWalletButton()
        setupSelectNetworkButton()
        setupRestoreButton()
        setupDisclaimer()
        setupGemImageView()

        elementsContainer.translatesAutoresizingMaskIntoConstraints = false

        elementsContainer.widthAnchor.constraint(equalTo: generalContainer.widthAnchor).isActive = true
        elementsContainer.centerXAnchor.constraint(equalTo: generalContainer.centerXAnchor).isActive = true
        elementsContainer.topAnchor.constraint(equalTo: videoView.bottomAnchor, constant: -15).isActive = true
        elementsContainer.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -9).isActive = true
        elementsContainer.bottomAnchor.constraint(equalTo: gemImageView.bottomAnchor).isActive = true
    }

    func setupTitleLabel() {
        titleLabel.isHidden = true
        titleLabel.text = localized("splash.title")
        titleLabel.interlineSpacing(spacingValue: 0)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = Theme.shared.fonts.splashTitleLabel
        titleLabel.textColor = Theme.shared.colors.splashTitle

        elementsContainer.addSubview(titleLabel)

        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: generalContainer.leadingAnchor, constant: Theme.shared.sizes.appSidePadding).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: generalContainer.trailingAnchor, constant: -Theme.shared.sizes.appSidePadding).isActive = true
        titleLabel.topAnchor.constraint(equalTo: elementsContainer.topAnchor).isActive = true
    }

    func setupCreateWalletButton() {
        createWalletButton.isHidden = true
        createWalletButton.addTarget(self, action: #selector(onCreateWalletTap), for: .touchUpInside)
        elementsContainer.addSubview(createWalletButton)

        createWalletButton.translatesAutoresizingMaskIntoConstraints = false

        createWalletButton.leadingAnchor.constraint(equalTo: generalContainer.leadingAnchor, constant: Theme.shared.sizes.appSidePadding).isActive = true
        createWalletButton.trailingAnchor.constraint(equalTo: generalContainer.trailingAnchor, constant: -Theme.shared.sizes.appSidePadding).isActive = true
        createWalletButton.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        createWalletButton.topAnchor.constraint(lessThanOrEqualTo: titleLabel.bottomAnchor, constant: 25).isActive = true
    }

    func setupSelectNetworkButton() {

        selectNetworkButton.translatesAutoresizingMaskIntoConstraints = false
        selectNetworkButton.isHidden = true
        selectNetworkButton.addTarget(self, action: #selector(onSelectNetworkButtonTap), for: .touchUpInside)

        elementsContainer.addSubview(selectNetworkButton)

        let constraints = [
            selectNetworkButton.leadingAnchor.constraint(equalTo: generalContainer.leadingAnchor, constant: Theme.shared.sizes.appSidePadding),
            selectNetworkButton.trailingAnchor.constraint(equalTo: generalContainer.trailingAnchor, constant: -Theme.shared.sizes.appSidePadding),
            selectNetworkButton.topAnchor.constraint(equalTo: createWalletButton.bottomAnchor, constant: 12.0),
            selectNetworkButton.heightAnchor.constraint(equalToConstant: 32.0)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func setupRestoreButton() {
        restoreButton.isHidden = true
        restoreButton.backgroundColor = .clear
        restoreButton.tintColor = .white
        restoreButton.titleLabel?.font = Theme.shared.fonts.restoreWalletButton
        restoreButton.addTarget(self, action: #selector(onRestoreWalletTap), for: .touchUpInside)
        let title = localized("splash.restore_wallet")
        restoreButton.setTitle(title, for: .normal)

        elementsContainer.addSubview(restoreButton)
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        restoreButton.centerXAnchor.constraint(equalTo: generalContainer.centerXAnchor).isActive = true
        restoreButton.topAnchor.constraint(greaterThanOrEqualTo: selectNetworkButton.bottomAnchor, constant: 5.0).isActive = true
        restoreButton.topAnchor.constraint(lessThanOrEqualTo: selectNetworkButton.bottomAnchor, constant: 22.0).isActive = true
        restoreButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }

    func setupDisclaimer() {
        disclaimerText.isHidden = true
        elementsContainer.addSubview(disclaimerText)
        disclaimerText.translatesAutoresizingMaskIntoConstraints = false
        disclaimerText.isEditable = false

        let userAgreementLinkText = localized("splash.disclaimer.param.user_agreement")
        let privacyPolicyLinkText = localized("splash.disclaimer.param.privacy_policy")
        let text = String(
            format: localized("splash.disclaimer.with_params"),
            userAgreementLinkText,
            privacyPolicyLinkText)

        let attributedText = NSMutableAttributedString(string: text)

        disclaimerText.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.shared.colors.splashVersionLabel!,
            NSAttributedString.Key.underlineColor: Theme.shared.colors.splashVersionLabel!,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        if let userAgreementStartIndex = text.indexDistance(of: userAgreementLinkText) {
            let range = NSRange(location: userAgreementStartIndex, length: userAgreementLinkText.count)
            attributedText.addAttribute(.link, value: TariSettings.shared.userAgreementUrl, range: range)
            attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: range)
        }

        if let privacyPolicyStartIndex = text.indexDistance(of: privacyPolicyLinkText) {
            let range = NSRange(location: privacyPolicyStartIndex, length: privacyPolicyLinkText.count)
            attributedText.addAttribute(.link, value: TariSettings.shared.privacyPolicyUrl, range: range)
            attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }

        disclaimerText.attributedText = attributedText

        disclaimerText.backgroundColor = .clear
        disclaimerText.textColor = Theme.shared.colors.splashVersionLabel
        disclaimerText.font = Theme.shared.fonts.splashDisclaimerLabel
        disclaimerText.textAlignment = .center
        disclaimerText.isScrollEnabled = false

        disclaimerText.leadingAnchor.constraint(equalTo: generalContainer.leadingAnchor, constant: Theme.shared.sizes.appSidePadding).isActive = true
        disclaimerText.trailingAnchor.constraint(equalTo: generalContainer.trailingAnchor, constant: -Theme.shared.sizes.appSidePadding).isActive = true
        disclaimerText.centerXAnchor.constraint(equalTo: generalContainer.centerXAnchor).isActive = true
        disclaimerText.topAnchor.constraint(greaterThanOrEqualTo: restoreButton.bottomAnchor, constant: 0).isActive = true
        disclaimerText.topAnchor.constraint(lessThanOrEqualTo: restoreButton.bottomAnchor, constant: 5).isActive = true
    }

    func setupGemImageView() {
        elementsContainer.addSubview(gemImageView)
        gemImageView.image = Theme.shared.images.currencySymbol
        gemImageView.translatesAutoresizingMaskIntoConstraints = false
        gemImageView.centerXAnchor.constraint(equalTo: generalContainer.centerXAnchor).isActive = true
        gemImageView.topAnchor.constraint(greaterThanOrEqualTo: disclaimerText.bottomAnchor, constant: 0).isActive = true
        gemImageView.topAnchor.constraint(lessThanOrEqualTo: disclaimerText.bottomAnchor, constant: 12).isActive = true
        gemImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        gemImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }

    func setupContraintsVersionLabel() {
        versionLabel.font = Theme.shared.fonts.splashVersionFooterLabel
        versionLabel.textColor = Theme.shared.colors.splashVersionLabel

        generalContainer.addSubview(versionLabel)
        versionLabel.textAlignment = .center
        versionLabel.numberOfLines = 0
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        versionLabel.bottomAnchor.constraint(equalTo: generalContainer.bottomAnchor,
                                             constant: -12).isActive = true
        versionLabel.leadingAnchor.constraint(equalTo: generalContainer.leadingAnchor,
                                              constant: Theme.shared.sizes.appSidePadding).isActive = true
        versionLabel.trailingAnchor.constraint(equalTo: generalContainer.trailingAnchor,
                                               constant: -Theme.shared.sizes.appSidePadding).isActive = true
        versionLabel.centerXAnchor.constraint(equalTo: generalContainer.centerXAnchor,
                                              constant: 0).isActive = true
    }

    func titleAnimation() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.distanceTitleSubtitle.constant = 30.0
            self.view.layoutIfNeeded()
        }
    }

    func topAnimationAndRemoveVideoAnimation(onComplete: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.ticketTopLayoutConstraint?.isActive = false
            self.animationContainerBottomAnchor?.isActive = false
            self.animationContainerBottomAnchorToVideo?.isActive = false
            self.ticketBottom?.isActive = false
            self.videoView.isHidden = true
            self.animationContainer.bottomAnchor.constraint(equalTo: self.generalContainer.centerYAnchor).isActive = true

            UIView.animate(withDuration: 1.0, animations: { [weak self] in
                guard let self = self else { return }
                self.elementsContainer.alpha = 0
                self.versionLabel.alpha = 0
                self.view.layoutIfNeeded()
            }) { [weak self] (_) in
                guard let self = self else { return }
                self.startAnimation(onComplete: onComplete)
            }
        }
    }
}
