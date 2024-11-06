//
//  ImageLoader.swift
//  RecipeApp
//
//  Created by Megha on 11/4/24.
//

import Combine
import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    private let cache: ImageCache
    
    init(cache: ImageCache) {
        self.cache = cache
    }
    
    func loadImage(from url: String) {
        // Check if the image is already cached
        if let cachedImage = cache.getImage(forKey: url) {
            image = cachedImage
            return
        }
        
        // If not cached, fetch from the network
        guard let imageUrl = URL(string: url) else { return }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: imageUrl)
            .map(\.data)
            .tryMap { data -> UIImage? in
                return UIImage(data: data)
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] image in
                if let image = image {
                    self?.cache.cacheImage(image, forKey: url)
                }
            })
            .replaceError(with: nil)
            .assign(to: \.image, on: self)
    }
}
