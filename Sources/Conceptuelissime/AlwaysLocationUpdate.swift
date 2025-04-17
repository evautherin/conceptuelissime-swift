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
    private static var phases: AsyncMapSequence<some AsyncSequence, ScenePhase> {
        let currentPhase = AsyncScenePhase.scenePhase
        let prefixSequence = [currentPhase].async.compacted()
        
        return chain(prefixSequence, AsyncScenePhase.phases())
            .map { $0 }
    }
    
    static func sessions(
    ) -> AsyncExclusiveReductionsSequence<some SendableAsyncSequence, CLServiceSession?>
    {
        phases
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
