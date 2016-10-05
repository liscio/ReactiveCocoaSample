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

    var selectedTrack: Property<Track?>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tracksProperty = tracks.flatMap(.latest) { (prop: MutableProperty<[Track]>?) -> Property<[Track]> in
            return prop == nil ? Property(value: []) : Property(prop!)
        }

        delegate = MasterTableViewDelegate(viewController: self, tracks: tracksProperty)
        dataSource = MasterTableViewDataSource(tableView: tableView, tracks: tracksProperty)

        tableView.delegate = delegate
        tableView.dataSource = dataSource

        selectedTrack = delegate.selectedTrackIndex.combineLatest(with: tracksProperty).map { $0 >= 0 ? $1[$0] : nil }

        tracksProperty.signal
            .observe(on: UIScheduler())
            .observeValues { tracks in
                self.tableView.reloadData()
            }
    }
}

final class MasterTableViewDataSource: NSObject, NSTableViewDataSource {
    let tracks: MutableProperty<[Track]>
    let tableView: NSTableView

    init(tableView: NSTableView, tracks: Property<[Track]>) {
        self.tableView = tableView
        self.tracks = MutableProperty([])

        self.tracks <~ tracks

        super.init()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return tracks.value.count
    }
}

final class MasterTableViewDelegate: NSObject, NSTableViewDelegate {
    let tracks: MutableProperty<[Track]>

    private let _selectedTrackIndex: MutableProperty<Int>
    let selectedTrackIndex: Property<Int>

    weak var tableViewController: MasterViewController?

    init(viewController: MasterViewController, tracks: Property<[Track]>) {
        self.tableViewController = viewController
        self.tracks = MutableProperty([])

        self._selectedTrackIndex = MutableProperty(-1)
        self.selectedTrackIndex = Property(_selectedTrackIndex)

        self._selectedTrackIndex <~ NotificationCenter.default.rac_notifications(forName: Notification.Name.NSTableViewSelectionDidChange, object: viewController.tableView).map { ($0.object as? NSTableView)?.selectedRow ?? NSNotFound }

        self.tracks <~ tracks

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
