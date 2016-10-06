//
//  TrackTableCellView.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Cocoa
import ReactiveSwift
import ReactiveCocoa

final class TrackTableCellView: NSTableCellView, Bindable {
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var artistLabel: NSTextField!
    @IBOutlet var trackIndexLabel: NSTextField!

    let viewModel = MutableProperty<TrackTableCellViewModel?>(nil)

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.rac.stringValue <~ viewModel.flatMap(.latest) { $0?.title ?? Property(value: "") }
        artistLabel.rac.stringValue <~ viewModel.flatMap(.latest) { $0?.artist ?? Property(value: "") }
        trackIndexLabel.rac.stringValue <~ viewModel.flatMap(.latest) { $0?.trackIndex.map { String(describing: $0) } ?? Property(value: "") }
    }
}
