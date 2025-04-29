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
    enum Action {
        case enterBackground
        case exitBackground
    }
    
    enum State {
        case noSession
        case session(CLServiceSession)
    }
    
    static func actions() -> AsyncMapSequence<some AsyncSequence, Action> {
        AsyncScenePhase.scenePhases()
            .map { phase -> Action in
                print("Phase: \(phase)")
                return switch phase {
                case .background: .enterBackground
                default: .exitBackground
                }
            }
    }
    
    static func reducer(state: inout State, action: Action) async {
        switch (state, action) {
        case (.noSession, .exitBackground), (.session, .enterBackground):
            print("State unchanged")
            break
            
        case (.noSession, .enterBackground):
            print("Session created")
            state = .session(CLServiceSession(authorization: .always))
            
        case (.session, .exitBackground):
            print("Session invalidated")
            state = .noSession
        }
    }
    
    static func states(
        initial initialState: State,
    ) -> AsyncExclusiveReductionsSequence<some SendableAsyncSequence, State> {
        actions().reductions(into: initialState, reducer)
    }

    public static func liveUpdates(
    ) -> AsyncMapSequence<some AsyncSequence, CLLocationUpdate> {
        combineLatest(CLLocationUpdate.liveUpdates(), states(initial: .noSession))
            .map(\.0)
    }
}
