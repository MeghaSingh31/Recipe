//
//  AsyncImageView.swift
//  RecipeApp
//
//  Created by Megha on 11/4/24.
//

import SwiftUI

struct AsyncImageView: View {
    @ObservedObject var loader: ImageLoader
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView() // Placeholder while loading
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 60, height: 60)
            }
        }
    }
}

