//
//  ActivityState.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 10/04/2025.
//

import Foundation
import ActivityKit


public protocol ActivityContentState: Sendable, Codable, Hashable { }

extension ActivityContentState {
    public typealias Content = ActivityContent<Self>
    public typealias ActivityUpdate = Content.ActivityUpdate    
}

extension Optional: ActivityContentState where Wrapped: ActivityContentState { }

extension ActivityContent where State: ActivityContentState {
    public typealias ActivityUpdate = (Self, AlertConfiguration?, Date?)
}

