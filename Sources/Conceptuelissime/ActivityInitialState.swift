//
//  ActivityInitialState.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 15/04/2025.
//


public protocol ActivityInitialState: ActivityState {
    static var initialState: Self { get }
}

extension Optional: ActivityInitialState where Wrapped: ActivityState {
    public static var initialState: Optional<Wrapped> { .none }
}
