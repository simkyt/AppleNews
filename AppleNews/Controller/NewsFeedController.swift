//
//  ViewController.swift
//  AppleNews
//
//  Created by arturs.olekss on 17/11/2023.
//

import UIKit
import SDWebImage

class NewsFeedController: UITableViewController {
    
    private var cellID = "cell"
    private var newsItems:[Article] = []
    private var currentApi = NetworkManager.popularApi
    private var sortPickerView: UIPickerView!
    private let sortOptions = ["Newest", "Oldest"]
    private var currentSortOption = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getNewsData(from: currentApi)
    }
    
    private func setupView(){
        title = "News"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self,forCellReuseIdentifier: cellID)
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        sortPickerView = UIPickerView()
        sortPickerView.delegate = self
        sortPickerView.dataSource = self
        
        let sortButton = UIBarButtonItem(title: "Sort By", style: .plain, target: self, action: #selector(showSortOptions))
        navigationItem.rightBarButtonItem = sortButton
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor:UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func getNewsData(from url: String){
        NetworkManager.fetchData(url: url){
            newsItems in
            self.newsItems = newsItems.articles ?? []
            DispatchQueue.main.async{
                self.handleSortSelection(at: self.currentSortOption)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func refreshNewsData(_ sender: UIRefreshControl) {
        getNewsData(from: currentApi)
        sender.endRefreshing()
    }
    
    @objc private func showSortOptions() {
        let alertController = UIAlertController(title: "Sort news articles by", message: nil, preferredStyle: .actionSheet)

        for (index, option) in sortOptions.enumerated() {
            alertController.addAction(UIAlertAction(title: option, style: .default, handler: { [weak self] _ in
                self?.handleSortSelection(at: index)
            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func handleSortSelection(at index: Int) {
        self.currentSortOption = index
        let dateFormatter = ISO8601DateFormatter()

        newsItems.sort(by: { firstArticle, secondArticle in
            let firstDate = firstArticle.publishedAt != nil ? dateFormatter.date(from: firstArticle.publishedAt!) : nil
            let secondDate = secondArticle.publishedAt != nil ? dateFormatter.date(from: secondArticle.publishedAt!) : nil

            switch index {
            case 0:
                if let firstDate = firstDate, let secondDate = secondDate {
                    return firstDate > secondDate
                }
                return firstDate != nil
            case 1:
                if let firstDate = firstDate, let secondDate = secondDate {
                    return firstDate < secondDate
                }
                return secondDate == nil
            default:
                return false
            }
        })

        tableView.reloadData()
    }
}

extension NewsFeedController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOptions[row]
    }
}

extension NewsFeedController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath)
        cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellID)
        
        let article = self.newsItems[indexPath.row]
        
        let titleLabel = UILabel()
        titleLabel.text = article.title ?? ""
        
        let widthTitleConstr = NSLayoutConstraint(item: titleLabel,
                                                  attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 220)
        
        titleLabel.addConstraint(widthTitleConstr)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        let imageView = UIImageView()
        imageView.sd_setImage(with: URL(string:article.urlToImage ?? ""))
        
        let widthImageConstr = NSLayoutConstraint(item: imageView,
                                                  attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 135)
        
        let heightImageConstr = NSLayoutConstraint(item: imageView,
                                                   attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 90)
        
        imageView.addConstraints([widthImageConstr,heightImageConstr])
        
        let stackView = UIStackView(arrangedSubviews: [imageView,titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        cell.addSubview(stackView)
        
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5)
        ])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle = newsItems[indexPath.row]
        
        let articleDetailsViewController = ArticleDetailsController()
        articleDetailsViewController.article = selectedArticle
        navigationController?.pushViewController(articleDetailsViewController, animated: true)
    }
}

