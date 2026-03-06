//
//  EditBookView.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct BookDetail: View {
    @Environment(\.dismiss) var dismiss
    @Binding var book: Book
    @ObservedObject var shelf: BookStore
    
    @State private var editingTargetDate = false
    @State private var editingCurrentPage = false
    @State private var editingRateGoal = false
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var showingGoalSheet = false
    
    @State private var fetchStatus: FetchStatus = .idle
    
    var goalSubtitle: String? {
        if book.readEnoughToday || book.isCompleted || book.isFuture {
            return nil
        } else {
            return "Goal last calculated on \(book.displayLastGoalCalculatedDate)"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    BookHeader(book: book)
                    
                    Card(
                        title: "Today's Goal",
                        content: book.progressDescription,
                        subtitle: goalSubtitle
                    )
                    
                    ExpandableCard(
                        title: "Your Progress",
                        content: "Page \(book.currentPage) of \(book.pageCount) (\(book.completionPercentage.asRoundedPercent()) complete)",
                        isOpen: $editingCurrentPage,
                        openContent: editCurrentPage
                    )
                    .padding(.bottom, 1)
                    
                    switch book.goalMode {
                    case .date:
                        ExpandableCard(
                            title: "Target Date",
                            content: book.targetDate.prettyPrinted(),
                            isOpen: $editingTargetDate,
                            openContent: editTargetDate
                        )
                        .padding(.bottom, 1)
                    case .rate:
                        ExpandableCard(
                            title: "Reading Pace",
                            content: "\(book.rateGoal!) pages per day",
                            isOpen: $editingRateGoal,
                            openContent: editRateGoal
                        )
                        .padding(.bottom, 1)
                    }
                    
                    if book.goalMode == .rate && !book.isCompleted {
                        Card(
                            title: "Estimated Completion Date",
                            content: book.floatingTargetDateAtRateGoal!.prettyPrinted(),
                            subtitle: "Based on \(book.rateGoal!) pages per day"
                        )
                    }
                    
                    if book.isCompleted {
                        Card(
                            title: "Finish Date",
                            content: book.completedAt?.prettyPrinted() ?? "Not completed",
                            subtitle: nil
                        )
                    }
                    
                    HStack(alignment: .center) {
                        Text(ISBNText)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                editButton
                archiveButton
                deleteBookButton
            }
        }
        .alert(isPresented: $showingDeleteAlert) { deleteBookAlert }
        .sheet(isPresented: $showingEditSheet) { editBookSheet }
    }
    
    var ISBNText: String {
        book.ISBN != "" && book.ISBN != nil ? "ISBN: \(book.ISBN!)" : "No ISBN Entered"
    }
    
    var archiveButton: some View {
        Button("Archive Book", systemImage: "archivebox", action: archiveBook)
    }
    
    var editButton: some View {
        Button("Edit Book", systemImage: "pencil", action: { showingEditSheet = true })
    }
    
    var editCurrentPage: some View {
        Group {
            Picker("", selection: $book.currentPage) {
                ForEach(0..<book.pageCount + 1, id: \.self) {
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
                    StyledButton(iconName: "star.circle", label: "Finish Book", bgColor: Color(.tertiarySystemBackground))
                }
                Button(action: {
                    withAnimation {
                        book.currentPage = book.dailyTargets.last?.targetPage ?? book.currentPage
                        editingCurrentPage = false
                    }
                }) {
                    StyledButton(iconName: "checkmark.circle", label: "Today's Goal", bgColor: Color(.tertiarySystemBackground))
                }
            }
        }
    }
    
    var editTargetDate: some View {
        DatePicker(
            "Update your target date",
            selection: $book.targetDate,
            in: book.startDate...,
            displayedComponents: .date
        )
    }
    
    var editRateGoal: some View {
        let rateGoal = Binding<Int>(
            get: {
                book.rateGoal ?? 5
            },
            set: {
                book.rateGoal = $0
            }
        )
        
        return PagesPerDayPicker(selection: rateGoal)
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
        
        let bookCurrentPage = Binding<String>(
            get: {
                "\(book.currentPage)"
            },
            set: { _ in }
        )
        
        let bookGoalMode = Binding<GoalMode>(
            get: {
                book.goalMode
            },
            set: {
                book.mode = $0
            }
        )
        
        let rateGoal = Binding<Int>(
            get: {
                book.rateGoal ?? 5
            },
            set: {
                book.rateGoal = $0
            }
        )
        
        return NavigationView {
            VStack {
                Form {
                    LabeledInput(label: "Title", placeholder: "Book title", value: $book.title)
                        .textInputAutocapitalization(.sentences)
                    
                    LabeledInput(label: "Author", placeholder: "Who wrote the book", value: $book.author)
                        .textInputAutocapitalization(.words)
                    
                    LabeledInput(label: "ISBN (Optional, used to find cover art)", placeholder: "ISBN", value: bookISBN)
                        .keyboardType(.numberPad)
                    
                    LabeledInput(label: "Page Count", placeholder: "Number of pages in the book", value: bookPageCount)
                        .keyboardType(.numberPad)
                    
                    DatePicker(
                        selection: $book.startDate,
                        displayedComponents: .date,
                        label: {
                            Text("Start Date")
                                .font(.callout)
                                .bold()
                        }
                    )
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Goal Type")
                                .rounded(.callout)
                            Text(book.goalMode == .date ? "Target Date" : "Pages Per Day")
                        }
                        Spacer()
                        Button("Edit Reading Goal", systemImage: "chevron.forward", action: showGoalSheet)
                            .labelStyle(.iconOnly)
                            .buttonStyle(.glass)
                            .sheet(isPresented: $showingGoalSheet) {
                                SetGoalScreen(startDate: $book.startDate, targetDate: $book.targetDate, mode: bookGoalMode, hasSetGoal: .constant(true), readingRate: rateGoal, pageCount: bookPageCount, currentPage: bookCurrentPage)
                            }
                    }
                    .padding(.vertical, 10.0)
                }
            }
            .navigationTitle("Edit Book")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel Editing", systemImage: "xmark") {
                        showingEditSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if book.ISBN != nil {
                            fetchStatus = .loading
                            ISBNSearcher().findBook(for: book.ISBN!, success: {
                                book.covers = $0["ISBN:\(book.ISBN!)"]?.cover
                                fetchStatus = .success
                                shelf.setTodaysTargets()
                                showingEditSheet = false
                            }, failure: {
                                print($0)
                                fetchStatus = .failure
                                shelf.setTodaysTargets()
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
                            StyledButton(iconName: "checkmark", label: "Update Book", bgColor: Color("SheetButton"))
                        }
                    }
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
                .foregroundStyle(Color.red)
        }
    }
    
    func archiveBook() {
        book.archivedAt = Date()
        dismiss()
    }
    
    func deleteBook() {
        book.deletedAt = Date()
        dismiss()
    }
    
    func showGoalSheet() {
        showingGoalSheet = true
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
