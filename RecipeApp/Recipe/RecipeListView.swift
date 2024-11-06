//
//  RecipeListView.swift
//  RecipeApp
//
//  Created by Megha on 10/16/24.
//
import SwiftUI

struct RecipeListView: View {
    @StateObject private var viewModel = RecipeViewModel(recipeService: RecipeService())
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    // Show a loading indicator while fetching data
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = viewModel.errorMessage {
                    // Display the error message if fetching fails
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    // Display the list of recipes when data is loaded
                    List(viewModel.recipes) { recipe in
                        RecipeRowView(recipe: recipe)
                    }
                    // Pull-to-refresh to reload recipes (only if not loading)
                    .refreshable {
                        await fetchRecipes()
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                // Refresh button to manually reload recipes
                Button(action: {
                    Task {
                        await fetchRecipes()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            Task {
                await fetchRecipes()
            }
        }
    }
    
    // Function to fetch recipes only if not already loading
    private func fetchRecipes() async {
        guard !viewModel.isLoading else { return } // Prevent initiating fetch if already loading
        await viewModel.fetchRecipes()  // Call the fetch method in viewModel
    }
}

struct RecipeRowView: View {
    let recipe: Recipe
    @StateObject private var loader: ImageLoader
    
    // Initialize ImageLoader only once for the recipe
    init(recipe: Recipe) {
        self.recipe = recipe
        _loader = StateObject(wrappedValue: ImageLoader(cache: ImageCache()))
    }
    
    var body: some View {
        HStack {
            loadImage()
            
            // Recipe details: Name and Cuisine
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func loadImage() -> some View {
        if let photoUrl = recipe.photoUrlSmall, !photoUrl.isEmpty {
            return AnyView(
                AsyncImageView(loader: loader)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .onAppear {
                        loader.loadImage(from: photoUrl)
                    }
            )
        } else {
            return AnyView(
                Image(systemName: "appetizer")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            )
        }
    }
}
