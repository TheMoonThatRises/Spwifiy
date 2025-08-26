//
//  CombineHandler.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import Foundation
import Combine

class CombineHandler {

    static var cancellables: Set<AnyCancellable> = []

    static func handler<T>(publisher: AnyPublisher<T, Error>,
                           sink: ((Subscribers.Completion<any Error>) -> Void)? = nil,
                           receiveValue: ((T) -> Void)? = nil) {
        let cancellable = publisher
            .sink { completion in
                sink?(completion)
            } receiveValue: { value in
                receiveValue?(value)
            }

        Task { @MainActor in
            cancellable
                .store(in: &cancellables)
        }
    }

    static func handler<T>(passthrough: PassthroughSubject<T, Never>,
                           sink: ((Subscribers.Completion<Never>) -> Void)? = nil,
                           receiveValue: ((T) -> Void)? = nil) {
        let cancellable = passthrough
            .receive(on: RunLoop.main)
            .sink { completion in
                sink?(completion)
            } receiveValue: { value in
                receiveValue?(value)
            }

        Task { @MainActor in
            cancellable
                .store(in: &cancellables)
        }
    }

}
