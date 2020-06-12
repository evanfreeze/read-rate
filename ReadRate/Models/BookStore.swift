//
//  BookStore.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import Foundation
import Combine

let bookOne = Book(
    title: "The Fault in Our Stars",
    author: "John Green",
    pageCount: 320,
    currentPage: 23,
    startDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * -4)),
    targetDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * 10)),
    todaysTarget: 43,
    todaysTargetLastUpdated: Date().advanced(by: TimeInterval(60.0 * 60.0 * -2))
)

let bookTwo = Book(
    title: "Deep Work",
    author: "Cal Newport",
    pageCount: 300,
    currentPage: 243,
    startDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * -1)),
    targetDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * 5)),
    todaysTarget: 250,
    todaysTargetLastUpdated: Date().advanced(by: TimeInterval(60.0 * 60.0 * -3))
)

let bookThree = Book(
    title: "So You Want to Talk About Race",
    author: "Ijeoma Oluo",
    pageCount: 238,
    currentPage: 70,
    startDate: Date(),
    targetDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * 24)),
    todaysTarget: 83,
    todaysTargetLastUpdated: Date().advanced(by: TimeInterval(60.0 * 60.0 * -8))
)

func getMockBooks() -> BookStore {
    let mockBookStore = BookStore()
    
    [bookOne, bookTwo, bookThree].forEach { book in
        mockBookStore.books.append(book)
    }
    
    return mockBookStore
}

class BookStore: ObservableObject {
    let bookStoreURL = URL(
        fileURLWithPath: "BookStore",
        relativeTo: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    ).appendingPathExtension("json")
    
    @Published var books: [Book] = [] {
        didSet {
            saveBookStoreJSON()
        }
    }
    
    init() {
        print(bookStoreURL)
        loadBookStoreJSON()
        migrateBooks()
    }
    
    private func loadBookStoreJSON() {
        guard FileManager.default.fileExists(atPath: bookStoreURL.path) else {
            return
        }
        
        do {
            let bookStoreData = try Data(contentsOf: bookStoreURL)
            books = try JSONDecoder().decode([Book].self, from: bookStoreData)
            print(books)
        } catch let error {
            print(error)
        }
    }
    
    private func saveBookStoreJSON() {
        do {
            let bookStoreJSON = try JSONEncoder().encode(books)
            try bookStoreJSON.write(to: bookStoreURL, options: .atomicWrite)
        } catch let error {
            print(error)
        }
    }
    
    public func setTodaysTargets() {
        print("setting today's target pages")
        
        guard books.count > 0 else {
            return
        }
        
        for (index, book) in books.enumerated() {
            if !Calendar.current.isDateInToday(book.todaysTargetLastUpdated) {
                books[index].todaysTarget = Int(book.nextStoppingPage)!
                books[index].todaysTargetLastUpdated = Date()
            }
        }
    }
    
    private func migrateBooks() {
//        for (index, _) in books.enumerated() {
//            books[index].todaysTargetLastUpdated = Date().addingTimeInterval(TimeInterval(-60 * 60 * 24))
//        }
    }
}

