//
//  NowReadingList.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct RoundedText: ViewModifier {
    let style: Font.TextStyle
    let bold: Bool
    
    func body(content: Content) -> some View {
        if bold {
            return content
                .font(Font.system(style, design: .rounded).bold())
        } else {
            return content
                .font(Font.system(style, design: .rounded))
        }
    }
}

extension Text {
    func rounded(_ style: Font.TextStyle = .body, bold: Bool = true) -> some View {
        self.modifier(RoundedText(style: style, bold: bold))
    }
}

struct NowReadingList: View {
    @ObservedObject var bookStore: BookStore
    @State var showSheet = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ForEach(bookStore.activeBooks) { book in
                    NavigationLink(
                        destination: BookDetail(book: $bookStore.books[bookStore.books.firstIndex(of: book)!], shelf: bookStore),
                        label: {
                            BookRow(book: $bookStore.books[bookStore.books.firstIndex(of: book)!])
                    })
                }
                .padding(.horizontal, 18.0)
                .padding(.vertical, 2.0)
                
                Spacer()
                
                if bookStore.archivedBooks.count > 0 {
                    HStack {
                        Spacer()
                        NavigationLink(destination: ArchivedBooks(shelf: bookStore)) {
                            Text("View Archived Books")
                        }
                        Spacer()
                    }
                }
            }
            .onAppear() {
                self.bookStore.setTodaysTargets()
            }
            .navigationBarTitle(Text("Now Reading"))
            .navigationBarItems(
                trailing: Button(action: {
                    self.showSheet = true
                }) {
                    HStack {
                        Image(systemName: "book")
                            .foregroundColor(.accentColor)
                        Text("Add Book")
                            .foregroundColor(.primary)
                            .rounded()
                    }
                    .padding(.vertical, 10.0)
                    .padding(.horizontal, 14.0)
                    .background(Color("BookBG"))
                    .cornerRadius(12.0)
                }
            )
        }
        .sheet(isPresented: $showSheet, onDismiss: { self.bookStore.setTodaysTargets() }) {
            AddBook(bookStore: self.bookStore)
        }
    }
}

struct NowReadingList_Previews: PreviewProvider {
    static var previews: some View {
        NowReadingList(bookStore: BookStore())
            .preferredColorScheme(.dark)
    }
}
