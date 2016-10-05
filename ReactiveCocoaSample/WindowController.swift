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
    let tracks = MutableProperty([
        Track(title: "Hello, World", albumTitle: "Something", artist: "Foo McBar", trackIndex: 4, favorite: false),
        Track(title: "Something Something Fun", albumTitle: "Something", artist: "Foo McBar", trackIndex: 3, favorite: false),
        ])

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let splitController = segue.destinationController as? SplitViewController else { fatalError("Unexpected segue") }

        splitController.tracks = tracks
    }
}
