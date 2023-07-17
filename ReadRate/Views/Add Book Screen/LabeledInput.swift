//
//  LabeledInput.swift
//  ReadRate
//
//  Created by Evan Freeze on 1/27/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct LabeledInput: View {
    var label: String
    var placeholder: String
    var value: Binding<String>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .rounded(.callout)
                .foregroundStyle(value.wrappedValue.isEmpty ? Color.accentColor : .primary)
            TextField(placeholder, text: value)
        }
        .padding(.vertical, 10.0)
    }
}

struct LabeledInput_Previews: PreviewProvider {
    static var previews: some View {
        LabeledInput(label: "What's the author's name?", placeholder: "Author Name", value: .constant(""))
    }
}
