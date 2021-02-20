//
//  HasReadingGoal.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/17/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import Foundation

protocol HasTargetDateGoal {
    var startDate: Date { get }
    var targetDate: Date { get }
}

protocol HasPagesPerDayGoal {
    var rateGoal: Int? { get }
}

protocol HasReadingGoal: HasTargetDateGoal, HasPagesPerDayGoal {
    var goalMode: GoalMode { get }
    var pageCount: Int { get }
    var currentPage: Int { get }
}
