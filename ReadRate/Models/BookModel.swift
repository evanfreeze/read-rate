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
    var rateGoal: Int?
    var mode: GoalMode?
}

struct DailyTarget: Codable {
    var targetPage: Int
    var calcTime: Date
    var meta: DailyTargetMeta
}

enum GoalMode: String, Codable {
    case date = "date"
    case rate = "rate"
}

struct Book: Identifiable, Codable, Comparable, HasReadingGoal {
    
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
    var mode: GoalMode?
    var rateGoal: Int?
    
    // MARK: Computed Properties
    var goalMode: GoalMode {
        mode ?? .date
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
    
    var isOverdue: Bool {
        // Target date has already passed and the book isn't finished, so a new target date needs to be picked
        Date() > targetDate && !isCompleted
    }
    
    var readEnoughToday: Bool {
        currentPage >= dailyTargets.last?.targetPage ?? pageCount
    }
    
    var completionPercentage: Double {
        if pageCount > 0 {
            return Double(currentPage) / Double(pageCount)
        } else {
            return 0
        }
    }
    
    var floatingTargetDateAtRateGoal: Date? {
        if goalMode == .rate {
            let daysLeftAtTarget = Double(pageCount - currentPage) / Double(rateGoal!)
            return Date().advanced(by: 60 * 60 * 24 * daysLeftAtTarget)
        } else {
            return nil
        }
    }
    
    var displayPagesRemainingToday: String {
        String((dailyTargets.last?.targetPage ?? pageCount) - currentPage)
    }
    
    var archivedDaysRead: String {
        if isCompleted {
            let daysBetweenStartAndFinish = Calendar.current.dateComponents([.day], from: startDate, to: completedAt!).day! + 1
            let daysText = daysBetweenStartAndFinish == 1 ? "day" : "days"
            let archivedPagesReadPerDay = Int((Double(pageCount) / Double(daysBetweenStartAndFinish)).rounded())
            return "Read in \(daysBetweenStartAndFinish) \(daysText), about \(archivedPagesReadPerDay) pages per day"
        } else {
            let pagesleft = pageCount - currentPage
            let pageText = pagesleft == 1 ? "page" : "pages"
            return "Not finished, \(pagesleft) \(pageText) remaining (\(completionPercentage.asRoundedPercent()) complete)"
        }
    }
    
    var completedDateForCalendarIcon: (String, String) {
        if isCompleted {
            return (completedAt!.printMonthShort().uppercased(), completedAt!.printDayOfMonthShort())
        } else {
            return ("DNF", "--")
        }
    }
    
    var displayLastGoalCalculatedDate: String {
        if let lastCalculatedDate = dailyTargets.last?.calcTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: lastCalculatedDate)
        } else {
            return "N/A"
        }
    }
    
    var progressDescription: String {
        if isNotStarted {
            return "Start reading on \(startDate.prettyPrinted())"
        } else if currentPage == pageCount {
            return "You finished the book — congrats!"
        } else if readEnoughToday {
            return "You've read enough today to stay on track"
        } else if isOverdue {
            return "Pick a new target date to get back on track"
        } else {
            return "Read to page \(dailyTargets.last?.targetPage ?? pageCount) today to stay on track"
        }
    }
    
    var progressDescriptionShort: String {
        if isNotStarted {
            return "Starting \(startDate.prettyPrinted(.short))"
        } else if currentPage >= pageCount {
            return "You finished the book!"
        } else if readEnoughToday {
            return "Read enough today"
        } else if isOverdue {
            return "Target date passed"
        } else {
            return "Read to page \(dailyTargets.last?.targetPage ?? pageCount)"
        }
    }
    
    var progressBarFillAmount: Double {
        let minAmount = 0.01
        
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
        } else if readEnoughToday {
            return .green
        } else if isOverdue {
            return .gray
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
            } else if readEnoughToday {
                Image(systemName: "checkmark")
                    .foregroundColor(progressColor)
                    .font(Font.system(.body).bold())
            } else if isOverdue {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(progressColor)
                    .font(Font.system(.body).bold())
            } else {
                Text(displayPagesRemainingToday)
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
        let goalModeChangedSinceLastUpdate = goalMode != dailyTargets.last?.meta.mode ?? goalMode
        var goalInputsChangedSinceLastUpdate = false
        
        switch goalMode {
        case .date:
            let targetDateAtLastGoalCalculation = dailyTargets.last?.meta.targetDate ?? targetDate
            if targetDate != targetDateAtLastGoalCalculation {
                goalInputsChangedSinceLastUpdate = true
            }
        case .rate:
            let rateGoalAtLastGoalCalculation = dailyTargets.last?.meta.rateGoal ?? rateGoal
            if rateGoal != rateGoalAtLastGoalCalculation {
                goalInputsChangedSinceLastUpdate = true
            }
        }
        
        return hasNotBeenUpdatedToday || goalModeChangedSinceLastUpdate || goalInputsChangedSinceLastUpdate
    }
    
    var completedMonthYear: String {
        if isCompleted {
            return completedAt!.printMonthAndYear()
        } else {
            return "Not Completed"
        }
    }
    
    // MARK: Methods
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
