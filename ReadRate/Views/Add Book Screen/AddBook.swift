//
//  AddBookView.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/6/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct BigButton: View {
    var label: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.largeTitle)
                .scaledToFill()
                .frame(width: 40, height: 40)
            Text(label).rounded(.headline).foregroundColor(.primary)

        }
        .frame(width: 150, height: 60)
        .padding(.vertical)
        .background(Color("SheetButton"))
        .cornerRadius(20)
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
    @State var isbn = ""
    @State var mode = GoalMode.date
    @State var readingRate = 15
    
    @State var showingSearchSheet = false
    @State var showingGoalSheet = false
    @State var fetchStatus: FetchStatus = .idle
    
    @State var showingForm = false
    @State var hasSetGoal = false

    var addButtonIsDisabled: Bool {
        title.isEmpty || author.isEmpty || pageCount.isEmpty || currentPage.isEmpty
    }
    
    var body: some View {
            VStack {
                Text("Start a New Book")
                    .rounded(.title)
                    .padding(.vertical, 8).padding(.top, 16)
                HStack {
                    Spacer(minLength: 0)
                    
                    Button(action: showSearchSheet) {
                        BigButton(label: "Search by ISBN", icon: "magnifyingglass")
                    }
                    .sheet(isPresented: $showingSearchSheet) {
                        SearchView(title: $title, author: $author, pageCount: $pageCount, isbn: $isbn)
                            .onDisappear(perform: {
                                if !isbn.isEmpty {
                                    showingForm = true
                                }
                            })
                    }
                    
                    Button(action: { showingForm = true }) {
                        BigButton(label: "Add Manually", icon: "hand.tap")
                    }
                    .sheet(isPresented: $showingGoalSheet) {
                        SetGoalScreen(startDate: $startDate, targetDate: $targetDate, mode: $mode, hasSetGoal: $hasSetGoal, readingRate: $readingRate, pageCount: Int(pageCount) ?? 0, currentPage: Int(currentPage) ?? 0)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.bottom)
                
                if showingForm {
                    manualEntryForm
                        .animation(.easeInOut)
                        .transition(.opacity)
                    
                    if hasSetGoal {
                        addBookButton
                    } else {
                        Button(action: showGoalSheet, label: {
                            StyledButton(iconName: "arrow.forward.circle", label: "Continue", bgColor: Color("SheetButton"))
                        })
                    }
                } else {
                    Spacer()
                }
            }
    }
    
    var addBookButton: some View {
        Group {
            if fetchStatus == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(10)
            } else {
                Button(action: addBook) {
                    StyledButton(iconName: "book", label: "Add Book", bgColor: Color("SheetButton"))
                }
                .disabled(addButtonIsDisabled || !hasSetGoal)
                .padding(.bottom, 8.0)
            }
        }
    }
    
    var manualEntryForm: some View {
        Form {
            Text("Book Details")
                .rounded(.title)
                .padding(.vertical, 4)
                .padding(.top, 6)
            LabeledInput(label: "What's the name of the book?", placeholder: "Book title", value: $title).autocapitalization(.sentences)
            LabeledInput(label: "Who's the author?", placeholder: "Author's name", value: $author).autocapitalization(.words)
            LabeledInput(label: "How many pages are in it?", placeholder: "Total page count", value: $pageCount).keyboardType(.numberPad)
            LabeledInput(label: "On which page are you starting?", placeholder: "Starting page", value: $currentPage).keyboardType(.numberPad)
            LabeledInput(label: "What's the ISBN? (Optional)", placeholder: "ISBN (used to find cover art)", value: $isbn).keyboardType(.numberPad)
            HStack {
                VStack(alignment: .leading) {
                    Text("Reading Goal")
                        .rounded(.callout)
                    if hasSetGoal {
                        GoalSummary(goalMode: mode, startDate: startDate, targetDate: targetDate, pageCount: Int(pageCount) ?? 0, currentPage: Int(currentPage) ?? 0, rateGoal: readingRate)
                    } else {
                        Text("Not set")
                    }
                }
                Spacer()
                Button(action: showGoalSheet, label: {
                    Image(systemName: "arrow.forward.circle")
                })
            }
            .padding(.vertical, 10.0)
        }
    }
    
    func addBook() {        
        // Creates a new book with the data from the form
        var newBook = Book(
            title: self.title,
            author: self.author,
            pageCount: Int(self.pageCount)!,
            currentPage: Int(self.currentPage)!,
            startDate: self.startDate,
            targetDate: self.targetDate,
            ISBN: isbn.cleanedNumeric(),
            mode: self.mode,
            rateGoal: self.mode == .rate ? readingRate : nil
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
    
    func showGoalSheet() {
        showingGoalSheet = true
    }
    
    func showSearchSheet() {
        showingSearchSheet = true
    }
}

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddBook(bookStore: BookStore())
            AddBook(bookStore: BookStore())
                .preferredColorScheme(.dark)
        }
    }
}
