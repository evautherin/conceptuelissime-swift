//
//  AlwaysLocationUpdateTests.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 24/04/2025.
//

import Testing
@testable import Conceptuelissime
import SwiftUI

struct AlwaysLocationUpdateTests {
    @Test func testSessionsSequenceTransitions() async throws {
        // Given: A simulated sequence of scene phases
        let testPhases: [ScenePhase] = [.inactive, .background, .active]
        let testPhaseSequence = testPhases.async

        // When: Create the session sequence
        let sequence = AlwaysLocationUpdate.sessions(testPhaseSequence)
        var observedStates: [String] = []

        // Capture first few state transitions
        for try await state in sequence.prefix(3) {
            switch state {
            case .noSession:
                observedStates.append("noSession")
            case .session:
                observedStates.append("session")
            }
        }

        // Then: Expect a correct transition through session states
        #expect(observedStates == ["noSession", "session", "noSession"], "Session state transitions did not match expected pattern.")
    }
}
