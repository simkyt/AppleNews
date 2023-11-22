//
//  ArticleDetails.swift
//  AppleNews
//
//  Created by arturs.olekss on 17/11/2023.
//

import UIKit
import SDWebImage

class ArticleDetailsController: UIViewController, ArticleDetailsViewDelegate {
    var article: Article?
    private let articleDetailsView = ArticleDetailsView()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        articleDetailsView.delegate = self
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        
        title = "Article"
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(articleDetailsView)
        
        articleDetailsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            articleDetailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            articleDetailsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            articleDetailsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            articleDetailsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        if let urlString = article?.urlToImage, let url = URL(string: urlString) {
            loadImage(from: url)
        }
    }
    
    func loadImage(from url: URL) {
        SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { [weak self] (image, data, error, cacheType, finished, imageURL) in
            DispatchQueue.main.async {
                if let image = image {
                    self?.articleDetailsView.updateImage(image)
                    self?.articleDetailsView.updateUI(withDataFrom: self!.article!)
                } else {
                    self?.articleDetailsView.updateImage(UIImage(named: "notfound.jpg"))
                }
            }
        }
    }
    
    func didTapOpenLinkButton() {
        if let urlString = article?.url, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func formatDate(from isoDateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let date = inputFormatter.date(from: isoDateString) else {
            return "Unknown publishing date"
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "E, MMM d, yyyy 'at' h:mm a 'GMT+2'"
        outputFormatter.timeZone = TimeZone(secondsFromGMT: 7200) // GMT+2

        return outputFormatter.string(from: date)
    }
}
