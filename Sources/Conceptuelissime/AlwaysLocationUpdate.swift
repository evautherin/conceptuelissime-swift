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
    
    enum Action {
        case enterBackground
        case exitBackground
    }
    
    enum State {
        case noSession
        case session(CLServiceSession)
    }
    
    static func sessions<Phases>(
        _ scenePhases: Phases
    ) -> AsyncExclusiveReductionsSequence<some SendableAsyncSequence, State>
      where
        Phases: SendableAsyncSequence,
        Phases.Element == ScenePhase
    {
        scenePhases
            .map { phase -> Action in
                print("Phase: \(phase)")
                return switch phase {
                case .background: .enterBackground
                default: .exitBackground
                }
            }
            .reductions(into: State.noSession) { (state, action) in
                switch (state, action) {
                case (.noSession, .exitBackground), (.session, .enterBackground):
                    print("State unchanged")
                    break
                    
                case (.noSession, .enterBackground):
                    print("Session created")
                    state = .session(CLServiceSession(authorization: .always))
                    
                case (.session, .exitBackground):
                    print("Session invalidated")
//                    session.invalidate()
                    state = .noSession
                }
            }
    }
    
    public static func liveUpdates(
    ) -> AsyncMapSequence<some AsyncSequence, CLLocationUpdate> {
        combineLatest(CLLocationUpdate.liveUpdates(), sessions(scenePhases))
            .map(\.0)
    }
}
