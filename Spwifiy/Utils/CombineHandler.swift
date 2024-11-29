//
//  CombineHandler.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import Combine

class CombineHandler {

    static var cancellables: Set<AnyCancellable> = []

    static func handler<T>(result: AnyPublisher<T, Error>,
                           sink: ((Subscribers.Completion<any Error>) -> Void)? = nil,
                           receiveValue: ((T) -> Void)? = nil) {
        let cancellable = result
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
