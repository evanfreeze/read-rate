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
    
    var body: some View {
        HStack(alignment: .center, spacing: 20.0) {
            ProgressCircle(
                progress: book.progressBarFillAmount,
                progressColor: book.progressColor,
                centerContent: book.progressIcon
            )
            VStack(alignment: .leading, spacing: 8.0) {
                VStack(alignment: .leading, spacing: 1.0) {
                    Text(book.title)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                    Text(book.author)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.leading)
                }
                Text(book.progressDescription)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 20.0)
        .background(LinearGradient(colors: [Color.clear, book.progressColor.opacity(0.1)], startPoint: .bottom, endPoint: .topTrailing))
        .background(.background)
        .cornerRadius(30)
    }
}

struct BookRow_v2_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookRow(book: .constant(BookStore.generateRandomSampleBooks()[0]))
                .previewLayout(PreviewLayout.fixed(width: 360, height: 200))
            BookRow(book: .constant(BookStore.generateRandomSampleBooks()[1]))
                .preferredColorScheme(.dark)
                .previewLayout(PreviewLayout.fixed(width: 360, height: 200))
        }
    }
}
