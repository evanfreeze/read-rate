//
//  EditBookView.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct Card: View {
    let title: String
    let content: String
    let withEdit: Bool
    let subtitle: String?
    let callback: () -> Void
    
    @State private var rotationAngle = Angle(degrees: 0)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    Text(title).rounded(.title3)
                    Spacer()
                }
                Text(content).rounded(.body).foregroundColor(.secondary)
                if subtitle != nil {
                    Divider()
                        .padding(.top, 8)
                    Text(subtitle!)
                        .rounded(.caption2, bold: false)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            Spacer(minLength: 1)
            if withEdit {
                Button(action: {
                    if rotationAngle.degrees == 0 {
                        rotationAngle.degrees += 90
                    } else {
                        rotationAngle.degrees = 0
                    }
                    callback()
                }) {
                    Image(systemName: "chevron.forward")
                        .font(.headline)
                        .rotationEffect(rotationAngle)
                        .animation(.easeInOut, value: true)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding(.horizontal, 20)
        .background(Color("BookBG"))
        .cornerRadius(20)
    }
}

struct BookDetail: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var book: Book
    @ObservedObject var shelf: BookStore
    
    @State private var editingTargetDate = false
    @State private var editingCurrentPage = false
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var goalSubtitle: String? {
        if book.readToday || book.completedAt != nil {
            return nil
        } else {
            return "Goal last calculated at \(book.displayLastGoalCalculatedDate)"
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(book.title).rounded(.title)
                    Text(book.author).rounded(.title2).foregroundColor(.secondary)
                }
                
                ScrollView {
                    Card(title: "Today's Goal", content: book.progressDescription, withEdit: false, subtitle: goalSubtitle) {}
                    
                    VStack {
                        Card(title: "Progress", content: "Page \(book.currentPage) of \(book.pageCount) (\(book.percentComplete) complete)", withEdit: true, subtitle: nil) {
                            editingCurrentPage.toggle()
                        }
                        .shadow(radius: editingCurrentPage ? 3.0 : 0.0)
                        
                        if editingCurrentPage {
                            Group {
                                Picker("", selection: $book.currentPage) {
                                    ForEach(0..<book.pageCount + 1) {
                                        Text(String($0)).tag($0)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                Button(action: {
                                    book.currentPage = book.pageCount
                                    editingCurrentPage = false
                                }) {
                                    StyledButton(iconName: "checkmark.circle", label: "Mark Complete", bgColor: Color("BookBG"))
                                }
                            }
                            .padding(.bottom, 10.0)
                        }
                    }
                    .background(Color("AltBG"))
                    .cornerRadius(20.0)
                    
                    VStack {
                        Card(title: "Target Completion Date", content: book.displayCompletionTarget, withEdit: true, subtitle: nil) { editingTargetDate.toggle()
                        }
                        .shadow(radius: editingTargetDate ? 3.0 : 0.0)
                        
                        if editingTargetDate {
                            DatePicker(
                                "Update your target date",
                                selection: $book.targetDate,
                                in: book.startDate...,
                                displayedComponents: .date
                            )
                            .padding([.horizontal, .bottom])
                            .padding(.top, 6.0)
                        }
                    }
                    .background(Color("AltBG"))
                    .cornerRadius(20.0)
                    
                    Card(title: "Start Date", content: book.displayStartDate, withEdit: false, subtitle: nil) {}
                    
                    if book.completedAt != nil {
                        Card(title: "Finish Date", content: book.displayFinishDate, withEdit: false, subtitle: nil) {}
                    }
                }
                
                HStack {
                    Spacer(minLength: 0)
                    Button(action: archiveBook) {
                        StyledButton(iconName: "archivebox", label: "Archive", bgColor: Color("BookBG"))
                    }
                    Button(action: { showingEditSheet = true }) {
                        StyledButton(iconName: "pencil.circle", label: "Edit", bgColor: Color("BookBG"))
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            showingDeleteAlert = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        })
        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("Delete Book"), message: Text("Are you sure you want to delete this book? There's no undo."), primaryButton: .destructive(Text("Yes, delete it")) {
                deleteBook()
                
            }, secondaryButton: .cancel())
        }
        .sheet(isPresented: $showingEditSheet) {
            VStack {
                Form {
                    Text("Edit Book")
                        .rounded(.title2)
                    LabeledInput(label: "Title", placeholder: "The name of the book", value: $book.title)
                    LabeledInput(label: "Author", placeholder: "Who wrote the book", value: $book.author)
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
                showingEditSheet = false
            }) {
                StyledButton(iconName: "checkmark.circle", label: "Update Book", bgColor: Color("BookBG"))
            }
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
            BookDetail(book: .constant(BookStore().books[0]), shelf: BookStore())
            BookDetail(book: .constant(BookStore().books[0]), shelf: BookStore())
                .preferredColorScheme(.dark)
        }
    }
}
