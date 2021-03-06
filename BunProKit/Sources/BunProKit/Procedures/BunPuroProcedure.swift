//
//  Created by Andreas Braun on 27.11.17.
//  Copyright © 2017 Andreas Braun. All rights reserved.
//

import UIKit
import Foundation
import ProcedureKit
import ProcedureKitNetwork


public class BunPuroProcedure<T: Codable>: GroupProcedure, OutputProcedure {
    public var output: Pending<ProcedureResult<T>> {
        get { return _transformProcedure.output }
        set { assertionFailure("\(#function) should not be called") } // swiftlint:disable:this unused_setter_value
    }

    private var _networkProcedure: NetworkProcedure<NetworkDataProcedure>!
    private var _transformProcedure: TransformProcedure<Data, T>!

    public let completion: ((T?, Error?) -> Void)?

    var url: URL { fatalError("Needs to be implemented by the subclass.") }
    var hasMilliseconds: Bool { return false }

    deinit {
        print("\(self) deinit")
    }
    
    public init(presentingViewController: UIViewController, completion: ((T?, Error?) -> Void)? = nil) {
        self.completion = completion

        super.init(operations: [])

        addCondition(LoggedInCondition(presentingViewController: presentingViewController))
    }

    override public func execute() {
        guard !isCancelled else { return }
        guard let token = Server.token else { cancel(with: ServerError.noAPIToken); super.execute(); return }

        var request = URLRequest(url: url)

        request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")

        _networkProcedure = NetworkProcedure(resilience: DefaultNetworkResilience(requestTimeout: nil)) {
            NetworkDataProcedure(session: URLSession.shared, request: request)
        }
        _transformProcedure = TransformProcedure<Data, T> {
            do {
                _ = try CustomDecoder.decode(T.self, from: $0, hasMilliseconds: self.hasMilliseconds)
            } catch {
                let jsonObject = try JSONSerialization.jsonObject(with: $0, options: [.allowFragments])
                logger.info(jsonObject)
            }

            return try CustomDecoder.decode(T.self, from: $0, hasMilliseconds: self.hasMilliseconds)
        }
        _transformProcedure.injectPayload(fromNetwork: _networkProcedure)

        _transformProcedure.addCondition(NoFailedDependenciesCondition())

        addChild(_networkProcedure)
        addChild(_transformProcedure)

        super.execute()
    }

    override public func procedureDidFinish(with error: Error?) {
        completion?(output.value?.value, output.error)
    }
}
