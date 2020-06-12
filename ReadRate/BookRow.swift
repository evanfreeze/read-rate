//
//  BookRow.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/2/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct BookRow: View {
    @Binding var book: Book
    
    var body: some View {
        NavigationLink(destination: BookDetails(book: $book)) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6.0) {
                    VStack(alignment: .leading, spacing: 1.0) {
                        Text(book.title)
                            .fontWeight(.semibold)
                        Text(book.author).font(.caption).fontWeight(.medium).foregroundColor(.gray)
                    }
                    HStack {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .frame(width: 200.0, height: 10.0)
                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.903))
                            Capsule()
                                .frame(width: CGFloat(book.getCompletionPercentage() * 200.0), height: 10.0)
                                .foregroundColor(book.readToday ? .green : .blue)
                        }
                        Text(book.percentComplete)
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                }
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 40.0, height: 40.0)
                        .foregroundColor(book.readToday ? .green : .blue)
                    
                    if book.readToday {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(Font.system(.body).bold())
                    } else {
                        Text(book.pagesPerDay)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                }
            }
            .padding(.vertical, 14.0)
        }
    }
}

struct BookRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookRow(book: .constant(BookStore().books[0])).previewLayout(PreviewLayout.fixed(width: 320, height: 70))
            BookRow(book: .constant(BookStore().books[1])).previewLayout(PreviewLayout.fixed(width: 320, height: 70))
        }
    }
}
