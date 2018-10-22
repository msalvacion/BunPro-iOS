//
//  NSUserActivity+Shortcuts.swift
//  BunPuro
//
//  Created by Andreas Braun on 22.10.18.
//  Copyright © 2018 Andreas Braun. All rights reserved.
//

import Foundation
import Intents
import CoreSpotlight
import MobileCoreServices

extension NSUserActivity {
    
    enum ActivityType: String {
        case study = "com.bunpro.activity.study"
        case cram = "com.bunpro.activity.cram"
    }
    
    @available (iOS 12.0, *)
    static var studyActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: ActivityType.study.rawValue)
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        activity.title =  NSLocalizedString("shortcut.study.title", comment: "")
        activity.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(with: "shortcut.study.suggetedphrase") as String
        activity.userInfo = ["value": "key"]
        
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attributes.keywords = ["japanese", "grammar", "learn", "study"]
        
        activity.contentAttributeSet = attributes
        
        return activity
    }
    
    @available (iOS 12.0, *)
    static var cramActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: ActivityType.cram.rawValue)
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        activity.title = NSLocalizedString("shortcut.cram.title", comment: "")
        activity.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(with: "shortcut.cram.suggetedphrase") as String
        activity.userInfo = ["value": "key"]
        
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attributes.keywords = ["japanese", "grammar", "learn", "study"]
        
        activity.contentAttributeSet = attributes
        
        return activity
    }
}
