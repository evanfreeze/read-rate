//
//  BookRow_v2.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/15/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct BookRow: View {
    @Binding var book: Book
    
    let progressLength: CGFloat = 180.0
    let progressHeight: CGFloat = 10.0
    
    var pageToReadTo: String {
        String(book.dailyTargets.last?.targetPage ?? book.pageCount)
    }
    
    var progressSubtext: String {
        if (book.currentPage == book.pageCount) {
            return "You finished the book — congrats!"
        } else if (book.readToday) {
            return "You've read enough today to stay on track"
        } else {
            return "Read to page \(pageToReadTo) today to stay on track"
        }
    }
    
    var progressColor: Color {
        if (book.currentPage == book.pageCount) {
            return .yellow
        } else if (book.readToday) {
            return .green
        } else {
            return .blue
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            ZStack {
                Circle()
                    .frame(width: 52.0, height: 52.0)
                    .foregroundColor(progressColor)
                if book.currentPage == book.pageCount {
                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
                        .font(Font.system(.body).bold())
                } else if book.readToday {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(Font.system(.body).bold())
                } else {
                    Text(book.pagesRemainingToday)
                        .foregroundColor(.white)
                        .font(Font.system(.body).bold())
                }
            }
            VStack(alignment: .leading, spacing: 6.0) {
                VStack(alignment: .leading, spacing: 2.0) {
                    Text(book.title)
                        .font(Font.system(.title3).bold())
                        .foregroundColor(.primary)
                    Text(book.author)
                        .font(Font.system(.subheadline).bold())
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 6.0) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(width: progressLength, height: progressHeight)
                            .foregroundColor(.gray).opacity(0.3)
                        Capsule()
                            .frame(width: CGFloat(getProgressBarFillAmount() * Double(progressLength)), height: progressHeight)
                            .foregroundColor(progressColor)
                    }
                    Text(book.percentComplete)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                Text(progressSubtext)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding([.top, .bottom], 12.0)
    }
    
    func getProgressBarFillAmount() -> Double {
        let minAmount = 0.06
        
        if book.getCompletionPercentage() < minAmount {
            return minAmount
        } else {
            return book.getCompletionPercentage()
        }
    }
}

struct BookRow_v2_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookRow(book: .constant(BookStore().books[0])).previewLayout(PreviewLayout.fixed(width: 360, height: 200))
            BookRow(book: .constant(BookStore().books[1])).previewLayout(PreviewLayout.fixed(width: 360, height: 300)).environment(\.colorScheme, .dark)
        }
    }
}
