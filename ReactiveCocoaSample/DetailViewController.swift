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

final class DetailViewController: NSViewController, Bindable {
    @IBOutlet var titleTextField: NSTextField!
    @IBOutlet var albumTitleTextField: NSTextField!
    @IBOutlet var artistTextField: NSTextField!
    @IBOutlet var favoriteCheckbox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.rac.text <~ viewModel.flatMap(.latest) { $0?.title ?? MutableProperty("") }
        albumTitleTextField.rac.text <~ viewModel.flatMap(.latest) { $0?.albumTitle ?? MutableProperty("") }
        artistTextField.rac.text <~ viewModel.flatMap(.latest) { $0?.artist ?? MutableProperty("") }

        viewModel.signal.observeValues { [unowned self] in
            guard let viewModel = $0 else { return }

            viewModel.title <~ self.titleTextField.rac.text
            viewModel.albumTitle <~ self.albumTitleTextField.rac.text
            viewModel.artist <~ self.artistTextField.rac.text
        }
    }

    let viewModel = MutableProperty<TrackDetailViewModel?>(nil)

    @IBAction func apply(_ sender: NSButton?) {
        viewModel.value?.commitEditing()
    }

    @IBAction func revert(_ sender: NSButton?) {
        viewModel.value?.revert()
    }
}
