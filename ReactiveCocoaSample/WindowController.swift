//
//  WindowController.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Cocoa
import ReactiveSwift

final class WindowController: NSWindowController {
    let dataSource = TrackDataSource()

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let splitController = self.contentViewController as? SplitViewController else { fatalError("Unexpected view controller") }

        splitController.dataSource.value = dataSource
    }

    @IBAction func newDocument(_ sender: AnyObject?) {
        dataSource.insertNewTrack()
    }
}
