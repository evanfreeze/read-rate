//
//  NowReadingList.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NowReadingList: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var bookStore = BookStore()
    @State var showSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Image(systemName: "books.vertical").font(.title).foregroundStyle(Color.accentColor)
                    Text("Now Reading").rounded(.largeTitle)
                }
                .padding(.top, 30)
                .padding(.bottom, 0)

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
            .padding(.horizontal, 18.0)
            .navigationBarHidden(true)
            .navigationTitle("Now Reading")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(destination: ArchivedBooks(shelf: bookStore)) {
                        Button("View Archived Books", systemImage: "archivebox", action: {})
                    }
                    Spacer()
                    Button("Add Book", systemImage: "plus", action: {
                        showSheet = true
                    })
                }
            }
        }
        .sheet(isPresented: $showSheet, onDismiss: { bookStore.setTodaysTargets() }) {
            AddBook(bookStore: bookStore)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                bookStore.readBooksAndSyncFromJSON()
                bookStore.setTodaysTargets()
            } else {
                WidgetCenter.shared.reloadAllTimelines()
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
