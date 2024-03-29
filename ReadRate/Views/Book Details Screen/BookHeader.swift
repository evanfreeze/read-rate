//
//  BookHeader.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/12/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI


struct BookHeader: View {
    var book: Book
    
    var body: some View {
        HStack {
            WebImage(url: book.covers?.medium ?? "")
                .scaledToFit()
                .cornerRadius(6.0)
                .frame(width: 80)
                .padding()
            VStack(alignment: .leading, spacing: 0) {
                Text(book.title)
                    .rounded(.title)
                
                Text(book.author)
                    .rounded(.title2)
                    .foregroundStyle(Color.secondary)
                
                Divider().padding(.vertical, 8)
                
                Text(startedText)
                    .rounded(.caption, bold: false)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
        }
    }
    
    var startedText: String {
        "\(book.isFuture ? "Starting" : "Started") on \(book.startDate.prettyPrinted())"
    }
}

struct BookHeader_Previews: PreviewProvider {
    static var previews: some View {
        BookHeader(book: bookOne)
    }
}
