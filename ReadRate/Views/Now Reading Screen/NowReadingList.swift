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
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
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
                        if #available(iOS 17.0, *) {
                            ContentUnavailableView("No Active Books", systemImage: "bookmark.slash", description: Text("You don't have any books in progress."))
                        } else {
                            VStack(alignment: .center, spacing: 12) {
                                Image(systemName: "books.vertical").font(.largeTitle).foregroundStyle(Color.secondary)
                                Text("No Active Books")
                                    .rounded(.title3)
                                    .foregroundStyle(Color.secondary)
                                    
                            }
                            .frame(width: 160)
                            .padding(30)
                            .background(Color("BookBG"))
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(destination: ArchivedBooks(shelf: bookStore)) {
                        StyledButton(iconName: "archivebox", label: "Archived Books", bgColor: Color("BookBG"))
                    }
                    Button(action: {
                        showSheet = true
                    }) {
                        StyledButton(iconName: "book", label: "Add Book", bgColor: Color("BookBG"))
                    }
                    Spacer()
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 18.0)
            .onAppear() {
                bookStore.setTodaysTargets()
            }
            .navigationBarHidden(true)
            .navigationTitle("Now Reading")
        } detail: {
            Text("Select a book")
        }
        .sheet(isPresented: $showSheet, onDismiss: { bookStore.setTodaysTargets() }) {
            AddBook(bookStore: bookStore)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
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
