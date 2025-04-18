//
//  ScenePhaseChange.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 10/03/2025.
//

import SwiftUI

/// Example:
/// ```swift
/// struct MyApp: App {
///     var body: some Scene {
///         ScenePhaseWindowGroup {
///             ContentView()
///         }
///     }
/// }
/// ```

public actor AsyncScenePhase {
    private typealias Continuation = AsyncStream<(ScenePhase, ScenePhase)>.Continuation
    static private var continuations = [UUID : Continuation]()
    static public var scenePhase: ScenePhase?
    
    static func onChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        scenePhase = newPhase
        continuations.values.forEach { continuation in
            continuation.yield((oldPhase, newPhase))
        }
    }
    
    public typealias Changes = AsyncStream<(ScenePhase, ScenePhase)>
    public static func changes() -> Changes {
        AsyncStream { continuation in
            let uuid = UUID()
            self.continuations[uuid] = continuation
            
            continuation.onTermination = { termination in
                self.continuations.removeValue(forKey: uuid)
            }
        }
    }
    
    public typealias Phases = AsyncMapSequence<Changes, ScenePhase>
    public static func phases() -> Phases {
        changes().map(\.1)
    }
}

public struct ScenePhaseWindowGroup<Content: View>: Scene {
    @Environment(\.scenePhase) private var scenePhase
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some Scene {
        WindowGroup {
            content
        }
        .onChange(of: scenePhase, initial: true, AsyncScenePhase.onChange)
    }
}

