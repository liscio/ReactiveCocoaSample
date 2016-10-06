//
//  Bindable.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 2016-10-05.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol Bindable {
    associatedtype ViewModel

    var viewModel: MutableProperty<ViewModel?> { get }
}

extension Bindable {
    func bind(to viewModel: ViewModel?) {
        self.viewModel.value = viewModel
    }
}
