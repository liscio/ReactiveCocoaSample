//
//  ReactiveCocoaSampleTests.swift
//  ReactiveCocoaSampleTests
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import XCTest
@testable import ReactiveCocoaSample

class TrackDetailViewModelTests: XCTestCase {
    func testCommitEditing() {
        let track = Track(title: "Some track", albumTitle: "Some album", artist: "Some artist", trackIndex: 4, favorite: false)
        let viewModel = TrackDetailViewModel(track: track)

        // Simulate settng the track's title
        viewModel.title.value = "Foobar"

        // Assert that the viewModel did not yet commit the user's editing
        XCTAssertEqual(viewModel.editedTrack.value.title, "Some track")

        viewModel.commitEditing()

        // Assert that the viewModel now contains the user's edited results
        XCTAssertEqual(viewModel.editedTrack.value.title, "Foobar")
    }

    func testRevertEditing() {
        let track = Track(title: "Some track", albumTitle: "Some album", artist: "Some artist", trackIndex: 4, favorite: false)
        let viewModel = TrackDetailViewModel(track: track)

        // Simulate settng the track's title
        viewModel.title.value = "Foobar"

        // Assert that the viewModel accepted the value, but did not yet commit the user's editing
        XCTAssertEqual(viewModel.title.value, "Foobar")
        XCTAssertEqual(viewModel.editedTrack.value.title, "Some track")

        viewModel.revert()

        // Assert that the viewModel's exposed properties have been updated with the reverted values
        XCTAssertEqual(viewModel.editedTrack.value.title, "Some track")
        XCTAssertEqual(viewModel.title.value, "Some track")
    }
}

class ReactiveCocoaSampleTests: XCTestCase {

}
