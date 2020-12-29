//
//  ArchiveView.swift
//  ReadRate
//
//  Created by Evan Freeze on 12/29/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct ArchiveView: View {
    @ObservedObject var shelf: BookStore
    
    var body: some View {
        List(shelf.archivedBooks) { book in
            HStack {
                VStack {
                    Text(book.title)
                        .bold()
                    Text(book.author)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { unarchiveBook(book: book) }) {
                    Text("Unarchive")
                }
            }
        }
        .navigationBarTitle("Archived Books")
    }
    
    func unarchiveBook(book: Book) {
        var bookCopy = book
        bookCopy.archivedAt = nil
        shelf.books.append(bookCopy)
        shelf.archivedBooks.removeAll(where: { $0 == book })
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView(shelf: BookStore())
    }
}
