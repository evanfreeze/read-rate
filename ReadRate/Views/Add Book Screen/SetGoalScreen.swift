//
//  SetGoalScreen.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/15/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct SetGoalScreen: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK:- Initial Properties
    var startDate: Binding<Date>
    var targetDate: Binding<Date>
    var mode: Binding<GoalMode>
    var hasSetGoal: Binding<Bool>
    var readingRate: Binding<Int>
    var pageCount: Int
    var currentPage: Int
    
    
    // MARK:- Body
    var body: some View {
        VStack() {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Set Your Reading Goal").rounded(.title2)
                        Picker("Which type of goal do you want to use for this book?", selection: mode) {
                            Text("Target Date").tag(GoalMode.date)
                            Text("Pages Per Day").tag(GoalMode.rate)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(modeTitle).rounded(.title3)
                            Text(modeDescription).rounded(.callout, bold: false).foregroundColor(.secondary)
                        }
                        .padding(20)
                        .padding(.bottom, 4)
                        .background(Color("BookBG"))
                        .cornerRadius(20)
                    }
                    .padding(.vertical)
                    
                    goalForm
                }
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Summary").rounded(.title3)
                        GoalSummary(goalMode: mode.wrappedValue, startDate: startDate.wrappedValue, targetDate: targetDate.wrappedValue, pageCount: pageCount, currentPage: currentPage, rateGoal: readingRate.wrappedValue)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                }
            }
            
            Spacer()
            
            Button(action: setGoal, label: {
                StyledButton(iconName: "calendar", label: "Set Goal", bgColor: Color("SheetButton"))
            })
        }
    }
    
    // MARK:- Methods
    func setGoal() {
        hasSetGoal.wrappedValue = true
        dismiss()
    }
    
    // MARK:- Computed Properties
    var modeTitle: String {
        switch mode.wrappedValue {
        case .date:
            return "Target Date Goal"
        case .rate:
            return "Pages Per Day Goal"
        }
    }
    
    var modeDescription: String {
        switch mode.wrappedValue {
        case .date:
            return "Pick when you want to finish the book and the app will adjust your pages per day to keep you on track"
        case .rate:
            return "Pick how many pages you want to read per day and the app will adjust your expected completion date based on that rate"
        }
    }
    
    // MARK:- Computed Views
    var goalForm: some View {
        Group {
            switch mode.wrappedValue {
            case .date:
                targetDateGoalForm
            case .rate:
                PagesPerDayPicker(selection: readingRate)
            }
        }
    }
    
    var targetDateGoalForm: some View {
        Group {
            DatePicker(
                selection: startDate,
                in: Date()...,
                displayedComponents: .date,
                label: { Text("When are you starting?")
                    .rounded(.callout) }
            )
            .padding(.vertical, 10)
            DatePicker(
                selection: targetDate,
                in: startDate.wrappedValue...,
                displayedComponents: .date,
                label: { Text("When do you want to finish?")
                    .rounded(.callout) }
            )
            .padding(.vertical, 10)
        }
    }
}

struct SetGoalScreen_Previews: PreviewProvider {
    static var previews: some View {
        SetGoalScreen(startDate: .constant(Date()), targetDate: .constant(Date().advanced(by: 60*60*24*14)), mode: .constant(.date), hasSetGoal: .constant(false), readingRate: .constant(15), pageCount: 100, currentPage: 1)
    }
}
