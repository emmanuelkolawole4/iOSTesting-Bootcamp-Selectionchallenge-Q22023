//
//  ViewController.swift
//  miniBootcampChallenge
//

/*
 To download all the images first before displaying them:
 - uncomment line 40 and 41
 - comment out line 68 and uncomment line 69
 - comment out lines 79 to 99
 - uncomment line 102
 */

import UIKit

class ViewController: UICollectionViewController {
    
    var allDownloadedImages: [UIImage] = []
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    private lazy var urls: [URL] = URLProvider.urls
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
//        ImageManager.shared.delegate = self
//        ImageManager.shared.downloadImages(from: urls)
        view.addSubview(spinner)
        collectionView.isHidden = true
        collectionView.alpha = 0
        addConstraints()
        spinner.startAnimating()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}

// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way

// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.


// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
//        allDownloadedImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        let url = urls[indexPath.row]
        cell.imageView.image = nil // Clear the image view while the new image is being downloaded
        
        
        ImageManager.shared.downloadImage(from: url) { [weak self] image, error in
            if let error = error {
                print("Failed to download image: \(error.localizedDescription)")
                return
            }

            self?.spinner.stopAnimating()
            collectionView.isHidden = false
            collectionView.reloadData()

            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.collectionView.alpha = 1
            }

            // Make sure the cell is still displaying the same image URL as when the download started
            guard cell.reuseIdentifier == Constants.cellID, url == self?.urls[indexPath.row] else {
                return
            }

            cell.display(image)
        }
        
//        cell.display(allDownloadedImages[indexPath.item])
                
        return cell
    }
}


// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
          let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
}


extension ViewController: ImageManagerDelegate {
    
    func didFinishDownloadingAllImages(images: [UIImage]) {
        self.allDownloadedImages = images
        spinner.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData()

        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.collectionView.alpha = 1
        }
    }
    
}
