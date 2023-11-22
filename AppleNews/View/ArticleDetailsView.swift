//
//  ArticleDetailView.swift
//  AppleNews
//
//  Created by Simonas Kytra on 22/11/2023.
//

import UIKit

protocol ArticleDetailsViewDelegate: AnyObject {
    func didTapOpenLinkButton()
    func formatDate(from isoDateString: String) -> String
}

class ArticleDetailsView: UIView {
    let scrollView = UIScrollView()
    
    let mainStackView = UIStackView()
    
    let imageView = UIImageView()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    let sourceStackView = UIStackView()
    let authorLabel = UILabel()
    let publishedAtLabel = UILabel()
    
    let contentStackView = UIStackView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    
    weak var delegate: ArticleDetailsViewDelegate?
    let openLinkButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .secondarySystemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceStackView.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        publishedAtLabel.translatesAutoresizingMaskIntoConstraints = false
        openLinkButton.translatesAutoresizingMaskIntoConstraints = false
        
        // label setup
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        authorLabel.font = UIFont.boldSystemFont(ofSize: 15)
        publishedAtLabel.font = UIFont.systemFont(ofSize: 12)
        
        // mainStackView setup
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.addArrangedSubview(sourceStackView)
        mainStackView.addArrangedSubview(contentStackView)
        mainStackView.addArrangedSubview(openLinkButton)
        
        // sourceStackView setup
        sourceStackView.axis = .vertical
        sourceStackView.spacing = 2
        sourceStackView.distribution = .fillEqually
        sourceStackView.addArrangedSubview(authorLabel)
        sourceStackView.addArrangedSubview(publishedAtLabel)
        
        // contentStackView setup
        contentStackView.axis = .vertical
        contentStackView.spacing = 30
        contentStackView.distribution = .fillProportionally
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        // button set up
        openLinkButton.setTitle("Open the full article...", for: .normal)
        openLinkButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)
        
        // subviews
        scrollView.addSubview(imageView)
        scrollView.addSubview(mainStackView)
        addSubview(scrollView)
        
        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // imageView constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 225),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // mainStackView constraints
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // to ensure that the mainStackView width matches the scrollView's width
        mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40).isActive = true
        
        activityIndicator.startAnimating()
    }
    
    func updateImage(_ image: UIImage?) {
        activityIndicator.stopAnimating()
        imageView.image = image
    }
    
    func updateUI(withDataFrom: Article) {
        titleLabel.text = withDataFrom.title
        descriptionLabel.text = withDataFrom.description?.replacingOccurrences(of: "[\\n\\r]+", with: "", options: .regularExpression)
        
        authorLabel.text = "by " + (withDataFrom.author ?? "Unknown author") + " at " + (withDataFrom.source?.name ?? "Unknown")
        
        publishedAtLabel.text = delegate?.formatDate(from: withDataFrom.publishedAt ?? "error")
    }
    
    @objc func openLink() {
        delegate?.didTapOpenLinkButton()
    }
}
