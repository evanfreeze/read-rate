//
//  Book.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import Foundation

struct DailyTargetMeta: Codable {
    var pageCount: Int
    var currentPage: Int
    var targetDate: Date
}

struct DailyTarget: Codable {
    var targetPage: Int
    var calcTime: Date
    var meta: DailyTargetMeta
}

struct Book: Identifiable, Codable, Comparable {
    
    // MARK: Defined Properties
    var id = UUID()
    var title: String
    var author: String
    var pageCount: Int
    var currentPage: Int {
        didSet {
            if currentPage == pageCount {
                completedAt = Date()
            } else {
                if completedAt != nil {
                    completedAt = nil
                }
            }
        }
    }
    var startDate: Date
    var targetDate: Date
    var dailyTargets: [DailyTarget] = []
    var archivedAt: Date?
    var completedAt: Date?
    
    
    // MARK: Computed Properties
    var readToday: Bool {
        get {
            currentPage >= dailyTargets.last?.targetPage ?? pageCount
        }
    }
    
    var percentComplete: String {
        get {
            "\(Int((getCompletionPercentage() * 100).rounded()))%"
        }
    }
    
    var pagesPerDay: String {
        get {
            String(getPagesPerDay())
        }
    }
    
    var pagesRemainingToday: String {
        get {
            String((dailyTargets.last?.targetPage ?? pageCount) - currentPage)
        }
    }
    
    var nextStoppingPage: String {
        get {
            String(currentPage + Int(pagesPerDay)!)
        }
    }
    
    var displayCompletionTarget: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: targetDate)
    }
    
    var displayStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: startDate)
    }
    
    var displayFinishDate: String {
        if completedAt != nil {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: completedAt!)
        } else {
            return "Not completed"
        }
    }
    
    var archivedDaysRead: String {
        if completedAt != nil {
            let daysText = daysBetweenStartAndFinish == 1 ? "day" : "days"
            return "Read in \(daysBetweenStartAndFinish) \(daysText), averaging about \(archivedPagesReadPerDay) pages per day"
        } else {
            return "Not completed"
        }
    }
    
    var daysBetweenStartAndFinish: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: completedAt!).day! + 1
        return days
    }
    
    var archivedPagesReadPerDay: Int {
        if completedAt != nil {
            return Int((Double(pageCount) / Double(daysBetweenStartAndFinish)).rounded())
        } else {
            return 0
        }
    }
    
    var finishedDateShort: String {
        if completedAt != nil {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: completedAt!)
        } else {
            return "N/A"
        }
    }
    
    var displayCompletedDate: (String, String) {
        if completedAt != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: completedAt!).uppercased()
            formatter.dateFormat = "d"
            let day = formatter.string(from: completedAt!)
            return (month, day)
        } else {
            return ("N/A", "N/A")
        }
    }
    
    var progressDescription: String {
        if (currentPage == pageCount) {
            return "You finished the book — congrats!"
        } else if (readToday) {
            return "You've read enough today to stay on track"
        } else {
            return "Read to page \(dailyTargets.last?.targetPage ?? pageCount) today to stay on track"
        }
    }
    
    // MARK: Methods
    func getCompletionPercentage() -> Double {
        return Double(currentPage) / Double(pageCount)
    }

    func getPagesPerDay() -> Int {
        let pagesRemaining = Double(pageCount - currentPage)
        var pagesPerDay: Double
        
        if startDate < Date() {
            // If the start date is in the past, we should use today's date to calculate the pages to read
            pagesPerDay = pagesRemaining / getReadingDaysFromDates(start: Date())
            
        } else {
            // If the start date is in the future, we should use it to calculate the pages to read
            pagesPerDay = pagesRemaining / getReadingDaysFromDates(start: startDate)
        }
        
        if !pagesPerDay.isNaN && pagesPerDay.isFinite {
            return Int(pagesPerDay.rounded())
        }
        
        return Int(pagesRemaining)
    }
    
    func getReadingDaysFromDates(start: Date) -> Double {
        print(title)
        print("Start date: \(start.description)")
        let days = Calendar.current.dateComponents([.day], from: start, to: targetDate).day!
        print("days: \(start.description)")
        print("corrected days: \(Double(days + 2))")
        return Double(days + 2)
    }
    
    // MARK: Comparable Conformance
    static func < (lhs: Book, rhs: Book) -> Bool {
        lhs.startDate < rhs.startDate
    }
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.startDate == rhs.startDate && lhs.title == rhs.title && lhs.author == rhs.author
    }
}
