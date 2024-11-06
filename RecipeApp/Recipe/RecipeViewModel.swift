import SwiftUI
import Combine

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let recipeService: RecipeServiceProtocol

    init(recipeService: RecipeServiceProtocol = RecipeService()) {
        self.recipeService = recipeService
    }
    
    func fetchRecipes() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let fetchedRecipes = try await recipeService.fetchRecipes()
            // Update the UI on the main thread
            await MainActor.run {
                self.recipes = fetchedRecipes
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                // Handle the errors based on their type
                if let recipeError = error as? RecipeError {
                    self.errorMessage = recipeError.localizedDescription
                } else if error is URLError {
                    self.errorMessage = RecipeError.badURL.localizedDescription
                } else {
                    self.errorMessage = "An unexpected error occurred."
                }
                self.isLoading = false
            }
        }
    }
}

