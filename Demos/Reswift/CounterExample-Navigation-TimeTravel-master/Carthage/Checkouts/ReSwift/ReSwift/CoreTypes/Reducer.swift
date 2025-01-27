//
//  Reducer.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol AnyReducer {
    func re_handleAction(action: Action, state: StateType?) -> StateType
}

public protocol Reducer: AnyReducer {
    associatedtype ReducerStateType

    func handleAction(action: Action, state: ReducerStateType?) -> ReducerStateType
}

extension Reducer {
    public func re_handleAction(action: Action, state: StateType?) -> StateType {
        return withSpecificTypes(action, state: state, function: handleAction)
    }
}
