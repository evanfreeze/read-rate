//
//  BookDetails.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/3/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct BookDetails: View {
    
    @Binding var book: Book
    
    @State var isEditing = false

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4.0) {
                    Text("Reading \(book.pagesPerDay) pages per day").font(.headline)
                    if (book.readToday) {
                        Text("Nice! You've read enough of this book today to stay on track")
                            .font(.subheadline)
                    } else {
                        Text("Read to at least page \(book.nextStoppingPage) today to stay on track")
                            .font(.subheadline)
                    }
                }
                Spacer()
            }.padding()

            Spacer()
                .frame(height: 30.0)
            Group {
                InfoRow(label: "Current Page", value: "\(Int(book.currentPage))")
                InfoRow(label: "Total Pages", value: "\(Int(book.pageCount))")
                InfoRow(label: "Target Completion", value: "\(book.targetDate.description)")
                InfoRow(label: "Today's target", value: "\(book.todaysTarget)")
                InfoRow(label: "Today's Target Last Updated", value: "\(String(describing: book.todaysTargetLastUpdated))")
            }
            
            Spacer()
            Button("Edit Book Details", action: onEdit)
        }
        .navigationBarTitle(book.title)
        .sheet(isPresented: $isEditing, content: {
            EditBookView(book: self.$book)
        })
    }
    
    func onEdit() -> Void {
        self.isEditing = true
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        Group {
            HStack {
                Text(label)
                    .fontWeight(.medium)
                Spacer()
                Text(value).foregroundColor(.blue).fontWeight(.medium)
                
            }.padding()
            Divider()
                .frame(height: 1.0).padding(.leading).padding(.trailing)
        }
    }
}

struct BookDetails_Previews: PreviewProvider {
    static var previews: some View {
        BookDetails(book: .constant(BookStore().books[0]))
    }
}
