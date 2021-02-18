//
//  PagesPerDayPicker.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/17/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct PagesPerDayPicker: View {
    var selection: Binding<Int>
    
    var body: some View {
        Group {
            Text("How many pages per day?")
            Picker("How many pages per day?", selection: selection) {
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

struct PagesPerDayPicker_Previews: PreviewProvider {
    static var previews: some View {
        PagesPerDayPicker(selection: .constant(15))
    }
}
