//
//  ReduxReducer.swift
//  ExchangeCurrency
//
//  Created by Rone Shender on 26/10/21.
//

import Foundation

open class ReduxReducer<StateType: ReduxState> {
    
    public init() {}
    
    open func reduce(state: StateType, action: ReduxAction) -> StateType {
        return state
    }
    
}

public class ReduxEmptyReducer<StateType: ReduxState>: ReduxReducer<StateType> {
    
}
