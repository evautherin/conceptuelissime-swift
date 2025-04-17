//
//  ActivityState.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 10/04/2025.
//

import Foundation
import ActivityKit


public protocol ActivityState: Sendable, Codable, Hashable { }

extension ActivityState {
    public typealias Content = ActivityContent<Self>
    public typealias ActivityUpdate = Content.ActivityUpdate
    
    public var activityContent: Content {
        ActivityContent<Self>(state: self, staleDate: .none, relevanceScore: 0.0)
    }
    
    public var activityUpdate: ActivityUpdate {
        print("ActivityState.activityUpdate")
        return (activityContent, .none, .none)
    }
}

extension Optional: ActivityState where Wrapped: ActivityState { }

extension ActivityContent where State: ActivityState {
    public typealias ActivityUpdate = (Self, AlertConfiguration?, Date?)
}
