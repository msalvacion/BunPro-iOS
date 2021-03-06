//
//  Created by Andreas Braun on 19.12.16.
//  Copyright © 2017 Andreas Braun. All rights reserved.
//

import UIKit

public protocol StoryboardIdentifiable { /* only needed for providing behavior via extension */ }

public extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController: StoryboardIdentifiable { }

public extension UIStoryboard {
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewCtrl = instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Could not instantiate View Controller with identifier: \(T.storyboardIdentifier)")
        }

        return viewCtrl
    }
}
