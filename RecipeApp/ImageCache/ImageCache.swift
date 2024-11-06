//
//  ImageCache.swift
//  RecipeApp
//
//  Created by Megha on 10/16/24.
//

import Foundation
import SwiftUI
import UIKit

class ImageCache {
    
    // The cache directory URL where images will be stored
    private let cacheDirectory: URL
    
    init() {
        // Initialize file manager and get the cache directory URL
        let fileManager = FileManager.default
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("ImageCache")
        
        // Ensure the cache directory exists; if not, create it
        createCacheDirectoryIfNeeded(fileManager: fileManager)
    }
    
    // MARK: - Caching Image
    
    /// Saves an image to the cache directory with a specified key.
    func cacheImage(_ image: UIImage, forKey key: String) {
        // Ensure the image can be converted to PNG data
        guard let data = image.pngData() else {
            print("Error: Unable to convert image to PNG data.")
            return
        }
        
        // Sanitize the key to make it a valid file name
        let sanitizedKey = sanitizeFileName(from: key)
        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey)
        
        // Write the data to the cache file
        do {
            try data.write(to: fileURL)
            print("Image cached at path: \(fileURL.path)")
        } catch {
            print("Error saving image to cache: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Retrieving Image
    
    /// Fetches an image from the cache for the given key.
    func getImage(forKey key: String) -> UIImage? {
        // Sanitize the key to make it a valid file name
        let sanitizedKey = sanitizeFileName(from: key)
        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey)
        
        // Check if the file exists in the cache directory
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found at path: \(fileURL.path)")
            return nil
        }
        
        // Try to load the image data from the file
        do {
            let data = try Data(contentsOf: fileURL)
            if let image = UIImage(data: data) {
                return image
            } else {
                print("Error: Failed to create UIImage from data.")
                return nil
            }
        } catch {
            print("Error loading image data: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Sanitizes the URL string to create a valid file name.
    private func sanitizeFileName(from url: String) -> String {
        // URL encoding to ensure all characters are valid in file names
        return url
            .replacingOccurrences(of: "https://", with: "")  // Optionally remove the "https://"
            .replacingOccurrences(of: "/", with: "_")        // Replace slashes with underscores
            .replacingOccurrences(of: ":", with: "_")        // Replace colons with underscores
            .replacingOccurrences(of: ".", with: "_")        // Optionally replace periods as well
    }
    
    /// Creates the cache directory if it doesn't already exist.
    private func createCacheDirectoryIfNeeded(fileManager: FileManager) {
        // Create the directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Cache directory created at: \(cacheDirectory.path)")
            } catch {
                print("Error creating cache directory: \(error.localizedDescription)")
            }
        }
    }
}
