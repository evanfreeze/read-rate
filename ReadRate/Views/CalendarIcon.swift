//
//  CalendarIcon.swift
//  ReadRate
//
//  Created by Evan Freeze on 12/31/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct CalendarIcon: View {
    let month: String
    let day: String
    
    var body: some View {
        VStack {
            Text(month)
                .rounded()
                .frame(width: 40, height: 24)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .background(Color.blue)
            Text(day)
                .rounded(.title)
                .frame(width: 40)
                .padding(.horizontal, 10)
                .padding(.bottom, 3)
                .background(Color("CalBG"))
        }
        .cornerRadius(8)
        .shadow(radius: 3)
    }
}

struct CalendarIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            CalendarIcon(month: "JAN", day: "13")
                .previewLayout(PreviewLayout.fixed(width: 100, height: 100))
            CalendarIcon(month: "FEB", day: "28")
                .previewLayout(PreviewLayout.fixed(width: 100, height: 100))
            CalendarIcon(month: "MAR", day: "30")
                .previewLayout(PreviewLayout.fixed(width: 100, height: 100))
            CalendarIcon(month: "OCT", day: "26")
                .previewLayout(PreviewLayout.fixed(width: 100, height: 100))
        }
    }
}
