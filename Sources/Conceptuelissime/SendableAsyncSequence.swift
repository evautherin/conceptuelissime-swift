//
//  SendableAsyncSequence.swift
//  conceptuelissime-swift
//
//  Created by Etienne Vautherin on 12/03/2025.
//

import AsyncAlgorithms

public protocol SendableAsyncSequence: Sendable, AsyncSequence
    where Element: Sendable { }


extension AsyncMapSequence: SendableAsyncSequence { }
extension AsyncCompactMapSequence: SendableAsyncSequence { }
extension AsyncFlatMapSequence: SendableAsyncSequence { }
extension AsyncPrefixSequence: SendableAsyncSequence { }

extension AsyncStream: SendableAsyncSequence { }

extension AsyncSyncSequence: SendableAsyncSequence { }
extension AsyncCombineLatest2Sequence: SendableAsyncSequence { }
extension AsyncExclusiveReductionsSequence: SendableAsyncSequence { }
extension AsyncChain2Sequence: SendableAsyncSequence { }
