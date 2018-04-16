//
//  StatusTableViewCell.swift
//  BunPuro
//
//  Created by Andreas Braun on 06.04.18.
//  Copyright © 2018 Andreas Braun. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {

    @IBOutlet private var reviewStatusLabel: UILabel!
    @IBOutlet private var reviewStatusNextDateLabel: UILabel!
    @IBOutlet private var reviewStatusLastUpdatedLabel: UILabel!
    
    @IBOutlet private var reviewNextHourLabel: UILabel!
    @IBOutlet private var reviewNextHourCountLabel: UILabel!
    @IBOutlet private var reviewTomorrowLabel: UILabel!
    @IBOutlet private var reviewTomorrowCountLabel: UILabel!
    
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        
        return formatter
    }()

    var isUpdating: Bool = false {
        didSet { isUpdating ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating() }
    }
    
    var nextReviewDate: Date? {
        didSet {
            guard let date = nextReviewDate else { reviewStatusNextDateLabel.text = " "; return }
            
            if date > Date() {
                reviewStatusLabel.textColor = .white
                reviewStatusNextDateLabel.text = dateFormatter.string(from: date)
            } else {
                reviewStatusLabel.textColor = UIColor(named: "Main Tint")
                reviewStatusNextDateLabel.text = NSLocalizedString("reviewtime.now", comment: "The string that indicates that a review is available")
            }
        }
    }
    var lastUpdateDate: Date? {
        didSet {
            guard let date = lastUpdateDate else { reviewStatusLastUpdatedLabel.text = " "; return }
            reviewStatusLastUpdatedLabel.text = "Updated: " + dateFormatter.string(from: date)
        }
    }
    var nextHourReviewCount: Int? {
        didSet {
            guard let count = nextHourReviewCount else { reviewNextHourCountLabel.text = " "; return }
            reviewNextHourCountLabel.text = "\(count)"
        }
    }
    var nextDayReviewCount: Int? {
        didSet {
            guard let count = nextDayReviewCount else { reviewTomorrowCountLabel.text = " "; return }
            reviewTomorrowCountLabel.text = "\(count)"
        }
    }

}