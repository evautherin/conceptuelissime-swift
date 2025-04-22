//
//  AlwaysLocationUpdate.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 12/03/2025.
//

import CoreLocation
import SwiftUI
import AsyncAlgorithms


public enum AlwaysLocationUpdate {
    private static var scenePhases: AsyncMapSequence<some AsyncSequence, ScenePhase> {
        let currentPhase = AsyncScenePhase.scenePhase
        let sequenceOfCurrentPhase = CollectionOfOne(currentPhase).async.compacted()
        
        return chain(sequenceOfCurrentPhase, AsyncScenePhase.scenePhases())
            .map { $0 }
    }
    
    static func sessions(
    ) -> AsyncExclusiveReductionsSequence<some SendableAsyncSequence, CLServiceSession?>
    {
        scenePhases
            .map { phase in
                print("Phase: \(phase)")
                return switch phase {
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
