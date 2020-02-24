//
//  Created by Andreas Braun on 24.02.20.
//  Copyright © 2020 Andreas Braun. All rights reserved.
//

import Foundation
import SwiftUI

extension LocalizedStringKey: Identifiable {
    public var id: String { "\(self)" }
}
