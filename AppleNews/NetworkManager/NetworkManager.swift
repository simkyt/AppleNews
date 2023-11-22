//
//  NetworkManager.swift
//  AppleNews
//
//  Created by arturs.olekss on 17/11/2023.
//

import Foundation

class NetworkManager {
    
    static let latestApi = "https://newsapi.org/v2/everything?q=apple&from=2023-11-02&sortBy=publishedAt&language=en&apiKey=56262a4c48db4db0b09cb2bbc4853cf0"
    
    static let popularApi = "https://newsapi.org/v2/everything?q=apple&from=2023-11-02&sortBy=popularity&language=en&apiKey=56262a4c48db4db0b09cb2bbc4853cf0"
    
    static func fetchData(url: String, completion: @escaping (NewsItems) -> () ) {

        guard let url = URL(string: url) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true

        URLSession(configuration: config).dataTask(with: request) { (data, response, err ) in

            guard err == nil else {
                print("err:::::", err!)
                return
            }

            //print("response:", response as Any)

            guard let data = data else { return }


            do {
                let jsonData = try JSONDecoder().decode(NewsItems.self, from: data)
                completion(jsonData)
            }catch{
                print("err:::::", error)
            }

        }.resume()

    }
    
}
