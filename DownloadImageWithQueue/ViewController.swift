//
//  ViewController.swift
//  DownloadImageWithQueue
//
//  Created by Fernanda Hernandez on 04/10/21.
//

import UIKit
struct ImageMetadata: Codable {
    let name: String
    let firstAppearance: String
    let year: Int
}

struct DetailedImage {
    let image: UIImage
    let metadata: ImageMetadata
}

enum ImageDownloadError: Error {
    case badImage
    case invalidMetadata
}

struct Character {
    let id: Int
    let metadata: ImageMetadata
    let image: UIImage

}

// MARK: - Functions

func downloadImageAndMetadata(
    imageNumber: Int,
    completionHandler: @escaping (_ image: DetailedImage?, _ error: Error?) -> Void
) {
    let imageUrl = URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(imageNumber).png")!
    
    
    DispatchQueue.global(qos: .background).async {
        let imageTask = URLSession.shared.downloadTask(with: imageUrl) { data, response, error in
            guard let data = try? Data(contentsOf: data!), let image = UIImage(data: data), (response as? HTTPURLResponse)?.statusCode == 200 else {
                completionHandler(nil, ImageDownloadError.badImage)
                return
            }
            let metadataUrl = URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(imageNumber).json")!
            let metadataTask = URLSession.shared.dataTask(with: metadataUrl) { data, response, error in
                guard let data = data, let metadata = try? JSONDecoder().decode(ImageMetadata.self, from: data),  (response as? HTTPURLResponse)?.statusCode == 200 else {
                    completionHandler(nil, ImageDownloadError.invalidMetadata)
                    return
                }
                let detailedImage = DetailedImage(image: image, metadata: metadata)
                completionHandler(detailedImage, nil)
            }
            metadataTask.resume()
        }
            imageTask.resume()
        
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var metadata: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImageAndMetadata(imageNumber: 1) { imageDetail, error in
                    DispatchQueue.main.async {
                        if let imageDetail = imageDetail {
                            self.imageView.image = imageDetail.image
                            self.metadata.text =  "\(imageDetail.metadata.name) (\(imageDetail.metadata.firstAppearance) - \(imageDetail.metadata.year))"
                        }
                    }
            }
        // Do any additional setup after loading the view.
    }


}

