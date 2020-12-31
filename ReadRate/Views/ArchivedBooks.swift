//
//  ArchiveView.swift
//  ReadRate
//
//  Created by Evan Freeze on 12/29/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct ArchivedBooks: View {
    @ObservedObject var shelf: BookStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text("Archived Books").rounded(.largeTitle)
            ScrollView {
                ForEach(shelf.archivedBooks) { book in
                    HStack(alignment: .center, spacing: 20.0) {
                        CalendarIcon(
                            month: book.displayCompletedDate.0,
                            day: book.displayCompletedDate.1,
                            headerColor: book.completedAt != nil ? .blue : .gray
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
                            Text(book.archivedDaysRead)
                                .foregroundColor(.secondary)
                                .rounded(.caption, bold: false)
                        }
                        Spacer(minLength: 0)
                        Button(action: { unarchiveBook(book: book) }) {
                            Image(systemName: "arrowshape.turn.up.backward.circle.fill")
                                .font(.title3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.all, 20.0)
                    .background(Color("BookBG"))
                    .cornerRadius(20.0)
                }
            }
//            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func unarchiveBook(book: Book) {
        if let found = shelf.books.firstIndex(of: book) {
            shelf.books[found].archivedAt = nil
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ArchivedBooks(shelf: BookStore())
            ArchivedBooks(shelf: BookStore())
                .preferredColorScheme(.dark)
        }
    }
}
