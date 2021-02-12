//
//  Book.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import Foundation
import SwiftUI

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
                if isCompleted {
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
    var deletedAt: Date?
    var ISBN: String?
    var covers: ISBNBook.ISBNCover?
    
    // MARK: Computed Properties
    var readToday: Bool {
        currentPage >= dailyTargets.last?.targetPage ?? pageCount
    }
    
    var percentComplete: String {
        "\(Int((getCompletionPercentage() * 100).rounded()))%"
    }
    
    var pagesPerDay: String {
        String(getPagesPerDay())
    }
    
    var pagesRemainingToday: String {
        String((dailyTargets.last?.targetPage ?? pageCount) - currentPage)
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
    
    var displayStartDateShort: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: startDate)
    }
    
    var displayFinishDate: String {
        if isCompleted {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: completedAt!)
        } else {
            return "Not completed"
        }
    }
    
    var archivedDaysRead: String {
        if isCompleted {
            let daysText = daysBetweenStartAndFinish == 1 ? "day" : "days"
            return "Read in \(daysBetweenStartAndFinish) \(daysText), about \(archivedPagesReadPerDay) pages per day"
        } else {
            let pagesleft = pageCount - currentPage
            let pageText = pagesleft == 1 ? "page" : "pages"
            return "Not finished, \(pagesleft) \(pageText) remaining (\(percentComplete) complete)"
        }
    }
    
    var daysBetweenStartAndFinish: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: completedAt!).day! + 1
        return days
    }
    
    var archivedPagesReadPerDay: Int {
        if isCompleted {
            return Int((Double(pageCount) / Double(daysBetweenStartAndFinish)).rounded())
        } else {
            return 0
        }
    }
    
    var finishedDateShort: String {
        if isCompleted {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: completedAt!)
        } else {
            return "N/A"
        }
    }
    
    var displayCompletedDate: (String, String) {
        if isCompleted {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: completedAt!).uppercased()
            formatter.dateFormat = "d"
            let day = formatter.string(from: completedAt!)
            return (month, day)
        } else {
            return ("DNF", "--")
        }
    }
    
    var displayLastGoalCalculatedDate: String {
        if let lastCalculatedDate = dailyTargets.last?.calcTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: lastCalculatedDate)
        } else {
            return "N/A"
        }
    }
    
    var progressDescription: String {
        if isNotStarted {
            return "Start reading on \(displayStartDate)"
        } else if currentPage == pageCount {
            return "You finished the book — congrats!"
        } else if readToday {
            return "You've read enough today to stay on track"
        } else {
            return "Read to page \(dailyTargets.last?.targetPage ?? pageCount) today to stay on track"
        }
    }
    
    var progressDescriptionShort: String {
        if isNotStarted {
            return "Starting \(displayStartDateShort)"
        } else if currentPage >= pageCount {
            return "You finished the book!"
        } else if readToday {
            return "Read enough today"
        } else {
            return "Read to page \(dailyTargets.last?.targetPage ?? pageCount)"
        }
    }
    
    var isCompleted: Bool {
        completedAt != nil
    }
    
    var isArchived: Bool {
        archivedAt != nil
    }
    
    var isDeleted: Bool {
        deletedAt != nil
    }
    
    var isNotStarted: Bool {
        // In the future and also not in the current day
        Date() < startDate && !Calendar.current.isDateInToday(startDate)
    }
    
    var progressBarFillAmount: Double {
        let minAmount = 0.01
        let completionPercentage = getCompletionPercentage()
        
        if completionPercentage < minAmount {
            return minAmount
        } else {
            return completionPercentage
        }
    }
    
    var progressColor: Color {
        if isNotStarted {
            return .gray
        } else if currentPage == pageCount {
            return .yellow
        } else if readToday {
            return .green
        } else {
            return .accentColor
        }
    }
    
    var progressIcon: some View {
        Group {
            if isNotStarted {
                Image(systemName: "calendar")
                    .foregroundColor(progressColor)
                    .font(Font.system(.body).bold())
            } else if currentPage == pageCount {
                Image(systemName: "star.fill")
                    .foregroundColor(progressColor)
                    .font(Font.system(.body).bold())
            } else if readToday {
                Image(systemName: "checkmark")
                    .foregroundColor(progressColor)
                    .font(Font.system(.body).bold())
            } else {
                Text(pagesRemainingToday)
                    .foregroundColor(progressColor)
                    .font(Font.system(.body, design: Font.Design.rounded).bold())
            }
        }
    }
    
    var needsTargetUpdate: Bool {
        if isCompleted || isArchived || isDeleted || isNotStarted {
            return false
        }
        
        let hasNotBeenUpdatedToday = !Calendar.current.isDateInToday(dailyTargets.last?.calcTime ?? Date().addingTimeInterval(60 * 60 * -48))
        let targetDateChangedSinceLastUpdate = targetDate != dailyTargets.last?.meta.targetDate ?? targetDate
        
        return hasNotBeenUpdatedToday || targetDateChangedSinceLastUpdate
    }
    
    // MARK: Methods
    func getCompletionPercentage() -> Double {
        if pageCount > 0 {
            return Double(currentPage) / Double(pageCount)
        } else {
            return 0
        }
    }

    func getPagesPerDay() -> Int {
        let pagesRemaining = Double(pageCount - currentPage)
        var pagesPerDay: Double
        
        if isNotStarted {
            pagesPerDay = 0
        } else {
            pagesPerDay = pagesRemaining / getReadingDaysFromDates(start: Date())
        }
        
        if !pagesPerDay.isNaN && pagesPerDay.isFinite {
            return Int(pagesPerDay.rounded())
        }
        
        return Int(pagesRemaining)
    }
    
    func getReadingDaysFromDates(start: Date) -> Double {
        let days = Calendar.current.dateComponents([.day], from: start, to: targetDate).day!
        return Double(days + 1)
    }
    
    // MARK: Comparable Conformance
    static func < (lhs: Book, rhs: Book) -> Bool {
        lhs.startDate < rhs.startDate
    }

    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.startDate == rhs.startDate && lhs.title == rhs.title && lhs.author == rhs.author
    }
}
