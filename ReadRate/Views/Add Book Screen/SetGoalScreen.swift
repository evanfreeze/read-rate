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
    var pageCount: Binding<String>
    var currentPage: Binding<String>
    
    
    // MARK:- Body
    var body: some View {
        VStack() {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Set Your Reading Goal").font(.title3).bold()
                        Picker("Which type of goal do you want to use for this book?", selection: mode) {
                            Text("Target Date").tag(GoalMode.date)
                            Text("Pages Per Day").tag(GoalMode.rate)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(modeTitle).font(.default).bold()
                            Text(modeDescription).font(.callout).foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(18)
                        .padding(.bottom, 4)
                        .background(Color("BookBG"))
                        .cornerRadius(20)
                    }
                    .padding(.vertical)
                    
                    goalForm
                }
                Section {
                    VStack(alignment: .leading) {
                        Text("Your Plan").font(.title3).bold()
                        GoalSummary(goalMode: mode.wrappedValue, startDate: startDate.wrappedValue, targetDate: targetDate.wrappedValue, pageCount: Int(pageCount.wrappedValue) ?? 0, currentPage: Int(currentPage.wrappedValue) ?? 0, rateGoal: readingRate.wrappedValue)
                            .foregroundStyle(Color.secondary)
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
            return "Pick when you want to finish the book and the app will adjust your pages per day to keep you on track."
        case .rate:
            return "Pick how many pages you want to read per day and the app will adjust your expected completion date based on that rate."
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
                label: { Text("When will you start?")
                    .font(.callout) }
            )
            DatePicker(
                selection: targetDate,
                in: startDate.wrappedValue...,
                displayedComponents: .date,
                label: { Text("When will you finish?")
                    .font(.callout) }
            )
        }
    }
}

struct SetGoalScreen_Previews: PreviewProvider {
    static var previews: some View {
        SetGoalScreen(startDate: .constant(Date()), targetDate: .constant(Date().advanced(by: 60*60*24*14)), mode: .constant(.date), hasSetGoal: .constant(false), readingRate: .constant(15), pageCount: .constant("100"), currentPage: .constant("1"))
    }
}
