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

class BookStore: ObservableObject {
    let bookStoreURL = URL(
        fileURLWithPath: "BookStore",
        relativeTo: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    ).appendingPathExtension("json")
    
//    let archiveURL = URL(
//        fileURLWithPath: "BookArchive",
//        relativeTo: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    ).appendingPathExtension("json")
    
    @Published var books: [Book] = [bookOne, bookTwo, bookThree] {
        didSet {
            saveBookStoreJSON()
        }
    }
    
    var activeBooks: [Book] {
        books.filter({ $0.archivedAt == nil })
    }
    
    var archivedBooks: [Book] {
        books.filter({ $0.archivedAt != nil })
    }
//
//    @Published var archivedBooks: [Book] = [] {
//        didSet {
//            saveArchiveJSON()
//        }
//    }
    
    init() {
        print(bookStoreURL)
        loadBookStoreJSON()
//        loadArchiveJSON()
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
    
//    private func loadArchiveJSON() {
//        guard FileManager.default.fileExists(atPath: archiveURL.path) else {
//            return
//        }
//
//        do {
//            let archivedBooksData = try Data(contentsOf: archiveURL)
//            archivedBooks = try JSONDecoder().decode([Book].self, from: archivedBooksData)
//            print(archivedBooks)
//        } catch let error {
//            print(error)
//        }
//    }
//
//    private func saveArchiveJSON() {
//        do {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//
//            let archivedBooksJSON = try encoder.encode(archivedBooks)
//            try archivedBooksJSON.write(to: archiveURL, options: .atomicWrite)
//        } catch let error {
//            print(error)
//        }
//    }
    
    public func setTodaysTargets() {
        print("setting today's target pages")
        
        guard books.count > 0 else {
            return
        }
        
        for (index, book) in books.enumerated() {
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
    
//    public func archiveBooks() {
//        for book in books {
//            if book.archivedAt != nil {
//                archivedBooks.append(book)
//                books.removeAll(where: { $0 == book })
//            }
//        }
//    }
    
    private func migrateBooks() {
//        for (index, _) in books.enumerated() {
//            books[index].todaysTargetLastUpdated = Date().addingTimeInterval(TimeInterval(-60 * 60 * 24))
//        }
    }
}

