//
//  ActivityLifeCycle.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 05/03/2025.
//

import Foundation
import ActivityKit
import CoreLocation
import AsyncAlgorithms


public actor ActivityLifeCycle<Attributes>
  where
    Attributes: Sendable,
    Attributes: ActivityAttributes,
    Attributes.ContentState: UpdateConstructor,
    Attributes.ContentState: ActivityLiveState,
    Attributes.ContentState: ActivityInitialState
{
    private var activity: Activity<Attributes>?
    
    private init(_ attributes: Attributes) throws {
        let activity = try Activity.request(
            attributes: attributes,
            content: Attributes.ContentState.initialState.activityContent,
            pushType: nil
        )
        self.activity = activity
    }
    
    private func complete() async throws {
        guard let activity else { return }
        
        let cycleStates = states(activity.activityStateUpdates)
        waitingCompletion: for try await state in cycleStates {
            print("Cycle state is \(state)")
            switch state {
            case .completed: break waitingCompletion
            default: break
            }
        }
    }
    
    public static func proceed(_ attributes: Attributes) throws {
        let lifeCycle = try ActivityLifeCycle(attributes)

        Task {
            do {
                try await lifeCycle.complete()
                print("ActivityLifeCycle proceed finished")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension ActivityLifeCycle {
    
    enum State {
        case initial
        case updates(Task<Void, Error>)
        case completed
    }
    
    enum Action {
        case stop
        case run
    }
    
    private var updatesState: State {
        .updates(Task {
            print("Updates task started")
            for try await element in Attributes.ContentState.liveUpdates() {
                let newState = element as! Attributes.ContentState
                print("New state is \(newState)")
                activity?.update(newState.activityUpdate)
            }
        })
    }
    
    static func actions<StatesUpdates>(
        _ activityStateUpdates: StatesUpdates
    ) -> AsyncMapSequence<some AsyncSequence, Action>
    where
      StatesUpdates: AsyncSequence,
      StatesUpdates.Element == ActivityState
    {
        activityStateUpdates
            .map { observedState -> Action in
                print("Observed state is \(observedState)")
                return switch observedState {
                case .active, .stale: .run
                case .ended, .dismissed: .stop
                @unknown default: .stop
                }
            }
    }
    
    func reducer(state: inout State, action: Action) async {
        print("Action is \(action)")
        switch (state, action) {
        case (.initial, .stop), (.updates(_), .run), (.completed, _):
            break
            
        case (.initial, .run):
            state = updatesState
            
        case (.updates(let task), .stop):
            task.cancel()
            state = .completed
        }
    }
    
    func states<StateUpdates>(
        _ activityStateUpdates: StateUpdates
    ) -> AsyncExclusiveReductionsSequence<some SendableAsyncSequence, State>
    where
      StateUpdates: AsyncSequence,
      StateUpdates.Element == ActivityState
    {
        Self.actions(activityStateUpdates)
            .reductions(into: .initial, reducer)
    }
}

// https://forums.swift.org/t/distinction-between-isolated-any-and-inheritactorcontext/75730/10
// _ = isolation // a capture affects the static isolation

extension Activity
  where
    Attributes.ContentState: ActivityLiveState,
    Attributes.ContentState: ActivityInitialState
{
    func update(
        isolation: isolated (any Actor)? = #isolation,
        _ activityUpdate: Attributes.ContentState.ActivityUpdate
    ) {
        Task {
            _ = isolation
            
            let (content, alert, timestamp) = activityUpdate
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
