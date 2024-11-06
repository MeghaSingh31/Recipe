//
//  RecipeAppTests.swift
//  RecipeAppTests
//
//  Created by Megha on 10/16/24.
//

import XCTest
import Combine
@testable import RecipeApp

class MockRecipeService: RecipeServiceProtocol {
    var shouldReturnError = false
    var shouldThrowEmptyListError = false
    var recipesToReturn: [Recipe] = []
    var errorToThrow: Error?

    func fetchRecipes() async throws -> [Recipe] {
        
        if shouldThrowEmptyListError {
            // Simulate an empty list scenario by throwing the error
            throw RecipeError.emptyList
        }
        
        if shouldReturnError {
            if let error = errorToThrow {
                throw error
            }
            throw RecipeError.badURL // Default error if none specified
        }
        return recipesToReturn
    }
}

class RecipeViewModelTests: XCTestCase {
    var viewModel: RecipeViewModel!
    var mockService: MockRecipeService!

    override func setUp() {
        super.setUp()
        mockService = MockRecipeService()
        viewModel = RecipeViewModel(recipeService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testFetchRecipesSuccess() async {
        // Given
        let expectedRecipes = [
            Recipe(cuisine: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                   name: "Apam Balik",
                   photoUrlLarge: "Malaysian",
                   photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                   sourceUrl: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                   uuid: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                   youtubeUrl: "https://www.youtube.com/watch?v=6R8ffRRJcrg")
        ]
        mockService.recipesToReturn = expectedRecipes

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.recipes.count, expectedRecipes.count)
        XCTAssertEqual(viewModel.recipes[0].name, expectedRecipes[0].name)
    }

    func testFetchRecipesEmptyList() async {
        // Given
        mockService.shouldThrowEmptyListError = true
        mockService.recipesToReturn = []

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, RecipeError.emptyList.localizedDescription)
        XCTAssertTrue(viewModel.recipes.isEmpty)
    }

    func testFetchRecipesBadURL() async {
        // Given
        mockService.shouldReturnError = true
        mockService.errorToThrow = RecipeError.badURL

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, RecipeError.badURL.localizedDescription)
        XCTAssertTrue(viewModel.recipes.isEmpty)
    }

    func testFetchRecipesNetworkError() async {
        // Given
        mockService.shouldReturnError = true
        mockService.errorToThrow = URLError(.notConnectedToInternet)

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, RecipeError.badURL.localizedDescription)
        XCTAssertTrue(viewModel.recipes.isEmpty)
    }

    func testFetchRecipesUnexpectedError() async {
        // Given
        mockService.shouldReturnError = true
        mockService.errorToThrow = NSError(domain: "Unexpected", code: -1, userInfo: nil)

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "An unexpected error occurred.")
        XCTAssertTrue(viewModel.recipes.isEmpty)
    }
}
