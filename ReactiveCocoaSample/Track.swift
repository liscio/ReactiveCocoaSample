//
//  Track.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation

public struct Track {
    public var title: String
    public var albumTitle: String
    public var artist: String
    public var trackIndex: Int
    public var favorite: Bool
}

extension Track: Equatable {
    public static func ==(lhs: Track, rhs: Track) -> Bool {
        return lhs.title == rhs.title &&
            lhs.albumTitle == rhs.albumTitle &&
            lhs.artist == rhs.artist &&
            lhs.trackIndex == rhs.trackIndex &&
            lhs.favorite == rhs.favorite
    }
}

extension Track: Hashable {
    public var hashValue: Int {
        return title.hashValue ^ albumTitle.hashValue ^ artist.hashValue ^ trackIndex.hashValue ^ favorite.hashValue
    }
}

