//
//  BookStore.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import Foundation
import Combine

var bookOne = Book(
    title: "The Fault in Our Stars",
    author: "John Green",
    pageCount: 320,
    currentPage: 23,
    startDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * -4)),
    targetDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * 10))
)

var bookTwo = Book(
    title: "Deep Work",
    author: "Cal Newport",
    pageCount: 300,
    currentPage: 243,
    startDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * -1)),
    targetDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * 5))
)

var bookThree = Book(
    title: "So You Want to Talk About Race",
    author: "Ijeoma Oluo",
    pageCount: 238,
    currentPage: 70,
    startDate: Date(),
    targetDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * 24))
)

var bookFour = Book(
    title: "A Promised Land",
    author: "Barack Obama",
    pageCount: 750,
    currentPage: 750,
    startDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * -12)),
    targetDate: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * -2)),
    archivedAt: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * -3)),
    completedAt: Date().advanced(by: TimeInterval(60.0 * 60.0 * 24 * -3))
)

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
    
    var activeBooks: [Book] {
        books.filter({ $0.archivedAt == nil && !$0.isDeleted })
    }
    
    var archivedBooks: [Book] {
        books.filter({ $0.archivedAt != nil && !$0.isDeleted }).sorted(by: { $0.archivedAt! > $1.archivedAt! })
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
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let bookStoreJSON = try encoder.encode(books)
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
            if book.completedAt != nil || book.archivedAt != nil {
                print("skipping \(book.title) because it's either archived or completed")
                continue
            }
            
            let hasNotBeenUpdatedToday = !Calendar.current.isDateInToday(book.dailyTargets.last?.calcTime ?? Date().addingTimeInterval(60 * 60 * -48))
            let targetDateChangedSinceLastUpdate = book.targetDate != book.dailyTargets.last?.meta.targetDate ?? book.targetDate
            let isNotComplete = book.currentPage < book.pageCount
            
            if isNotComplete && (hasNotBeenUpdatedToday || targetDateChangedSinceLastUpdate) {
                let targetMeta = DailyTargetMeta(pageCount: books[index].pageCount, currentPage: books[index].currentPage, targetDate: books[index].targetDate)
                let todaysTarget = DailyTarget(targetPage: Int(book.nextStoppingPage)!, calcTime: Date(), meta: targetMeta)
                
                books[index].dailyTargets.append(todaysTarget)
                print("set target for \(book.title)")
            } else {
                print("skipped setting target for \(book.title)")
            }
        }
    }
    
    private func migrateBooks() {
//        for (index, _) in books.enumerated() {
//            books[index].todaysTargetLastUpdated = Date().addingTimeInterval(TimeInterval(-60 * 60 * 24))
//        }
    }
}

