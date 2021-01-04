//
//  AddBookView.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/6/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct LabeledInput: View {
    var label: String
    var placeholder: String
    var value: Binding<String>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .rounded(.callout)
            TextField(placeholder, text: value)
        }
        .padding(.vertical, 10.0)
    }
}

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
    
    var body: some View {
        VStack {
            Form {
                Text("Start a New Book")
                    .rounded(.title).padding(.bottom).padding(.top)
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
            }

            Button(action: addBook) {
                StyledButton(iconName: "book", label: "Add Book", bgColor: Color("BookBG"))
            }
            .disabled(shouldBeDisabled())
            .padding(.bottom, 8.0)

        }
    }
    
    
    
    func addBook() {        
        // Creates a new book with the data from the form
        let newBook = Book(
            title: self.title,
            author: self.author,
            pageCount: Int(self.pageCount)!,
            currentPage: Int(self.currentPage)!,
            startDate: Date(),
            targetDate: self.targetDate
        )
        
        // Adds the new book to the store
        self.bookStore.books.append(newBook)
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func shouldBeDisabled() -> Bool {
        return title.isEmpty || author.isEmpty || pageCount.isEmpty || currentPage.isEmpty
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
