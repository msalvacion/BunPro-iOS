//
//  Created by Andreas Braun on 20.02.20.
//  Copyright © 2020 Andreas Braun. All rights reserved.
//

import SwiftUI
import UIKit

class SettingsHostingController: UIHostingController<SettingsView> {
    private let settingsController: SettingsController!

    required init?(coder aDecoder: NSCoder) {
        let root = UIApplication.shared.windows.first?.rootViewController
        settingsController = SettingsController(presentingViewController: root)
        super.init(coder: aDecoder, rootView: SettingsView(settingsController: settingsController))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        settingsController.fetch()
    }
}
