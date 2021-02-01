//
//  BookRow_v2.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/15/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct BookRow: View {
    @Binding var book: Book
    
    var body: some View {
        HStack(alignment: .center, spacing: 20.0) {
            ProgressCircle(
                progress: book.progressBarFillAmount,
                progressColor: book.progressColor,
                centerContent: book.progressIcon
            )
            VStack(alignment: .leading, spacing: 8.0) {
                VStack(alignment: .leading, spacing: 1.0) {
                    Text(book.title)
                        .rounded(.title2)
                        .foregroundColor(.primary)
                    Text(book.author)
                        .rounded(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text(book.progressDescription)
                    .foregroundColor(.secondary)
                    .rounded(.caption, bold: false)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 20.0)
        .background(Color("BookBG"))
        .cornerRadius(20.0)
    }
}

struct BookRow_v2_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookRow(book: .constant(BookStore().books[0]))
                .previewLayout(PreviewLayout.fixed(width: 360, height: 200))
            BookRow(book: .constant(BookStore().books[1]))
                .preferredColorScheme(.dark)
                .previewLayout(PreviewLayout.fixed(width: 360, height: 200))
        }
    }
}