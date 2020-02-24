//
//  Created by Andreas Braun on 20.02.20.
//  Copyright © 2020 Andreas Braun. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

class SettingsController: ObservableObject {
    var furiganaOptions: [LocalizedStringKey] = [
        "furigana.off",
        "furigana.on",
        "furigana.wanikani"
    ]

    static var appearanceOptions: [LocalizedStringKey] = [
        "system",
        "light",
        "dark",
        "Bunpro Theme"
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
}
