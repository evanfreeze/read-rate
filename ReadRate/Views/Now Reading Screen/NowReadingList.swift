//
//  NowReadingList.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct NowReadingList: View {
    @StateObject var bookStore = BookStore()
    @State var showSheet = false
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Image(systemName: "books.vertical").font(.title).foregroundColor(.accentColor)
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
                        .navigationDestination(for: Book.self) {
                            BookDetail(book: $bookStore.books[bookStore.books.firstIndex(of: $0)!], shelf: bookStore)
                        }
                    }
                } else {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .center, spacing: 12) {
                            Image(systemName: "books.vertical").font(.largeTitle).foregroundColor(.secondary)
                            Text("No Active Books")
                                .rounded(.title3)
                                .foregroundColor(.secondary)
                                
                        }
                        .frame(width: 160)
                        .padding(30)
                        .background(Color("BookBG"))
                        .cornerRadius(20)
                        
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            bookStore.setTodaysTargets()
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
