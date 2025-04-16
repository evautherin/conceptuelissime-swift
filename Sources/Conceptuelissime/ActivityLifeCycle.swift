//
//  ActivityLifeCycle.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 05/03/2025.
//

import Foundation
import ActivityKit


public actor ActivityLifeCycle<Attributes>
  where
    Attributes: Sendable,
    Attributes: ActivityAttributes,
    Attributes.ContentState: ActivityLiveState,
    Attributes.ContentState: ActivityInitialState
{
    private var activity: Activity<Attributes>?
    
    private init(_ attributes: Attributes) async throws {
        let activity = try Activity.request(
            attributes: attributes,
            content: Attributes.ContentState.initialState.activityContent,
            pushType: nil
        )
        self.activity = activity
    }
    
    public static func proceed(_ attributes: Attributes) async throws {
        let lifeCycle = try await ActivityLifeCycle(attributes)
        try await lifeCycle.complete()
    }
}

extension ActivityLifeCycle {
    
    private enum State {
        case initial
        case mutations(Task<Void, Error>)
        case completed
    }
    
    private enum Action {
        case stop
        case run
    }

    private func complete() async throws {
        guard let activity else { return }
        
        let cycleStates = activity.activityStateUpdates
            .map { observedState -> Action in
                switch observedState {
                case .active, .stale: .run
                case .ended, .dismissed: .stop
                @unknown default: .stop
                }
            }
            .reductions(into: State.initial) { (state, action) in
                switch (state, action) {
                case (.initial, .stop), (.mutations(_), .run), (.completed, _):
                    break
                    
                case (.initial, .run):
                    state = await self.mutationsState
                    
                case (.mutations(let task), .stop):
                    task.cancel()
                    state = .completed
                }
            }
        
        waitingCompletion: for await state in cycleStates {
            switch state {
            case .completed: break waitingCompletion
            default: break
            }
        }
    }
    
    private var mutationsState: State {
        .mutations(Task {
            for try await mutation in ActivityMutations<Attributes>() {
                activity?.mutate(mutation)
            }
        })
    }
}

extension Activity
  where
    Attributes.ContentState: ActivityLiveState,
    Attributes.ContentState: ActivityInitialState
{
    func mutate(
        isolation: isolated (any Actor)? = #isolation,
        _ mutation: Attributes.ContentState.Mutation
    ) {
        Task {
            // https://forums.swift.org/t/distinction-between-isolated-any-and-inheritactorcontext/75730/10
            _ = isolation // a capture affects the static isolation
            
            let (content, alert, timestamp) = mutation
            switch timestamp {
            case .none:
                print("Update without timestamp")
                await self.update(content, alertConfiguration: alert)
                
            case .some(let timestamp):
                print("Update with timestamp: \(timestamp)")
                await self.update(
                    content,
                    alertConfiguration: alert,
                    timestamp: timestamp
                )
            }
        }
    }
}
