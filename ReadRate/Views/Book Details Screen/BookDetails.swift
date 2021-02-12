//
//  EditBookView.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct BookDetail: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var book: Book
    @ObservedObject var shelf: BookStore
    
    @State private var editingTargetDate = false
    @State private var editingCurrentPage = false
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    @State private var fetchStatus: FetchStatus = .idle
    
    var goalSubtitle: String? {
        if book.readEnoughToday || book.isCompleted || book.isNotStarted {
            return nil
        } else {
            return "Goal last calculated at \(book.displayLastGoalCalculatedDate)"
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView {
                    BookHeader(book: book)
                    
                    Card(
                        title: "Today's Goal",
                        content: book.progressDescription,
                        subtitle: goalSubtitle
                    )
                    
                    ExpandableCard(
                        title: "Progress",
                        content: "Page \(book.currentPage) of \(book.pageCount) (\(book.completionPercentage.asRoundedPercent()) complete)",
                        isOpen: $editingCurrentPage,
                        openContent: editCurrentPage
                    )
                    .padding(.bottom, 1)
                    
                    ExpandableCard(
                        title: "Target Completion Date",
                        content: book.targetDate.prettyPrinted(),
                        isOpen: $editingTargetDate,
                        openContent: editTargetDate
                    )
                    .padding(.bottom, 1)
                    
                    Card(
                        title: "Start Date",
                        content: book.startDate.prettyPrinted(),
                        subtitle: nil
                    )
                    
                    if book.isCompleted {
                        Card(
                            title: "Finish Date",
                            content: book.completedAt?.prettyPrinted() ?? "Not completed",
                            subtitle: nil
                        )
                    }
                }
                
                HStack {
                    Spacer(minLength: 0)
                    archiveButton
                    editButton
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: deleteBookButton)
        .alert(isPresented: $showingDeleteAlert) { deleteBookAlert }
        .sheet(isPresented: $showingEditSheet) { editBookSheet }
    }
    
    var archiveButton: some View {
        Button(action: archiveBook) {
            StyledButton(iconName: "archivebox", label: "Archive", bgColor: Color("BookBG"))
        }
    }
    
    var editButton: some View {
        Button(action: { showingEditSheet = true }) {
            StyledButton(iconName: "pencil.circle", label: "Edit", bgColor: Color("BookBG"))
        }
    }
    
    var editCurrentPage: some View {
        Group {
            Picker("", selection: $book.currentPage) {
                ForEach(0..<book.pageCount + 1) {
                    Text(String($0)).tag($0)
                }
            }
            .pickerStyle(WheelPickerStyle())
            HStack {
                Button(action: {
                    withAnimation {
                        book.currentPage = book.pageCount
                        editingCurrentPage = false
                    }
                }) {
                    StyledButton(iconName: "star.circle", label: "Finish Book", bgColor: Color("BookBG"))
                }
                Button(action: {
                    withAnimation {
                        book.currentPage = book.dailyTargets.last?.targetPage ?? book.currentPage
                        editingCurrentPage = false
                    }
                }) {
                    StyledButton(iconName: "checkmark.circle", label: "Today's Goal", bgColor: Color("BookBG"))
                }
            }
        }
        .padding(.bottom, 10.0)
    }
    
    var editTargetDate: some View {
        DatePicker(
            "Update your target date",
            selection: $book.targetDate,
            in: book.startDate...,
            displayedComponents: .date
        )
        .padding([.horizontal, .bottom])
        .padding(.top, 6.0)
    }
    
    var editBookSheet: some View {
        let bookISBN = Binding<String>(
            get: {
                book.ISBN ?? ""
            },
            set: {
                book.ISBN = $0
            }
        )
        
        let bookPageCount = Binding<String>(
            get: {
                "\(book.pageCount)"
            },
            set: {
                book.pageCount = Int($0) ?? 0
            }
        )
        
        return Group {
            VStack {
                Form {
                    Text("Edit Book")
                        .rounded(.title).padding(.bottom).padding(.top)
                    LabeledInput(label: "Title", placeholder: "The name of the book", value: $book.title)
                    LabeledInput(label: "Author", placeholder: "Who wrote the book", value: $book.author)
                    LabeledInput(label: "The book's ISBN", placeholder: "ISBN (used to find cover art)", value: bookISBN).keyboardType(.numberPad)
                    LabeledInput(label: "Page Count", placeholder: "Total number of pages in the book", value: bookPageCount)
                        .keyboardType(.numberPad)
                    DatePicker(
                        selection: $book.startDate,
                        displayedComponents: .date,
                        label: { Text("Start Date")
                            .rounded(.callout) }
                    )
                    .padding(.vertical, 10)
                }
            }
            Button(action: {
                if book.ISBN != nil {
                    fetchStatus = .loading
                    ISBNSearcher().findBook(for: book.ISBN!, success: {
                        book.covers = $0["ISBN:\(book.ISBN!)"]?.cover
                        fetchStatus = .success
                        showingEditSheet = false
                    }, failure: {
                        print($0)
                        fetchStatus = .failure
                        showingEditSheet = false
                    })
                } else {
                    showingEditSheet = false
                }
            }) {
                if fetchStatus == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(10)
                } else {
                    StyledButton(iconName: "checkmark.circle", label: "Update Book", bgColor: Color("SheetButton"))
                }
            }
        }
    }
    
    var deleteBookAlert: Alert {
        Alert(title: Text("Delete Book"), message: Text("Are you sure you want to delete this book? There's no undo."), primaryButton: .destructive(Text("Yes, delete it")) {
            deleteBook()
            
        }, secondaryButton: .cancel())
    }
    
    var deleteBookButton: some View {
        Button(action: {
            showingDeleteAlert = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
    }
    
    func archiveBook() {
        book.archivedAt = Date()
        presentationMode.wrappedValue.dismiss()
    }
    
    func deleteBook() {
        book.deletedAt = Date()
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditBookView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookDetail(book: .constant(bookOne), shelf: BookStore())
            BookDetail(book: .constant(bookThree), shelf: BookStore())
                .preferredColorScheme(.dark)
        }
    }
}
