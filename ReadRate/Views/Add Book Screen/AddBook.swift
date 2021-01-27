//
//  AddBookView.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/6/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct AddBook: View {
    var bookStore: BookStore
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var title = ""
    @State var author = ""
    @State var pageCount = ""
    @State var currentPage = ""
    @State var readingDays = ""
    @State var startDate = Date()
    @State var targetDate = Date()
    @State var isbn = ""
    
    @State var showingSearch = false
    @State var fetchStatus: FetchStatus = .idle
    
    var addButtonIsDisabled: Bool {
        title.isEmpty || author.isEmpty || pageCount.isEmpty || currentPage.isEmpty
    }
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Text("Start a New Book")
                        .rounded(.title).padding(.bottom).padding(.top)
                    Spacer()
                    Button(action: { showingSearch = true }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title2)
                    }
                }
                LabeledInput(label: "What's the name of the book?", placeholder: "Book title", value: $title).autocapitalization(.sentences)
                LabeledInput(label: "Who's the author?", placeholder: "Author's name", value: $author).autocapitalization(.words)
                LabeledInput(label: "How many pages are in it?", placeholder: "Total page count", value: $pageCount).keyboardType(.numberPad)
                LabeledInput(label: "Which page are you starting on?", placeholder: "Starting page", value: $currentPage).keyboardType(.numberPad)
                DatePicker(
                    selection: $targetDate,
                    in: startDate...,
                    displayedComponents: .date,
                    label: { Text("When do you want to finish the book?")
                        .rounded(.callout) }
                )
                .padding(.vertical, 10)
                LabeledInput(label: "What's the book's ISBN? (Optional)", placeholder: "ISBN (used to find cover art)", value: $isbn).keyboardType(.numberPad)
            }

            if fetchStatus == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(10)
            } else {
                Button(action: addBook) {
                    StyledButton(iconName: "book", label: "Add Book", bgColor: Color("SheetButton"))
                }
                .disabled(addButtonIsDisabled)
                .padding(.bottom, 8.0)
            }

        }
        .sheet(isPresented: $showingSearch) {
            SearchView(title: $title, author: $author, pageCount: $pageCount, isbn: $isbn)
        }
    }
    
    func addBook() {        
        // Creates a new book with the data from the form
        var newBook = Book(
            title: self.title,
            author: self.author,
            pageCount: Int(self.pageCount)!,
            currentPage: Int(self.currentPage)!,
            startDate: Date(),
            targetDate: self.targetDate,
            ISBN: isbn
        )
        
        if newBook.ISBN != nil && newBook.ISBN!.count > 0 {
            fetchStatus = .loading
            ISBNSearcher().findBook(for: newBook.ISBN!, success: {
                newBook.covers = $0["ISBN:\(newBook.ISBN!)"]?.cover
                fetchStatus = .success
                // Adds the new book to the store
                self.bookStore.books.append(newBook)
                self.presentationMode.wrappedValue.dismiss()
            }, failure: {
                print($0)
                fetchStatus = .failure
                // Adds the new book to the store
                self.bookStore.books.append(newBook)
                self.presentationMode.wrappedValue.dismiss()
            })
        } else {
            self.bookStore.books.append(newBook)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddBook(bookStore: BookStore())
            AddBook(bookStore: BookStore())
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        }
    }
}
