//
//  RecipeService.swift
//  RecipeApp
//
//  Created by Megha on 10/16/24.
//

import Foundation

protocol RecipeServiceProtocol {
    func fetchRecipes() async throws -> [Recipe]
}

class RecipeService: RecipeServiceProtocol {
    private let urlString =  "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    
    func fetchRecipes() async throws -> [Recipe] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
        
        if response.recipes.isEmpty {
            throw RecipeError.emptyList
        }
        
        return response.recipes
    }
}

enum RecipeError: Error {
    case emptyList
    case badURL
    var localizedDescription: String {
        switch self {
        case .emptyList:
            return "No recipes available"
        case .badURL:
            return "The URL is malformed."
        }
        
    }
}
