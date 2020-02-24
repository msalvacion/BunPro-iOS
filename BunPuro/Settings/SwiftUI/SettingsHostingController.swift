//
//  Created by Andreas Braun on 20.02.20.
//  Copyright © 2020 Andreas Braun. All rights reserved.
//

import SwiftUI
import UIKit

class SettingsHostingController: UIHostingController<SettingsView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SettingsView(settingsController: SettingsController()))
    }
}
