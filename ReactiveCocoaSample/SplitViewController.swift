//
//  SplitViewController.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Cocoa
import ReactiveSwift

final class SplitViewController: NSViewController {
    var tracks: MutableProperty<[Track]>!

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let master = segue.destinationController as? MasterViewController {
            master.tracks.value = tracks
        }
        else if let detail = segue.destinationController as? DetailViewController {
        }
        else {
            fatalError("Unknown segue encountered.")
        }
    }
}
