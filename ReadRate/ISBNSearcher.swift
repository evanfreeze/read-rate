//
//  ISBNSearcher.swift
//  ReadRate
//
//  Created by Evan Freeze on 1/12/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import Foundation
import SwiftUI

class ISBNSearcher {
    func findBook(for isbn: String, completion: @escaping ([String: ISBNBook]) -> Void) {
        guard let url = URL(string: "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&format=json&jscmd=data") else {
            print("Invalid url")
            return
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let decodedData = try? decoder.decode([String: ISBNBook].self, from: data) {
                    DispatchQueue.main.async {
                        print(decodedData)
                        completion(decodedData)
                    }
                    return
                } else {
                    print("failed to decode data")
                }
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct ISBNBook: Codable {
    let title: String
    let authors: [ISBNAuthor]
    let numberOfPages: Int
    let publishDate: String
    let cover: ISBNCover?
    
    struct ISBNAuthor: Codable {
        let name: String
    }
    
    struct ISBNCover: Codable {
        let small: String
        let medium: String
        let large: String
    }
}

