//
//  EditBookView.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

extension Text {
    func blueButtonStyle() -> some View {
        self.fontWeight(.bold)
            .padding()
            .frame(maxWidth: CGFloat.infinity)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct Card: View {
    let title: String
    let content: String
    let withEdit: Bool
    let callback: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).rounded(.title3)
                Spacer()
                if withEdit {
                    Button(action: callback, label: {
                        Image(systemName: "pencil.circle")
                    })
                }
            }
            Text(content).rounded(.body).foregroundColor(.secondary)
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
    @State private var pagePickerOpacity = 0.0
    @State private var datePickerOpacity = 0.0
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(book.title).rounded(.title)
                    Text(book.author).rounded(.title2).foregroundColor(.secondary)
                }
                
                Card(title: "Today's Goal", content: book.progressDescription, withEdit: false) {}
                
                Card(title: "Progress", content: "You're on page \(book.currentPage) of \(book.pageCount) (\(book.percentComplete) complete)", withEdit: true) {
                    editingCurrentPage.toggle()
                }
                if editingCurrentPage {
                    Group {
                        Picker("", selection: $book.currentPage) {
                            ForEach(0..<book.pageCount + 1) {
                                Text(String($0)).tag($0)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                }
                
                Card(title: "Target Completion Date", content: book.displayCompletionTarget, withEdit: true) { editingTargetDate.toggle()
                }
                if editingTargetDate {
                    DatePicker(
                        "Update your target date",
                        selection: $book.targetDate,
                        in: book.startDate...,
                        displayedComponents: .date
                    )
                }
                
                Card(title: "Start Date", content: book.displayStartDate, withEdit: false) {}
                
                Card(title: "Finish Date", content: book.displayFinishDate, withEdit: false) {}
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: archiveBook) {
                        StyledButton(iconName: "archivebox", label: "Archive Book")
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func archiveBook() {
        book.archivedAt = Date()
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditBookView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetail(book: .constant(BookStore().books[0]), shelf: BookStore())
    }
}
