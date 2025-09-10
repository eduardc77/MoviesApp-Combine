//
//  Genre.swift
//  MoviesModels
//
//  Created by User on 9/10/25.
//

import Foundation

public struct Genre: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
