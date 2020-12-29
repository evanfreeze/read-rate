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
                    ForEach(bookStore.books) { index in
                        NavigationLink(
                            destination: EditBookView(book: self.$bookStore.books[index], shelf: bookStore),
                            label: {
                                BookRow(book: self.$bookStore.books[index])
                            })
                    }
                    .onDelete { indexSet in
                        self.bookStore.books.remove(atOffsets: indexSet)
                    }
                    .onMove { indiciesToMove, destinationIndex in
                        self.bookStore.books.move(fromOffsets: indiciesToMove, toOffset: destinationIndex)
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
                self.bookStore.archiveBooks()
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
}

struct NowReadingList_Previews: PreviewProvider {
    static var previews: some View {
        NowReadingList(bookStore: BookStore())
    }
}
