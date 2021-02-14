//
//  Date.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/12/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import Foundation

extension Date {
    func prettyPrinted(_ style: DateFormatter.Style = .long) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    private func printDateUsing(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func printMonthShort() -> String {
        printDateUsing(format: "MMM")
    }
    
    func printMonthAndYear() -> String {
        printDateUsing(format: "MMMM y")
    }
    
    func printDayOfMonthShort() -> String {
        printDateUsing(format: "d")
    }
}
