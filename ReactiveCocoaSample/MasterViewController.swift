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

final class MasterViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!

    var dataSource = MutableProperty<TrackDataSource?>(nil)
    var tracks: Property<[Track]>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // This will populate our own "view" of the data source's tracks
        tracks = dataSource.flatMap(.latest) { $0?.tracks ?? Property(value: []) }

        // When the tracks list changes, we want to reload the table view's contents
        tracks.signal
            .observe(on: UIScheduler())
            .observeValues { tracks in
                self.tableView.reloadData()
            }

        let selectedRow = NotificationCenter.default.rac_notifications(forName: Notification.Name.NSTableViewSelectionDidChange, object: tableView).map { ($0.object as? NSTableView)?.selectedRow ?? NSNotFound }

        // As the data source changes, we want to update its selected index when our table view's selected row changes
        dataSource.signal.observeValues { dataSource in
            guard let dataSource = dataSource else { return }
            dataSource.selectedIndex <~ selectedRow
        }

        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return tracks.value.count
    }

    // MARK: NSTableViewDelegate

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let view = tableView.make(withIdentifier: "Track", owner: self) as? TrackTableCellView {
            view.bind(to: TrackTableCellViewModel(track: tracks.value[row]))
            return view
        } else {
            fatalError("Could not construct table cell view.")
        }
    }
}
