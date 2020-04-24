//
//  Created by Andreas Braun on 17.01.18.
//  Copyright © 2018 Andreas Braun. All rights reserved.
//

import BunProKit
import Combine
import CoreData
import Foundation
import SafariServices
import UIKit

final class DataManager {
    let presentingViewController: UIViewController
    let database: Database

    private var loginObserver: AnyCancellable?
    private var logoutObserver: AnyCancellable?
    private var backgroundObserver: AnyCancellable?

    private var subscribers = Set<AnyCancellable>()

    deinit {
        loginObserver?.cancel()
        logoutObserver?.cancel()
        backgroundObserver?.cancel()
    }

    init(presentingViewController: UIViewController, database: Database) {
        self.presentingViewController = presentingViewController
        self.database = database

        loginObserver = NotificationCenter
            .default
            .publisher(for: .ServerDidLoginNotification)
            .receive(on: RunLoop.main)
            .print()
            .sink {  [weak self] _ in
                self?.updateGrammarDatabase()
            }

        logoutObserver = NotificationCenter
            .default
            .publisher(for: .ServerDidLogoutNotification)
            .receive(on: RunLoop.main)
            .print()
            .sink {  [weak self] _ in
                self?.database.resetReviews()
                self?.scheduleUpdateProcedure()
            }

        backgroundObserver = NotificationCenter
            .default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: RunLoop.main)
            .print()
            .sink {  [weak self] _ in
                self?.stopStatusUpdates()
                self?.isUpdating = false
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
            startImmediately.toggle()
            scheduleUpdateProcedure()
        }

        guard isUpdating == false else { return }

        stopStatusUpdates()

        Timer
            .publish(every: updateTimeInterval, on: RunLoop.main, in: .common)
            .print()
            .drop { [weak self] _ in self?.isUpdating == true }
            .sink { [weak self] _ in
                self?.scheduleUpdateProcedure()
            }
            .store(in: &subscribers)
    }

    func stopStatusUpdates() {
        subscribers.forEach { $0.cancel() }
    }

    func immidiateStatusUpdate() {
        self.scheduleUpdateProcedure()
    }

    private func needsGrammarDatabaseUpdate() -> Bool {
        let lastUpdate = Settings.lastDatabaseUpdate

        return Date().hours(from: lastUpdate) > 7 * 24
    }

    private func updateGrammarDatabase() {
        guard needsGrammarDatabaseUpdate() else { return }

        let updateProcedure = GrammarPointsProcedure(presentingViewController: presentingViewController)
        updateProcedure.addDidFinishBlockObserver { procedure, error in
            if let error = error {
                log.error(error.localizedDescription)
            } else if let grammar = procedure.output.value?.value {
                self.database.updateGrammar(grammar) {
                    Settings.lastDatabaseUpdate = Date()
                }
            }
        }

        Server.add(procedure: updateProcedure)
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

        Server
            .updateStatus(from: presentingViewController)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    log.info(completion)
                },
                receiveValue: { [weak self] account, reviews in
                    guard let self = self else { return }

                    // update the account
                    self.database.updateAccount(account, completion: nil)

                    // update the reviews
                    let oldReviewsCount = AppDelegate.badgeNumber()?.intValue ?? 0

                    self.database.updateReviews(reviews) {
                        self.isUpdating = false

                        // update pending review modifications
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
                }
            )
            .store(in: &subscribers)
    }
}

extension Notification.Name {
    static let BunProWillBeginUpdating = Notification.Name(rawValue: "BunProWillBeginUpdating")
    static let BunProDidEndUpdating = Notification.Name(rawValue: "BunProDidEndUpdating")
}

extension Notification.Name {
    static let BunProDidModifyReview = Notification.Name(rawValue: "BunProDidModifyReview")
}
