//
//  UpdateConstructor.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 17/04/2025.
//

import ActivityKit


public protocol UpdateConstructor: ActivityContentState {
    var activityContent: Content { get }
    
    var activityUpdate: ActivityUpdate { get }
}

extension UpdateConstructor {
    public var activityContent: Content {
        ActivityContent<Self>(state: self, staleDate: .none, relevanceScore: 0.0)
    }
    
    public var activityUpdate: ActivityUpdate {
        print("ActivityState.activityUpdate")
        return (activityContent, .none, .none)
    }
}
