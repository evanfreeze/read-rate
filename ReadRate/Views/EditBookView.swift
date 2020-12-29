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

struct EditBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var book: Book
    @ObservedObject var shelf: BookStore
    
    @State private var editingTargetDate = false
    @State private var editingCurrentPage = false
    @State private var actionsOpacity = 0.0
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Progress").font(.title).bold()
                Text("You're on page \(book.currentPage). \(book.progressDescription).")
                    .font(.headline)
                Text("You started the book on \(book.displayStartDate). At your current rate, you'll finish on \(book.displayCompletionTarget)")
                    .font(.headline)
                Text("You're reading at a rate of roughly \(book.pagesPerDay) pages per day.")
                    .font(.headline)
            }
            .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    Button(action: {
                        editingCurrentPage.toggle()
                        if actionsOpacity == 0 {
                            actionsOpacity = 100
                        } else {
                            actionsOpacity = 0
                        }
                    }) {
                        Text(editingCurrentPage ? "Save Progress" : "Update Progress")
                            .blueButtonStyle()
                    }
                    if editingCurrentPage {
                        Group {
                            Text("Select the page you're on now").bold()
                            Picker("", selection: $book.currentPage) {
                                ForEach(0..<book.pageCount + 1) {
                                    Text(String($0)).tag($0)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                        .opacity(actionsOpacity)
                        .animation(.default)
                    }
                }
                
                Group {
                    Button(action: {
                        editingTargetDate.toggle()
                        if actionsOpacity == 0 {
                            actionsOpacity = 100
                        } else {
                            actionsOpacity = 0
                        }
                    }) {
                        Text(editingTargetDate ? "Save Updated Date" : "Change Target Date")
                            .blueButtonStyle()
                    }
                    if editingTargetDate {
                        DatePicker(
                            "Select your target date",
                            selection: $book.targetDate,
                            in: book.startDate...,
                            displayedComponents: .date
                        )
                        .opacity(actionsOpacity)
                    }
                }
            }
            Spacer()
            Button(action: archiveBook) {
                Text("Archive Book")
            }
        }
        .padding()
        .navigationTitle(book.title)
    }
    
    func archiveBook() {
        book.archivedAt = Date()
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditBookView_Previews: PreviewProvider {
    static var previews: some View {
        EditBookView(book: .constant(BookStore().books[0]), shelf: BookStore())
    }
}
