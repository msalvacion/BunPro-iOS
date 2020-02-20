//
//  Created by Andreas Braun on 05.11.19.
//  Copyright © 2019 Andreas Braun. All rights reserved.
//

import Combine
import Foundation

protocol StatusObserverProtocol {
    var didLogout: (() -> Void)? { get set }
    var willBeginUpdating: (() -> Void)? { get set }
    var didEndUpdating: (() -> Void)? { get set }
    var didUpdateReview: (() -> Void)? { get set }
}

class StatusObserver {
    private init() {}

    static func newObserver() -> StatusObserverProtocol {
        StatusObserverImplementationCombine()
    }
}

private class StatusObserverImplementationCombine: StatusObserverProtocol {
    private var cancellables: Set<AnyCancellable> = []

    var didLogout: (() -> Void)? {
        didSet {
            NotificationCenter
                .default
                .publisher(for: .ServerDidLogoutNotification)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in self?.didLogout?() }
                .store(in: &cancellables)
        }
    }

    var willBeginUpdating: (() -> Void)? {
        didSet {
            NotificationCenter
                .default
                .publisher(for: .BunProWillBeginUpdating)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in self?.willBeginUpdating?() }
                .store(in: &cancellables)
        }
    }

    var didEndUpdating: (() -> Void)? {
        didSet {
            NotificationCenter
                .default
                .publisher(for: .BunProDidEndUpdating)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in self?.didEndUpdating?() }
                .store(in: &cancellables)
        }
    }
    var didUpdateReview: (() -> Void)? {
        didSet {
            NotificationCenter
                .default
                .publisher(for: .BunProDidModifyReview)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in self?.didUpdateReview?() }
                .store(in: &cancellables)
        }
    }
}
