//
//  StyledButton.swift
//  ReadRate
//
//  Created by Evan Freeze on 7/16/23.
//  Copyright © 2023 Evan Freeze. All rights reserved.
//

import SwiftUI

struct StyledButton: View {
    let iconName: String
    let label: String
    let bgColor: Color
    
    var body: some View {
        Label(
            title: { Text(label).foregroundColor(.primary).rounded() },
            icon: { Image(systemName: iconName).foregroundColor(.accentColor) }
        )
        .padding(.vertical, 10.0)
        .padding(.horizontal, 14.0)
        .background(bgColor)
        .cornerRadius(12.0)
    }
}


#Preview {
    StyledButton(iconName: "plus", label: "Add something", bgColor: Color(.systemGray6))
}
