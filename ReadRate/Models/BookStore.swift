//
//  BookStore.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import Foundation
import Combine
import WidgetKit

var bookOne = Book(id: UUID(), title: "The Great Gatsby", author: "F. Scott Fitzgerald", pageCount: 320, currentPage: 23, startDate: Date(), targetDate: Date().advanced(by: TimeInterval(60*60*24*20)), dailyTargets: [DailyTarget(targetPage: 38, calcTime: Date(), meta: DailyTargetMeta(pageCount: 320, currentPage: 23, targetDate: Date().advanced(by: TimeInterval(60*60*24*20))))], archivedAt: nil, completedAt: nil, deletedAt: nil, ISBN: nil, covers: nil)

var bookTwo = Book(id: UUID(), title: "Jane Eyre", author: "Charlotte Brontë", pageCount: 320, currentPage: 233, startDate: Date(), targetDate: Date().advanced(by: TimeInterval(60*60*24*12)), dailyTargets: [DailyTarget(targetPage: 241, calcTime: Date(), meta: DailyTargetMeta(pageCount: 320, currentPage: 1, targetDate: Date().advanced(by: TimeInterval(60*60*24*12))))], archivedAt: nil, completedAt: nil, deletedAt: nil, ISBN: nil, covers: nil)

var bookThree = Book(id: UUID(), title: "Frankenstein", author: "Mary Shelley", pageCount: 320, currentPage: 120, startDate: Date(), targetDate: Date().advanced(by: TimeInterval(60*60*24*18)), dailyTargets: [DailyTarget(targetPage: 142, calcTime: Date(), meta: DailyTargetMeta(pageCount: 10, currentPage: 1, targetDate: Date().advanced(by: TimeInterval(60*60*24*18))))], archivedAt: nil, completedAt: nil, deletedAt: nil, ISBN: nil, covers: nil)

var bookFour = Book(id: UUID(), title: "Little Women", author: "Louisa May Alcott", pageCount: 320, currentPage: 190, startDate: Date(), targetDate: Date().advanced(by: TimeInterval(60*60*24*4)), dailyTargets: [DailyTarget(targetPage: 222, calcTime: Date(), meta: DailyTargetMeta(pageCount: 10, currentPage: 1, targetDate: Date().advanced(by: TimeInterval(60*60*24*2))))], archivedAt: nil, completedAt: nil, deletedAt: nil, ISBN: nil, covers: nil)

class BookStore: ObservableObject {
    let bookStoreURL = URL(
        fileURLWithPath: "BookStore",
        relativeTo: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    ).appendingPathExtension("json")
    
    let appGroupURL = URL(fileURLWithPath: "BookStore", relativeTo: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.evanfreeze.ReadRate")).appendingPathExtension("json")
    
    @Published var books: [Book] = [] {
        didSet {
            saveBookStoreJSON()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    var activeBooks: [Book] {
        books.filter({ $0.archivedAt == nil && !$0.isDeleted })
    }
    
    var archivedBooks: [Book] {
        books.filter({ $0.isArchived && !$0.isDeleted }).sorted(by: { $0.archivedAt! > $1.archivedAt! })
    }
    
    init() {
        print(bookStoreURL)
        print(appGroupURL)
        loadBookStoreJSON()
    }
    
    private func loadBookStoreJSON() {
        if FileManager.default.fileExists(atPath: appGroupURL.path) {
            do {
                print("loading from app group...")
                let bookStoreData = try Data(contentsOf: appGroupURL)
                books = try JSONDecoder().decode([Book].self, from: bookStoreData)
                return
            } catch let error {
                print(error)
            }
        }
        
        guard FileManager.default.fileExists(atPath: bookStoreURL.path) else {
            return
        }
        
        do {
            print("loading from document directory")
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
            try bookStoreJSON.write(to: appGroupURL, options: .atomicWrite)
        } catch let error {
            print(error)
        }
    }
    
    public func setTodaysTargets() {
        print("setting today's target pages")
        
        guard activeBooks.count > 0 else {
            return
        }
        
        for (index, book) in books.enumerated() {
            if book.needsTargetUpdate {
                switch book.goalMode {
                case .date:
                    let targetMeta = DailyTargetMeta(pageCount: book.pageCount, currentPage: book.currentPage, targetDate: book.targetDate, mode: book.goalMode)
                    let nextStoppingPage = book.currentPage + book.getPagesPerDay()
                    let todaysTarget = DailyTarget(targetPage: nextStoppingPage, calcTime: Date(), meta: targetMeta)
                    books[index].dailyTargets.append(todaysTarget)
                case .rate:
                    let daysLeftAtRate = (Double(book.pageCount) - Double(book.currentPage)) / Double(book.rateGoal!)
                    let newTargetDate = Date().advanced(by: 60 * 60 * 24 * daysLeftAtRate)
                    let targetMeta = DailyTargetMeta(pageCount: book.pageCount, currentPage: book.currentPage, targetDate: newTargetDate, rateGoal: book.rateGoal!, mode: book.goalMode)
                    let targetPage = book.currentPage + book.rateGoal!
                    let todaysTarget = DailyTarget(targetPage: targetPage, calcTime: Date(), meta: targetMeta)
                    books[index].dailyTargets.append(todaysTarget)
                }
            }
        }
    }
        
    static func generateRandomSampleBooks() -> [Book] {
        [bookOne, bookFour, bookTwo, bookThree]
    }
}
