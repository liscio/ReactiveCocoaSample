//
//  SplitViewController.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Cocoa
import ReactiveSwift

final class SplitViewController: NSSplitViewController {
    var dataSource = MutableProperty<TrackDataSource?>(nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        masterViewController.dataSource <~ dataSource

        detailViewController.viewModel <~ dataSource
            .flatMap(.latest) { (dataSource: TrackDataSource?) -> Property<TrackSelection?> in
                dataSource != nil ?
                    Property(value: TrackSelection(selection: dataSource!.selection))
                    : Property(value: nil)
            }
    }

    var masterViewController: MasterViewController {
        guard let master = childViewControllers[0] as? MasterViewController else {
            fatalError("Could not get master view controller")
        }

        return master
    }

    var detailViewController: DetailViewController {
        guard let detail = childViewControllers[1] as? DetailViewController else {
            fatalError("Could not get detail view controller")
        }

        return detail
    }
}
