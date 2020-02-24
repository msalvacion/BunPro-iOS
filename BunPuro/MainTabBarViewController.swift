//
//  Created by Andreas Braun on 21.02.20.
//  Copyright © 2020 Andreas Braun. All rights reserved.
//

import BunProKit
import Combine
import UIKit

class MainTabBarViewController: UITabBarController {
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter
            .default
            .publisher(for: .ServerDidLogoutNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.selectedIndex = 0
            }.store(in: &subscriptions)
    }
}
