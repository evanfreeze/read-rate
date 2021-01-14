//
//  SearchView.swift
//  ReadRate
//
//  Created by Evan Freeze on 1/12/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var title: String
    @Binding var author: String
    @Binding var pageCount: String
    
    @State private var searchTerm = ""
    @State private var result: ISBNBook? = nil
    
    var body: some View {
        VStack {
            Text("Search by ISBN").rounded(.title)
            TextField("ISBN", text: $searchTerm)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            Button(action: search) {
                StyledButton(iconName: "magnifyingglass", label: "Search", bgColor: Color("SheetButton"))
            }
            
            if result != nil && searchTerm.count > 0 {
                Divider()
                    .padding()
                Text("Found a match!").rounded(.title2)
                    .padding(.bottom, 6)
                VStack(alignment: .leading) {
                    HStack(spacing: 14) {
                        WebImage(url: result?.cover?.medium ?? "")
                            .scaledToFit()
                            .cornerRadius(6.0)
                            .frame(width: 80, height: 80)
                        VStack(alignment: .leading, spacing: 1.0) {
                            Text(result?.title ?? "Unknown Title")
                                .rounded(.title3)
                            Text(result?.authors.first?.name ?? "Unknown Author")
                                .rounded()
                                .foregroundColor(.secondary)
                                .padding(.bottom, 6.0)
                            HStack(spacing: 1) {
                                Text("\(result?.numberOfPages ?? 0) pages")
                                    .rounded(.caption)
                                    .foregroundColor(.secondary)
                                Text("•")
                                    .rounded(.caption)
                                    .foregroundColor(.secondary)
                                Text(result?.publishDate ?? "Unknown publication date")
                                    .rounded(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button(action: addBook) {
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
            Spacer()
        }
        .padding()
    }
    
    func search() {
        let searcher = ISBNSearcher()
        let normalizedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        searcher.findBook(for: normalizedSearchTerm) {
            result = $0["ISBN:\(normalizedSearchTerm)"]
        }
    }
    
    func addBook() {
        title = result?.title ?? ""
        author = result?.authors.first?.name ?? ""
        pageCount = "\(result?.numberOfPages ?? 0)"
        presentationMode.wrappedValue.dismiss()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(title: .constant(""), author: .constant(""), pageCount: .constant(""))
    }
}
