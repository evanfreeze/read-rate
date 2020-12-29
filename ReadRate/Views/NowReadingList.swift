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
        NavigationView {
            VStack {
                List {
                    ForEach(bookStore.activeBooks) { book in
                        NavigationLink(
                            destination: EditBookView(book: $bookStore.books[bookStore.books.firstIndex(of: book)!], shelf: bookStore),
                            label: {
                                BookRow(book: $bookStore.books[bookStore.books.firstIndex(of: book)!])
                            })
                    }
                    .onDelete(perform: deleteBooks)
                    .onMove { indiciesToMove, destinationIndex in
                        moveBooks(indexesToMove: indiciesToMove, destinationIndex: destinationIndex)
                    }
                }
                Spacer()
                if bookStore.archivedBooks.count > 0 {
                    HStack {
                        Spacer()
                        NavigationLink(destination: ArchiveView(shelf: bookStore)) {
                            Text("View Archived Books")
                        }
                        Spacer()
                    }
                }
            }
            .onAppear() {
                self.bookStore.setTodaysTargets()
            }
            .navigationBarTitle("Now Reading")
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: {
                    self.showSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Image(systemName: "book")
                    }
                }
            )
        }
        .sheet(isPresented: $showSheet, onDismiss: { self.bookStore.setTodaysTargets() }) {
            AddBookView(bookStore: self.bookStore)
        }
    }
    
    func bookBindingForIndex(_ index: Int) -> Binding<Book> {
        if let found = bookStore.books.firstIndex(of: bookStore.activeBooks[index]) {
            return $bookStore.books[found]
        } else {
            fatalError()
        }
    }
    
    func deleteBooks(_ indexes: IndexSet) {
        for index in indexes {
            if let found = bookStore.books.firstIndex(of: bookStore.activeBooks[index]) {
                bookStore.books.remove(at: found)
            }
        }
    }
    
    func moveBooks(indexesToMove: IndexSet, destinationIndex: Int) {
        let foundIndexes = indexesToMove.map({ bookStore.books.firstIndex(of: bookStore.activeBooks[$0])! })
        let offsets = IndexSet(foundIndexes)
        
        bookStore.books.move(fromOffsets: offsets, toOffset: destinationIndex)
    }
}

struct NowReadingList_Previews: PreviewProvider {
    static var previews: some View {
        NowReadingList(bookStore: BookStore())
    }
}
