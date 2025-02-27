//  RestoreWalletFromSeedsModel.swift

/*
	Package MobileWallet
	Created by Adrian Truszczynski on 12/07/2021
	Using Swift 5.0
	Running on macOS 12.0

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

import Combine

struct TokenViewModel: Identifiable, Hashable {
    let id: UUID
    let title: String
}

final class RestoreWalletFromSeedsModel {

    final class ViewModel {
        @Published var error: SimpleErrorModel?
        @Published var isConfimationEnabled: Bool = false
        @Published var isEmptyWalletCreated: Bool = false
        @Published var isAutocompletionAvailable: Bool = false
        @Published var autocompletionTokens: [TokenViewModel] = []
        @Published var autocompletionMessage: String?
    }

    // MARK: - Properties

    @Published var inputText: String = ""
    @Published var seedWords: [String] = []
    
    let viewModel: ViewModel = ViewModel()
    
    private var availableAutocompletionTokens: [TokenViewModel] = [] {
        didSet { viewModel.isAutocompletionAvailable = !availableAutocompletionTokens.isEmpty }
    }
    private var cancelables = Set<AnyCancellable>()
    
    // MARK: - Initalizers

    init() {
        setupFeedbacks()
        fetchAvailableSeedWords()
    }

    // MARK: - Setups

    private func setupFeedbacks() {
        
        $seedWords
            .map { !$0.isEmpty }
            .assign(to: \.isConfimationEnabled, on: viewModel)
            .store(in: &cancelables)
        
        $inputText
            .map { [unowned self] inputText in self.availableAutocompletionTokens.filter { $0.title.lowercased().hasPrefix(inputText.lowercased()) }}
            .map { [unowned self] in $0 != self.availableAutocompletionTokens ? $0 : [] }
            .assign(to: \.autocompletionTokens, on: viewModel)
            .store(in: &cancelables)
        
        Publishers.CombineLatest($inputText, viewModel.$autocompletionTokens)
            .map {
                switch ($0.isEmpty, $1.isEmpty) {
                case (true, true):
                    return localized("restore_from_seed_words.autocompletion_toolbar.label.start_typing")
                case (false, true):
                    return localized("restore_from_seed_words.autocompletion_toolbar.label.no_suggestions")
                default:
                    return nil
                }
            }
            .assign(to: \.autocompletionMessage, on: viewModel)
            .store(in: &cancelables)
    }

    // MARK: - Actions

    func startRestoringWallet() {
        do {
            let walletSeedWords = try SeedWords(words: seedWords)
            try TariLib.shared.createNewWallet(seedWords: walletSeedWords)
            viewModel.isEmptyWalletCreated = true
        } catch let error as SeedWords.Error {
            handle(seedWordsError: error)
        } catch let error as WalletErrors {
            handle(walletError: error)
        } catch {
            handleUnknownError()
        }
    }
    
    private func fetchAvailableSeedWords() {
        availableAutocompletionTokens = (try? SeedWordsMnemonicWordList(language: .english)?.seedWords.map { TokenViewModel(id: UUID(), title: $0) }) ?? []
    }

    // MARK: - Handlers

    private func handle(seedWordsError: SeedWords.Error) {
        switch seedWordsError {
        case .invalidSeedPhrase, .invalidSeedWord:
            viewModel.error = SimpleErrorModel(
                title: localized("restore_from_seed_words.error.title"),
                description: localized("restore_from_seed_words.error.description.invalid_seed_word")
            )
        case .phraseIsTooShort:
            viewModel.error = SimpleErrorModel(
                title: localized("restore_from_seed_words.error.title"),
                description: localized("restore_from_seed_words.error.description.phrase_too_short")
            )
        case .phraseIsTooLong:
            viewModel.error = SimpleErrorModel(
                title: localized("restore_from_seed_words.error.title"),
                description: localized("restore_from_seed_words.error.description.phrase_too_long")
            )
        case .unexpectedResult:
            viewModel.error = SimpleErrorModel(
                title: localized("restore_from_seed_words.error.title"),
                description: localized("restore_from_seed_words.error.description.unknown_error")
            )
        }
    }

    private func handle(walletError: WalletErrors) {
        
        guard let description = walletError.errorDescription else {
            handleUnknownError()
            return
        }
        
        viewModel.error = SimpleErrorModel(
            title: localized("restore_from_seed_words.error.title"),
            description: description,
            error: walletError
        )
    }

    private func handleUnknownError() {
        viewModel.error = SimpleErrorModel(
            title: localized("restore_from_seed_words.error.title"),
            description: localized("restore_from_seed_words.error.description.unknown_error")
        )
    }
}
