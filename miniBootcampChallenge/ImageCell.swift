//
//  ImageCell.swift
//  miniBootcampChallenge
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func display(_ image: UIImage?) {
        imageView.image = image
    }
}

protocol ImageManagerDelegate: AnyObject {
    func didFinishDownloadingAllImages(images: [UIImage])
}

final class ImageManager {
    
    static let shared = ImageManager()
    private var imageCache = NSCache<NSString, UIImage >()
    
    weak var delegate: ImageManagerDelegate?
    
    private init() {}
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        let key = url.absoluteString as NSString
        if let image = imageCache.object(forKey: key) {
            completion(image, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                let error = NSError(domain: "com.yourdomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse image data"])
                completion(nil, error)
                return
            }
            
            self?.imageCache.setObject(image, forKey: key)
            
            DispatchQueue.main.async {
                completion(image, nil)
            }
        }.resume()
    }
    
    func downloadImages(from urls: [URL]) {
        var downloadedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for url in urls {
            dispatchGroup.enter()
            ImageManager.shared.downloadImage(from: url) { image, error in
                if let error = error {
                    print("Failed to download image: \(error.localizedDescription)")
                } else if let image = image {
                    downloadedImages.append(image)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.delegate?.didFinishDownloadingAllImages(images: downloadedImages)
        }
    }

}
