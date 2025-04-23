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
    
    private enum Action {
        case enterBackground
        case exitBackground
    }
    
    private enum State {
        case noSession
        case session(CLServiceSession)
    }
    
    private static func sessions(
    ) -> AsyncExclusiveReductionsSequence<some SendableAsyncSequence, State> {
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
                    
                case (.session(let session), .exitBackground):
                    print("Session invalidated")
                    session.invalidate()
                    state = .noSession
                }
            }
    }
    
    public static func liveUpdates(
    ) -> AsyncMapSequence<some AsyncSequence, CLLocationUpdate> {
        combineLatest(CLLocationUpdate.liveUpdates(), sessions())
            .map(\.0)
    }
}
