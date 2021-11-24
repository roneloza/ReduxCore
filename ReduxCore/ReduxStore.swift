//
//  ReduxStore.swift
//  ExchangeCurrency
//
//  Created by Rone Shender on 26/10/21.
//

import SwiftUI
import Combine

public protocol StoreProtocol: ObservableObject, DispatcherObject {
    
    associatedtype StateType: ReduxState
    
    var state: StateType { get }
    var reducer: ReduxReducer<StateType> { get }
    var parent: DispatcherObject? { get }
    var children: [DispatcherObject] { get }
    var middlewares: [MiddlewareListenerObject] { get }
    var coordinator: CoordinatorListenerObject? { get }
    
}

open class ReduxStore<StateType: ReduxState>: StoreProtocol {
    
    private(set) public weak var parent: DispatcherObject?
    @Published public var state: StateType
    private(set) public var reducer: ReduxReducer<StateType>
    private(set) public var children: [DispatcherObject] = []
    private(set) public var middlewares: [MiddlewareListenerObject] = []
    private(set) public var coordinator: CoordinatorListenerObject?
    private let queue: DispatchQueue = DispatchQueue(label: "io.reduxstore.queue",
                                                     qos: .userInteractive,
                                                     attributes: .concurrent,
                                                     autoreleaseFrequency: .inherit,
                                                     target: .main)
    
    public init(parent: DispatcherObject? = nil,
                state: StateType,
                reducer: ReduxReducer<StateType>,
                middlewares: [MiddlewareListenerObject] = [],
                coordinator: CoordinatorListenerObject? = nil) {
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
        self.assignStoreToMiddlewares()
        self.coordinator = coordinator
        self.assignStoreToCoordinator()
        self.parent = parent
    }
    
    // MARK: - Functions:
    
    public func dispatch(_ action: ReduxAction) {
        self.queue.async {
            /// 1 Dispatch flow action
            if (action is FlowAction || action is CoordinatorAction),
               let coordinator = self.coordinator,
               coordinator.handleDispatch(action: action,
                                          store: self,
                                          parent: self.parent) {
                return
            }
            DispatchQueue.main.async {
                /// 2 Dispatch action on store
                self.state = self.reducer.reduce(state: self.state,
                                                 action: action)
                if action.wait {
                    self.queue.resume()
                }
            }
            /// 3 Dispatch middleware actions
            self.middlewares.forEach {
                $0.handleDispatch(action: action,
                                  store: self,
                                  parent: self.parent)
            }
            /// 4 Dispatch action on every child
            self.children.forEach {
                $0.dispatch(action)
            }
        }
        if action.wait {
            self.queue.suspend()
        }
    }
    
    public func addChild(store: DispatcherObject) {
        guard let index = children.firstIndex(where: {
            (type(of: $0) == type(of: store))
        }) else {
            children.append(store)
            return
        }
        children[index] = store
    }
    
    public func addParent(store: DispatcherObject?) {
        self.parent = store
    }
    
    public func getStore<T: ReduxState>(ofType type: T.Type) -> ReduxStore<T>? {
        return children.compactMap { $0 as? ReduxStore<T> }.first
    }
    
    public func addMiddleware(middleware: MiddlewareListenerObject) {
        self.middlewares.append(middleware)
        self.assignStoreToMiddlewares()
    }
    
    private func assignStoreToMiddlewares() {
        self.middlewares.enumerated().forEach { self.middlewares[$0.offset].dispatcher = self }
    }
    
    private func assignStoreToCoordinator() {
        self.coordinator?.dispatcher = self.coordinator?.dispatcher ?? self
    }
    
    public func addCoordinator(coordinator: CoordinatorListenerObject?) {
        self.coordinator = coordinator
        self.assignStoreToCoordinator()
    }
    
}

