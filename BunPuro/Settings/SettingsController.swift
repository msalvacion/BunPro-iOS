//
//  Created by Andreas Braun on 20.02.20.
//  Copyright © 2020 Andreas Braun. All rights reserved.
//

import BunProKit
import Combine
import Foundation
import SwiftUI
import UIKit

class SettingsController: ObservableObject {
    weak var presentingViewController: UIViewController?

    private(set) var account: BPKAccount? {
        didSet { self.update() }
    }

    var furiganaOptions: [LocalizedStringKey] = [
        "settings.review.furigana.off",
        "settings.review.furigana.on",
        "settings.review.furigana.wanikani"
    ]

    var appearanceOptions: [LocalizedStringKey] = [
        "settings.other.appearance.system",
        "settings.other.appearance.light",
        "settings.other.appearance.dark",
        "settings.other.appearance.bunpro"
    ]

    var selectedFuriganaOption: Int = 0 {
        didSet { objectWillChange.send() }
    }

    var isEnglishHidden: Bool = false {
        didSet { objectWillChange.send() }
    }

    var isBunnyModeOn: Bool = false {
        didSet { objectWillChange.send() }
    }

    var selectedAppearanceOption: Int = 0 {
        didSet { objectWillChange.send() }
    }

    var objectWillChange = PassthroughSubject<Void, Never>()

    init(presentingViewController: UIViewController?) {
        self.presentingViewController = presentingViewController
    }

    func fetch() {
        guard let presentingViewCtrl = self.presentingViewController else {
            log.info("No presentingViewController was set or has been released.")
            return
        }

        Server.add(
            procedure: UserProcedure(
                presentingViewController: presentingViewCtrl
            ) { [weak self] account, error in
                guard let self = self else { return }

                if let error = error {
                    log.info(error.localizedDescription)
                }

                self.account = account
            }
        )
    }

    private func update() {
        guard let account = self.account else {
            log.info("Update called but no account set (should only happen on logout).")
            return
        }

        selectedFuriganaOption = FuriganaMode.allCases.firstIndex(of: account.furigana) ?? 0
        isEnglishHidden = account.hideEnglish == .yes
        isBunnyModeOn = account.bunnyMode == .on
//        selectedAppearanceOption = UserDefaults.
    }
}
