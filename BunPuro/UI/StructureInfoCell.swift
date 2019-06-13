//
//  Created by Andreas Braun on 23.01.18.
//  Copyright © 2018 Andreas Braun. All rights reserved.
//

import UIKit

final class StructureInfoCell: UITableViewCell {
    @IBOutlet private weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 0
        }
    }

    var attributedDescription: NSAttributedString? {
        get {
            return descriptionLabel?.attributedText
        }
        set {
            guard let string = newValue?.string else { return }

            let linkAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                NSAttributedString.Key.underlineColor: UIColor.clear
            ]

            descriptionLabel?.attributedText = NSAttributedString(string: string, attributes: linkAttributes)
        }
    }

    @IBOutlet private weak var structureContentView: UIView! {
        didSet {
            structureContentView.layer.borderColor = Asset.background.color.cgColor
            structureContentView.layer.borderWidth = 0.5
            structureContentView.layer.cornerRadius = 9.0
        }
    }
}
