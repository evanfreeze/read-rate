//
//  Book.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import Foundation

struct Book: Identifiable, Codable {
    
    // MARK: Defined Properties
    let id = UUID()
    var title: String;
    var author: String;
    var pageCount: Int;
    var currentPage: Int;
    var startDate: Date;
    var targetDate: Date;
    var todaysTarget: Int;
    var todaysTargetLastUpdated: Date
    
    
    // MARK: Computed Properties
    var readToday: Bool {
        get {
            currentPage >= todaysTarget
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
    
    var nextStoppingPage: String {
        get {
            String(currentPage + Int(pagesPerDay)!)
        }
    }

    
    // MARK: Methods
    func getCompletionPercentage() -> Double {
        return Double(currentPage) / Double(pageCount)
    }

    func getPagesPerDay() -> Int {
        let pagesRemaining = Double(pageCount - currentPage)
        var pagesPerDay: Double
        
        if startDate.compare(Date()) == ComparisonResult.orderedAscending {
            // If the start date is in the past, we should use today's date to calculate the pages to read
            pagesPerDay = pagesRemaining / getReadingDaysFromDates(start: Date())
            
        } else {
            // If the start date is in the future, we should use it to calculate the pages to read
            pagesPerDay = pagesRemaining / getReadingDaysFromDates(start: startDate)
        }
        
        return Int(pagesPerDay.rounded())
    }
    
    func getReadingDaysFromDates(start: Date) -> Double {
        let days = Calendar.current.dateComponents([.day], from: start, to: targetDate).day!
        return Double(days + 1)
    }
}
