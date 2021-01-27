//
//  NowReadingList.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct StyledButton: View {
    let iconName: String
    let label: String
    let bgColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.accentColor)
            Text(label)
                .foregroundColor(.primary)
                .rounded()
        }
        .padding(.vertical, 10.0)
        .padding(.horizontal, 14.0)
        .background(bgColor)
        .cornerRadius(12.0)
    }
}

struct NowReadingList: View {
    @ObservedObject var bookStore: BookStore
    @State var showSheet = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Now Reading").rounded(.largeTitle)
                    .padding(.top, 20.0)
                if bookStore.activeBooks.count > 0 {
                    ScrollView {
                        ForEach(bookStore.activeBooks) { book in
                            NavigationLink(
                                destination: BookDetail(book: $bookStore.books[bookStore.books.firstIndex(of: book)!], shelf: bookStore),
                                label: {
                                    BookRow(book: $bookStore.books[bookStore.books.firstIndex(of: book)!])
                                })
                        }
                        .padding(.vertical, 2.0)
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
                        self.showSheet = true
                    }) {
                        StyledButton(iconName: "book", label: "Add Book", bgColor: Color("BookBG"))
                    }
                    Spacer()
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 18.0)
            .onAppear() {
                self.bookStore.setTodaysTargets()
            }
            .navigationBarHidden(true)
            .navigationTitle("Now Reading")
        }
        .sheet(isPresented: $showSheet, onDismiss: { self.bookStore.setTodaysTargets() }) {
            AddBook(bookStore: self.bookStore)
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
