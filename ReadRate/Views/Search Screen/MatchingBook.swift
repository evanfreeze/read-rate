//
//  MatchingBook.swift
//  ReadRate
//
//  Created by Evan Freeze on 1/27/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct MatchingBook: View {
    let result: ISBNBook?
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 14) {
                WebImage(url: result?.cover?.medium ?? "")
                    .scaledToFit()
                    .cornerRadius(6.0)
                    .frame(width: 80, height: 80)
                VStack(alignment: .leading, spacing: 1.0) {
                    Text(result?.title ?? "Unknown Title")
                        .rounded(.title3)
                    Text(result?.authors?.first?.name ?? "Unknown Author")
                        .rounded()
                        .foregroundStyle(Color.secondary)
                        .padding(.bottom, 6.0)
                    HStack(spacing: 3) {
                        Text("\(result?.numberOfPages ?? 0) pages")
                            .rounded(.caption)
                            .foregroundStyle(Color.secondary)
                        Text("•")
                            .rounded(.caption)
                            .foregroundStyle(Color.secondary)
                        Text(result?.publishDate ?? "Unknown publication date")
                            .rounded(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("SheetButton"))
        .cornerRadius(20.0)
    }
}

struct MatchingBook_Previews: PreviewProvider {
    static var previews: some View {
        MatchingBook(result: nil, action: {})
    }
}
