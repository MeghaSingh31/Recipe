//
//  Recipe.swift
//  RecipeApp
//
//  Created by Megha on 10/16/24.
//

import Foundation

struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

// MARK: - Recipe
struct Recipe: Identifiable, Codable, Equatable {
    let cuisine: String
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let sourceUrl: String?
    let uuid: String
    let youtubeUrl: String?
    
    var id: String {
        return uuid
    }
    
    // CodingKeys to map JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case cuisine
        case name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case uuid
        case youtubeUrl = "youtube_url"
    }
}
