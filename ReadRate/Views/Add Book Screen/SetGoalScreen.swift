//
//  SetGoalScreen.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/15/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct SetGoalScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    // MARK:- Initial Properties
    var startDate: Binding<Date>
    var targetDate: Binding<Date>
    var mode: Binding<GoalMode>
    var hasSetGoal: Binding<Bool>
    var readingRate: Binding<Int>
    var interimRate: String
    
    // MARK:- Body
    var body: some View {
        VStack() {
            Text("Set Your Goal").rounded(.title).padding(.vertical, 8).padding(.top, 16)
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Goal Type").rounded(.title3)
                        Picker("Which type of goal do you want to use for this book?", selection: mode) {
                            Text("Target Date").tag(GoalMode.date)
                            Text("Pages Per Day").tag(GoalMode.rate)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.vertical)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(modeTitle).rounded(.title3)
                        Text(modeDescription).rounded(.callout, bold: false).foregroundColor(.secondary)
                    }.padding(.vertical)
                    
                    goalForm
                }
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your Goal").rounded(.title3)
                        Text(interimRate)
                            .rounded(.callout, bold: false).foregroundColor(.secondary)
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
        presentationMode.wrappedValue.dismiss()
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
                readingRateGoalForm
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
    
    var readingRateGoalForm: some View {
        Group {
            Text("How many pages do you want to read per day?")
            Picker("How many pages do you want to read per day?", selection: readingRate) {
                Text("5").tag(5)
                Text("10").tag(10)
                Text("15").tag(15)
                Text("20").tag(20)
                Text("25").tag(25)
                Text("30").tag(30)
                Text("50").tag(50)
                Text("75").tag(75)
                Text("100").tag(100)
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
}

struct SetGoalScreen_Previews: PreviewProvider {
    static var previews: some View {
        SetGoalScreen(startDate: .constant(Date()), targetDate: .constant(Date().advanced(by: 60*60*24*14)), mode: .constant(.date), hasSetGoal: .constant(false), readingRate: .constant(15), interimRate: "This is where the interim rate would go")
    }
}
