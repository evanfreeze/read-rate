//
//  NowReadingList.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct NowReadingList: View {
    @ObservedObject var bookStore: BookStore
    
    @State var showSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if bookStore.activeBooks.count > 0 {
                    ScrollView {
                        ForEach(bookStore.activeBooks) { book in
                            NavigationLink(value: book) {
                                BookRow(book: $bookStore.books[bookStore.books.firstIndex(of: book)!])
                                    .padding(.bottom, 2)
                            }
                        }
                        .navigationDestination(for: Book.self) { bookBinding in
                            BookDetail(book: $bookStore.books.first(where: { book in
                                book.id == bookBinding.id
                            })!, shelf: bookStore)
                        }
                    }
                } else {
                    Spacer()
                    HStack {
                        Spacer()
                        ContentUnavailableView("No Active Books", systemImage: "bookmark.slash", description: Text("You don't have any books in progress."))
                        Spacer()
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(18.0)
            .navigationTitle("Now Reading")
            .sheet(isPresented: $showSheet, onDismiss: { bookStore.setTodaysTargets() }) {
                AddBook(bookStore: bookStore)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Add Book", systemImage: "plus", action: {
                        showSheet = true
                    })
                }
            }
        }
    }
}

struct NowReadingList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NowReadingList(bookStore: BookStore())
            NowReadingList(bookStore: BookStore())
                .preferredColorScheme(.dark)
        }
            
    }
}
