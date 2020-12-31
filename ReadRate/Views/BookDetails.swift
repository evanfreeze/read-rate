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
    
    @State private var rotationAngle = Angle(degrees: 0)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title).rounded(.title3)
                    Spacer()
                    
                }
                Text(content).rounded(.body).foregroundColor(.secondary)
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
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(book.title).rounded(.title)
                    Text(book.author).rounded(.title2).foregroundColor(.secondary)
                }
                
                ScrollView {
                    Card(title: "Today's Goal", content: book.progressDescription, withEdit: false) {}
                    
                    VStack {
                        Card(title: "Progress", content: "Page \(book.currentPage) of \(book.pageCount) (\(book.percentComplete) complete)", withEdit: true) {
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
                        Card(title: "Target Completion Date", content: book.displayCompletionTarget, withEdit: true) { editingTargetDate.toggle()
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
                    
                    Card(title: "Start Date", content: book.displayStartDate, withEdit: false) {}
                    
                    if book.completedAt != nil {
                        Card(title: "Finish Date", content: book.displayFinishDate, withEdit: false) {}
                    }
                }
                
                if book.completedAt != nil {
                    HStack {
                        Spacer()
                        Button(action: archiveBook) {
                            StyledButton(iconName: "archivebox", label: "Archive Book", bgColor: Color("BookBG"))
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
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
        Group {
            BookDetail(book: .constant(BookStore().books[0]), shelf: BookStore())
            BookDetail(book: .constant(BookStore().books[0]), shelf: BookStore())
                .preferredColorScheme(.dark)
        }
    }
}