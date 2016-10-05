//
//  MasterViewController.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Cocoa
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

final class MasterViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!

    var dataSource: MasterTableViewDataSource!
    var delegate: MasterTableViewDelegate!

    var tracks = MutableProperty<MutableProperty<[Track]>?>(nil)

    override func viewDidLoad() {

        let propsSignal = tracks.signal
        let tracksSignal: Signal<[Track], NoError> = propsSignal.flatMap(.latest) { (prop: MutableProperty<[Track]>?) -> [Track] in
            return prop?.value ?? []
        }
        let trackProp = Property(initial: [], then: tracksSignal)

        delegate = MasterTableViewDelegate(viewController: self, tracks: trackProp)
        dataSource = MasterTableViewDataSource(tableView: tableView, tracks: Property(tracks.flatMap(.latest) { $0 ?? MutableProperty([]) }))

        tableView.delegate = delegate
        tableView.dataSource = dataSource

        tracks.signal
            .observe(on: UIScheduler())
            .observeValues { _ in
                self.tableView.reloadData()
            }
    }
}

final class MasterTableViewDataSource: NSObject, NSTableViewDataSource {
    let tracks: Property<[Track]>
    let tableView: NSTableView

    init(tableView: NSTableView, tracks: Property<[Track]>) {
        self.tableView = tableView
        self.tracks = tracks

        super.init()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return tracks.value.count
    }
}

final class MasterTableViewDelegate: NSObject, NSTableViewDelegate {
    let tracks: Property<[Track]>
    weak var tableViewController: MasterViewController?

    init(viewController: MasterViewController, tracks: Property<[Track]>) {
        self.tableViewController = viewController
        self.tracks = tracks

        super.init()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let view = tableView.make(withIdentifier: "Track", owner: tableViewController) as? TrackTableCellView {
            view.bind(to: TrackTableCellViewModel(track: tracks.value[row]))
            return view
        } else {
            fatalError("Could not construct table cell view.")
        }
    }
}
