//
//  AlwaysLocationUpdate.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 12/03/2025.
//

import CoreLocation
import AsyncAlgorithms


public enum AlwaysLocationUpdate {
    static func sessions(
    ) -> AsyncExclusiveReductionsSequence<some SendableAsyncSequence, CLServiceSession?>
    {
        AsyncScenePhase.phases()
            .map { phase in
                switch phase {
                case .background: CLServiceSession(authorization: .always)
                default: CLServiceSession?.none
                }
            }
            .reductions(CLServiceSession?.none) { (previousSession, session) in
                previousSession?.invalidate()
                return session
            }
    }
    
    public static func liveUpdates(
    ) -> AsyncMapSequence<some AsyncSequence, CLLocationUpdate> {
        combineLatest(CLLocationUpdate.liveUpdates(), sessions())
            .map(\.0)
    }
}
