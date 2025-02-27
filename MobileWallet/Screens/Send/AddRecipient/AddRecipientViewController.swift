//  AddRecipientViewController.swift

/*
	Package MobileWallet
	Created by Jason van den Berg on 2020/02/10
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
import Combine
import TariCommon

final class AddRecipientViewController: UIViewController {

    // MARK: - Properties
    
    var deepLinkParams: DeepLinkParams?
    
    private let model = AddRecipientModel()
    private let mainView = AddRecipientView()
    
    private var cancellables = Set<AnyCancellable>()
    private var initialized: Bool = false
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupFeedbacks()
        hideKeyboardWhenTappedAroundOrSwipedDown()
        Tracker.shared.track("/home/send_tari/add_recipient", "Send Tari - Add Recipient")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.searchText.send("")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !initialized else { return }
        mainView.searchView.textField.becomeFirstResponder()
        initialized = true
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        mainView.contactsTableView.register(type: ContactCell.self)
        mainView.contactsTableView.register(headerFooterType: AddRecipientSectionHeaderView.self)
    }
    
    private func setupFeedbacks() {
        
        let isEditingPublisher = mainView.searchView.textField.isEditingPublisher()
        let canMoveToNextStepPublisher = model.$canMoveToNextStep
        
        isEditingPublisher.combineLatest(canMoveToNextStepPublisher)
            .receive(on: DispatchQueue.main)
            .map { !$0 && $1 }
            .assign(to: \.isSearchFieldContainsValidAddress, on: mainView)
            .store(in: &cancellables)
        
        mainView.searchView.textField
            .textPublisher()
            .map { $0.filter { !"| ".contains($0) }}
            .sink { [weak self] in self?.model.searchText.send($0) }
            .store(in: &cancellables)
        
        model.searchText
            .map { $0.add(separator: " | ", interval: 3) }
            .sink { [weak self] in self?.mainView.searchView.textField.text = $0 }
            .store(in: &cancellables)
        
        model.searchText
            .map { $0.containsOnlyEmoji }
            .assign(to: \.isSearchTextDimmed, on: mainView)
            .store(in: &cancellables)
        
        model.$yatID
            .receive(on: DispatchQueue.main)
            .map { $0 != nil }
            .assign(to: \.isPreviewButtonVisible, on: mainView)
            .store(in: &cancellables)
        
        model.$walletAddressPreview
            .receive(on: DispatchQueue.main)
            .assign(to: \.previewText, on: mainView.searchView)
            .store(in: &cancellables)
        
        mainView.contactsTableView.delegate = self
        
        mainView.onScanButtonTap = { [weak self] in self?.openScanner() }
        mainView.onPreviewButtonTap = { [weak self] in self?.model.toogleYatPreview() }
        mainView.onSearchFieldBeginEditing = { [weak self] in self?.model.checkPasteboard() }
        mainView.onReturnButtonTap = { [weak self] in self?.model.confirmSelection() }
        mainView.onContinueButtonTap = { [weak self] in self?.model.confirmSelection() }
        
        canMoveToNextStepPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in $0 ? self?.showNextButton() : self?.hideNextButton() }
            .store(in: &cancellables)
        
        model.$errorMessage
            .replaceNil(with: "")
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: mainView)
            .store(in: &cancellables)
        
        model.$verifiedPaymentInfo
            .compactMap { $0 }
            .sink { [weak self] in self?.onContinue(paymentInfo: $0) }
            .store(in: &cancellables)
        
        model.$contactsSectionItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.updateTableView(items: $0) }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map(\.height)
            .sink { [weak self] in self?.showClipboardEmojis(keyboardHeight: $0) }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in self?.hideClipboardEmojis() }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    private func showNextButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismissKeyboard()
        mainView.isContinueButtonVisible = true
    }
    
    private func hideNextButton() {
        mainView.isContinueButtonVisible = false
    }
    
    private func openScanner() {
        let scanViewController = ScanViewController(scanResourceType: .publicKey)
        scanViewController.actionDelegate = self
        scanViewController.modalPresentationStyle = UIDevice.current.userInterfaceIdiom == .pad ? .automatic :.popover
        present(scanViewController, animated: true, completion: nil)
    }
    
    private func showClipboardEmojis(keyboardHeight: CGFloat) {
        
        guard let validatedPasteboardText = model.validatedPasteboardText else { return }
        
        mainView.showCopyFromClipboardDialog(text: validatedPasteboardText, keyboardOffset: keyboardHeight) { [weak self] in
            self?.model.searchText.send(validatedPasteboardText)
        }
    }

    private func hideClipboardEmojis() {
        mainView.hideCopyFromClipboardDialog()
    }
    
    private func updateTableView(items: [ContactsSectionItem]) {
        
        let snapshot = items
            .reduce(into: NSDiffableDataSourceSnapshot<String, ContactElementItem>()) { result, section in
                result.appendSections([section.title])
                result.appendItems(section.items, toSection: section.title)
            }
        
        mainView.tableDataSource?.apply(snapshot, animatingDifferences: initialized)
    }
    
    private func onContinue(paymentInfo: PaymentInfo) {
        let amountVC = AddAmountViewController()
        amountVC.paymentInfo = paymentInfo
        amountVC.deepLinkParams = deepLinkParams
        navigationController?.pushViewController(amountVC, animated: true)
    }
}

extension AddRecipientViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(type: AddRecipientSectionHeaderView.self)
        view.text = model.contactsSectionItems[section].title
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.onSelectItem(atIndexPath: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrolledToTop = scrollView.contentOffset.y <= 20.0
        mainView.isSearchViewShadowVisible = !isScrolledToTop
    }
}

extension AddRecipientViewController: ScanViewControllerDelegate {
    
    func onAdd(publicKey: PublicKey) {
        model.searchText.send(publicKey.emojis.0)
    }
}

private extension String {
    
    func add(separator: String, interval: Int) -> String {
        
        guard containsOnlyEmoji else { return self }
        
        return enumerated().reduce(into: "") { result, input in
            result += String(input.element)
            guard (input.offset + 1) % interval == 0, input.offset + 1 != count else { return }
            result += separator
        }
    }
}
