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
        if let found = shelf.books.firstIndex(of: book) {
            shelf.books[found].archivedAt = nil
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedBooks(shelf: BookStore())
    }
}
