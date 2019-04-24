//
//  Created by Andreas Braun on 17.01.18.
//  Copyright © 2018 Andreas Braun. All rights reserved.
//

import BunPuroKit
import CoreData
import Foundation
import ProcedureKit
import SafariServices
import UIKit

final class DataManager {
    private let procedureQueue = ProcedureQueue()

    let presentingViewController: UIViewController
    private let persistentContainer: NSPersistentContainer

    private var loginObserver: NotificationToken?
    private var logoutObserver: NotificationToken?

    deinit {
        if loginObserver != nil {
            NotificationCenter.default.removeObserver(loginObserver!)
        }

        if logoutObserver != nil {
            NotificationCenter.default.removeObserver(logoutObserver!)
        }
    }

    init(presentingViewController: UIViewController, persistentContainer: NSPersistentContainer = AppDelegate.coreDataStack.storeContainer) {
        self.presentingViewController = presentingViewController
        self.persistentContainer = persistentContainer

        loginObserver = NotificationCenter.default.observe(name: .ServerDidLoginNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.updateGrammarDatabase()
        }

        logoutObserver = NotificationCenter.default.observe(name: .ServerDidLogoutNotification, object: nil, queue: nil) { [weak self] _ in
            DispatchQueue.main.async {
                self?.procedureQueue.addOperation(ResetReviewsProcedure())
                self?.scheduleUpdateProcedure()
            }
        }
    }

    // Status Updates
    private let updateTimeInterval = TimeInterval(60 * 5)
    private var startImmediately: Bool = true
    var isUpdating: Bool = false {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.isUpdating ? .BunProWillBeginUpdating : .BunProDidEndUpdating, object: self)
            }
        }
    }
    private var statusUpdateTimer: Timer? { didSet { statusUpdateTimer?.tolerance = 10.0 } }

    private var hasPendingReviewModification: Bool = false

    func startStatusUpdates() {
        if startImmediately {
            startImmediately = false
            scheduleUpdateProcedure()
        }

        guard !isUpdating else { return }

        stopStatusUpdates()

        statusUpdateTimer = Timer(timeInterval: updateTimeInterval, repeats: true) { _ in
            guard !self.isUpdating else { return }
            self.scheduleUpdateProcedure()
        }

        RunLoop.main.add(statusUpdateTimer!, forMode: RunLoop.Mode.default)
    }

    func stopStatusUpdates() {
        statusUpdateTimer?.invalidate()
        statusUpdateTimer = nil
    }

    func immidiateStatusUpdate() {
        self.scheduleUpdateProcedure()
    }

    private func updateGrammarDatabase() {
        let updateProcedure = UpdateGrammarProcedure(presentingViewController: presentingViewController)
        Server.add(procedure: updateProcedure)
    }

    func signupForTrial() {
        self.isUpdating = true

        let signupForTrialProcedure = ActivateTrialPeriodProcedure(presentingViewController: presentingViewController) { user, _ in
            guard let user = user else {
                DispatchQueue.main.async {
                    self.isUpdating = false
                }

                return
            }

            DispatchQueue.main.async {
                let importProcedure = ImportAccountIntoCoreDataProcedure(account: user, progress: nil)

                importProcedure.addDidFinishBlockObserver { _, _ in
                    self.isUpdating = false
                }

                self.procedureQueue.addOperation(importProcedure)
            }
        }

        Server.add(procedure: signupForTrialProcedure)
    }

    func signup() {
        let url = URL(string: "https://bunpro.jp")!
        let safariViewCtrl = SFSafariViewController(url: url)

        safariViewCtrl.preferredBarTintColor = .black
        safariViewCtrl.preferredControlTintColor = Asset.mainTint.color

        presentingViewController.present(safariViewCtrl, animated: true, completion: nil)
    }

    func modifyReview(_ modificationType: ModifyReviewProcedure.ModificationType) {
        let addProcedure = ModifyReviewProcedure(presentingViewController: presentingViewController, modificationType: modificationType) { error in
            log.error(error ?? "No Error")

            if error == nil {
                DispatchQueue.main.async {
                    self.hasPendingReviewModification = true
                    AppDelegate.setNeedsStatusUpdate()
                }
            }
        }

        Server.add(procedure: addProcedure)
    }

    func scheduleUpdateProcedure(completion: ((UIBackgroundFetchResult) -> Void)? = nil) {
        self.isUpdating = true

        let statusProcedure = StatusProcedure(presentingViewController: presentingViewController) { user, reviews, _ in
            DispatchQueue.main.async {
                if let user = user {
                    let importProcedure = ImportAccountIntoCoreDataProcedure(account: user)

                    importProcedure.addDidFinishBlockObserver { _, _ in
                        self.isUpdating = false
                    }

                    self.procedureQueue.addOperation(importProcedure)
                }

                if let reviews = reviews {
                    let oldReviewsCount = AppDelegate.badgeNumber()?.intValue ?? 0

                    let importProcedure = ImportReviewsIntoCoreDataProcedure(reviews: reviews)

                    importProcedure.addDidFinishBlockObserver { _, _ in
                        self.isUpdating = false

                        self.startStatusUpdates()

                        if self.hasPendingReviewModification {
                            self.hasPendingReviewModification = false
                            NotificationCenter.default.post(name: .BunProDidModifyReview, object: nil)
                        }

                        DispatchQueue.main.async {
                            let newReviewsCount = AppDelegate.badgeNumber()?.intValue ?? 0
                            let hasNewReviews = newReviewsCount > oldReviewsCount
                            if hasNewReviews {
                                UserNotificationCenter.shared.scheduleNextReviewNotification(
                                    at: Date().addingTimeInterval(1.0),
                                    reviewCount: newReviewsCount - oldReviewsCount
                                )
                            }

                            completion?(hasNewReviews ? .newData : .noData)
                        }
                    }

                    self.procedureQueue.addOperation(importProcedure)
                }
            }
        }

        Server.add(procedure: statusProcedure)
    }
}

extension Notification.Name {
    static let BunProWillBeginUpdating = Notification.Name(rawValue: "BunProWillBeginUpdating")
    static let BunProDidEndUpdating = Notification.Name(rawValue: "BunProDidEndUpdating")
}

extension Notification.Name {
    static let BunProDidModifyReview = Notification.Name(rawValue: "BunProDidModifyReview")
}
