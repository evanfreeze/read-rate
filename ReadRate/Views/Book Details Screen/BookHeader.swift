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
                .frame(width: 80)
                .padding()
            VStack(alignment: .leading, spacing: 0) {
                Text(book.title).rounded(.title)
                Text(book.author).rounded(.title2).foregroundColor(.secondary)
                Text(book.ISBN != "" && book.ISBN != nil ? "ISBN: \(book.ISBN!)" : "Unknown ISBN").rounded(.caption, bold: false).foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            Spacer()
        }
    }
}

struct BookHeader_Previews: PreviewProvider {
    static var previews: some View {
        BookHeader(book: bookOne)
    }
}
