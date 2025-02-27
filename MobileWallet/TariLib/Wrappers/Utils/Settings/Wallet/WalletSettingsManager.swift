//  WalletSettingsManager.swift

/*
	Package MobileWallet
	Created by Adrian Truszczynski on 03/10/2021
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

final class WalletSettingsManager {

    private var settings: WalletSettings {

        guard let networkName = GroupUserDefaults.selectedNetworkName else {
            return WalletSettings(networkName: "", configationState: .notConfigured, isCloudBackupEnabled: false, hasVerifiedSeedPhrase: false)
        }

        guard let existingSettings = GroupUserDefaults.walletSettings?.first(where: { $0.networkName == networkName }) else {
            var settings = GroupUserDefaults.walletSettings ?? []
            let newSettings = WalletSettings(networkName: networkName, configationState: .notConfigured, isCloudBackupEnabled: false, hasVerifiedSeedPhrase: false)
            settings.append(newSettings)
            GroupUserDefaults.walletSettings = settings
            return newSettings
        }

        return existingSettings
    }

    var configationState: WalletSettings.WalletConfigurationState {
        get { settings.configationState }
        set { update(settings: settings.update(configationState: newValue)) }
    }

    var isCloudBackupEnabled: Bool {
        get { settings.isCloudBackupEnabled }
        set { update(settings: settings.update(isCloudBackupEnabled: newValue)) }
    }

    var hasVerifiedSeedPhrase: Bool {
        get { settings.hasVerifiedSeedPhrase }
        set { update(settings: settings.update(hasVerifiedSeedPhrase: newValue)) }
    }

    private func update(settings: WalletSettings) {
        var allSettings = GroupUserDefaults.walletSettings ?? []
        allSettings.removeAll { $0 == settings }
        allSettings.append(settings)
        GroupUserDefaults.walletSettings = allSettings
    }
}
