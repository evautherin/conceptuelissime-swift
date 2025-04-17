//
//  ActivityInitialState.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 15/04/2025.
//


public protocol ActivityInitialState: ActivityContentState {
    static var initialState: Self { get }
}

extension Optional: ActivityInitialState where Wrapped: ActivityContentState {
    public static var initialState: Optional<Wrapped> { .none }
}
