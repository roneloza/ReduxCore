//
//  ReduxStoreView.swift
//  ExchangeCurrency
//
//  Created by Rone Shender on 26/10/21.
//

import SwiftUI

public protocol ReduxStoreView: View {
    
    associatedtype ViewState: ReduxState
    
    var store: ReduxStore<ViewState> { get }
    
}
