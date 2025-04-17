//
//  AsyncState.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 04/03/2025.
//


public protocol ActivityLiveState: ActivityContentState {
    static func liveUpdates() -> any SendableAsyncSequence // with Element == Self
}

extension Optional: ActivityLiveState where Wrapped: ActivityLiveState {
    public static func liveUpdates() -> any SendableAsyncSequence {
        print("Optional liveUpdates")
        return Wrapped.liveUpdates()
    }
}
