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

        titleTextField.rac.value <~ viewModel.flatMap(.latest) { $0.title }
        albumTitleTextField.rac.value <~ viewModel.flatMap(.latest) { $0.albumTitle }
        artistTextField.rac.value <~ viewModel.flatMap(.latest) { $0.artist }

        viewModel.signal.observeValues { [unowned self] in
            guard let viewModel = $0 else { return }

            viewModel.title <~ self.titleTextField.rac.stringValues
            viewModel.albumTitle <~ self.albumTitleTextField.rac.stringValues
            viewModel.artist <~ self.artistTextField.rac.stringValues
        }
    }

    let viewModel = MutableProperty<TrackSelection?>(nil)

    @IBAction func apply(_ sender: NSButton?) {
//        viewModel.value?.commitEditing()
    }

    @IBAction func revert(_ sender: NSButton?) {
//        viewModel.value?.revert()
    }
}
