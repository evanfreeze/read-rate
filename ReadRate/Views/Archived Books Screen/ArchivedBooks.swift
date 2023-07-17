//
//  ArchiveView.swift
//  ReadRate
//
//  Created by Evan Freeze on 12/29/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct ArchivedBook: View {
    let book: Book
    @ObservedObject var shelf: BookStore
    
    var body: some View {
        HStack(alignment: .center, spacing: 20.0) {
           CalendarIcon(
               month: book.completedDateForCalendarIcon.0,
               day: book.completedDateForCalendarIcon.1,
               headerColor: book.isCompleted ? .accentColor : .gray
           )
           VStack(alignment: .leading, spacing: 8.0) {
               VStack(alignment: .leading, spacing: 1.0) {
                   Text(book.title)
                       .rounded(.body)
                       .foregroundStyle(Color.primary)
                   Text(book.author)
                       .rounded(.subheadline)
                       .foregroundStyle(Color.secondary)
               }
               Text(book.archivedDaysRead)
                   .rounded(.caption2, bold: false)
                   .foregroundStyle(Color.secondary)
           }
           Spacer(minLength: 0)
           Button(action: { unarchiveBook(book: book) }) {
               Image(systemName: "arrowshape.turn.up.backward.circle.fill")
                   .font(.title3)
           }
       }
       .frame(maxWidth: .infinity)
       .padding(.all, 20.0)
       .background(Color("BookBG"))
       .cornerRadius(20.0)
    }
    
    func unarchiveBook(book: Book) {
        if let found = shelf.books.firstIndex(of: book) {
            shelf.books[found].archivedAt = nil
        }
    }
}

struct NoArchivedBooks: View {
    let title = "No Archived Books"
    let description = """
    Any book you archive will appear here, along with the date you completed it.

    You'll also be able to unarchive any archived book from this screen.
    """
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                Text(title).rounded(.title2)
                    .padding(.bottom, 4)
                Text(description).rounded(.body, bold: false).foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 45)
        }
        .frame(maxWidth: .infinity)
        .background(Color("BookBG"))
        .cornerRadius(20)
        .padding(.all, 20.0)
    }
}

struct MonthHeader: View {
    var name: String
    var count: Int
    
    var body: some View {
            HStack(alignment: .firstTextBaseline) {
            Text(name).rounded(.title2)
            Spacer()
            Text("\(count) \(count == 1 ? "book" : "books")")
                .rounded(.body)
                .foregroundStyle(Color.secondary)
        }
        .padding(.top)
    }
}

struct ArchivedBooks: View {
    @ObservedObject var shelf: BookStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12.0) {
                if shelf.archivedBooks.count > 0 {
                        ForEach(monthsWithBooks, id:\.self) { month in
                            Section(header: MonthHeader(name: month, count: getBooksCompletedIn(month).count)) {
                                ForEach(getBooksCompletedIn(month)) { book in
                                    ArchivedBook(book: book, shelf: shelf)
                                }
                            }
                        }
                } else {
                    NoArchivedBooks()
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle("Archived Books")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var monthsWithBooks: [String] {
        var months = [String]()
        for book in shelf.archivedBooks.sorted(by: { (a, b) -> Bool in
            a.completedAt ?? Date() > b.completedAt ?? Date()
        }) {
            if !months.contains(book.completedMonthYear) {
                months.append(book.completedMonthYear)
            }
        }
        return months
    }
    
    func getBooksCompletedIn(_ month: String) -> [Book] {
        shelf.archivedBooks.filter({ $0.completedMonthYear == month }).sorted { (a, b) -> Bool in
            a.completedAt ?? Date() > b.completedAt ?? Date()
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ArchivedBooks(shelf: BookStore())
            ArchivedBooks(shelf: BookStore())
                .preferredColorScheme(.dark)
        }
    }
}
