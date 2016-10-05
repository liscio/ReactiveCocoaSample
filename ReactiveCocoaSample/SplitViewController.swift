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
    var tracks = MutableProperty<MutableProperty<[Track]>?>(nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        masterViewController.tracks <~ tracks

        self.detailViewController.viewModel <~ masterViewController.selectedTrack.signal.map { (track: Track?) -> TrackDetailViewModel? in
            return (track != nil) ? TrackDetailViewModel(track: track!) : nil
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
