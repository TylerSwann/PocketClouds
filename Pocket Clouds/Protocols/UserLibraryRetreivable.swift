//
//  UserLibraryRetreivable.swift
//  ServerPieces
//
//  Created by Tyler on 16/04/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import Photos


extension UserLibraryRetreivable
{
    func getViewableUserMediaAssets() -> [PHAsset]
    {
        let imageAssets = self.retreiveAssets(ofType: .image)
        var videoAssets = self.retreiveAssets(ofType: .video)
        videoAssets += imageAssets
        return videoAssets
    }

    func retreiveAssets(ofType assetMediaType: PHAssetMediaType) -> [PHAsset]
    {
        var assets = [PHAsset]()
        let fetchResults = PHAsset.fetchAssets(with: assetMediaType, options: nil)
        if (fetchResults.count > 0)
        {
            for i in 0..<fetchResults.count
            {
                assets.append(fetchResults.object(at: i))
            }
        }
        return assets
    }
    
    
    func retreiveThumbnailFor(assets: [PHAsset], size imageSize: CGSize) -> [UIImage]
    {
        var images = [UIImage]()
        for asset in assets
        {
            let image = self.retreiveThumbnailFor(asset: asset, size: imageSize)
            images.append(image)
        }
        return images
    }
    
    func retreiveThumbnailFor(asset: PHAsset, size imageSize: CGSize) -> UIImage
    {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = false
        options.isSynchronous = true
        options.deliveryMode = .fastFormat
        return self.retreiveImageFor(asset: asset, size: imageSize, options: options)
    }
    func retreiveImageFor(assets: [PHAsset], size imageSize: CGSize, options: PHImageRequestOptions) -> [UIImage]
    {
        var images = [UIImage]()
        for asset in assets
        {
            let image = self.retreiveImageFor(asset: asset, size: imageSize, options: options)
            images.append(image)
        }
        return images
    }
    
    func retreiveImageFor(asset: PHAsset, size imageSize: CGSize, options: PHImageRequestOptions) -> UIImage
    {
        var size = ImageSize.largeThumbnail
        var image = UIImage()
        let imageManager = PHImageManager()
        switch (imageSize)
        {
        case ImageSize.original:
            size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        default:
            size = imageSize
        }
        imageManager.requestImage(for: asset, targetSize: size,
                                        contentMode: .aspectFit, options:
                                        options, resultHandler: {(result, _) in
        if let anImage = result {image = anImage}
        })
        return image
    }
}








