//
//  EditBookView.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct EditBookView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var book: Book
    
    var body: some View {
        Form {
            Text("You're on page")
            Picker("", selection: $book.currentPage) {
                ForEach(0..<book.pageCount + 1) {
                    Text(String($0)).tag($0)
                }
            }.pickerStyle(WheelPickerStyle())
            DatePicker(
                "You want to finish by",
                selection: $book.targetDate,
                in: book.startDate...,
                displayedComponents: .date
            )
            Button("Update Reading Progress") {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle(book.title)
    }
}

struct EditBookView_Previews: PreviewProvider {
    static var previews: some View {
        EditBookView(book: .constant(BookStore().books[0]))
    }
}
