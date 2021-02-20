//
//  GoalSummary.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/17/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct GoalSummary: View, HasReadingGoal {
    var goalMode: GoalMode
    var startDate: Date
    var targetDate: Date
    var pageCount: Int
    var currentPage: Int
    var rateGoal: Int?
    
    var pagesRemaining: Double {
        Double(pageCount - currentPage)
    }
    
    var oneDay: TimeInterval {
        60 * 60 * 24
    }
    
    var textToDisplay: String {
        switch goalMode {
        case .date:
            let days = Double(Calendar.current.dateComponents([.day], from: startDate, to: targetDate).day!) + 1
            let pagesPerDay = (pagesRemaining / days).rounded()
            if pagesPerDay.isFinite && !pagesPerDay.isNaN && days.isFinite && !days.isNaN {
                return "\(Int(days)) \(days == 1 ? "day" : "days"), \(Int(pagesPerDay)) pages per day"
            }
            return "Invalid dates"
        case .rate:
            let daysOfReading = pagesRemaining / Double(rateGoal ?? 5)
            let daysToComplete = daysOfReading * oneDay
            let finishEstimate = Date().addingTimeInterval(daysToComplete)
            return "\(rateGoal!) pages per day (~\(finishEstimate.prettyPrinted(.short)))"
        }
    }
    
    var body: some View {
        Text(textToDisplay)
            .rounded(.body, bold: false)
    }
}

struct GoalSummary_Previews: PreviewProvider {
    static var previews: some View {
        GoalSummary(goalMode: .date, startDate: Date(), targetDate: Date(), pageCount: 100, currentPage: 1, rateGoal: nil)
    }
}
