//
//  ActivityMutations.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 05/03/2025.
//

import Foundation
import ActivityKit


public struct ActivityMutations<Attributes>: SendableAsyncSequence
  where
    Attributes: ActivityAttributes,
    Attributes.ContentState: ActivityLiveState
{
    public typealias State = Attributes.ContentState
    public typealias Content = ActivityContent<State>

    let stateUpdates = State.liveUpdates()
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        public typealias Element = Content.Mutation
        public typealias Failure = Error
        
        var stateIterator: any AsyncIteratorProtocol
        
        mutating public func next() async throws -> Element? {
            print("Waiting for next mutation...")
           let mutation = try await (stateIterator.next() as? State)?.activityMutation
            print("next mutation is \(mutation.debugDescription)")
            return mutation
        }
    }
    
    nonisolated public func makeAsyncIterator() -> AsyncIterator {
        print("ActivityMutations makeAsyncIterator")
        return AsyncIterator(stateIterator: stateUpdates.makeAsyncIterator())
    }
}
