//
//  DetailViewController.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Cocoa
import Result
import ReactiveSwift
import ReactiveCocoa

final class DetailViewController: NSViewController {
    @IBOutlet var titleTextField: NSTextField!
    @IBOutlet var albumTitleTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.rac.text <~ self.viewModel.flatMap(.latest) { $0 != nil ? Property($0!.title) : Property(value: "") }

        albumTitleTextField.rac.text <~ self.viewModel.flatMap(.latest) { $0 != nil ? Property($0!.albumTitle) : Property(value: "") }
    }

    let viewModel = MutableProperty<TrackDetailViewModel?>(nil)
}
