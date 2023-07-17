//
//  SearchView.swift
//  ReadRate
//
//  Created by Evan Freeze on 1/12/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

enum FetchStatus {
    case idle, loading, success, failure
}

struct IdleView: View {
    var body: some View {
        Divider().padding(.bottom)
    }
}

struct LoadingView: View {
    var body: some View {
        Divider().padding()
        Text("Searching...").rounded(.title2)
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
    }
}

struct SuccessView: View {
    let result: ISBNBook?
    let action: () -> Void
    
    var body: some View {
        Divider()
            .padding()
        Text("Found a match!").rounded(.title2)
            .padding(.bottom, 6)
        MatchingBook(result: result, action: action)
    }
}

struct FailureView: View {
    let errorText: String
    
    var body: some View {
        Divider().padding()
        Text("Hmm 🤔").rounded(.title2)
            .padding(.bottom, 6)
        Text(errorText)
            .rounded(.subheadline, bold: false)
            .foregroundColor(.secondary)
    }
}

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var title: String
    @Binding var author: String
    @Binding var pageCount: String
    @Binding var isbn: String
    
    @State private var searchTerm = ""
    @State private var result: ISBNBook? = nil
    @State private var status: FetchStatus = .idle
    @State private var errorText = ""
    @FocusState private var focused
    
    var body: some View {
        VStack {
            Text("Search by ISBN").rounded(.title)
            TextField("ISBN", text: $searchTerm)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .focused($focused)
            Button(action: search) {
                StyledButton(iconName: "magnifyingglass", label: "Search", bgColor: Color("SheetButton"))
            }
            Text("Powered by OpenLibrary.org")
                .rounded(.footnote, bold: false)
                .foregroundColor(.secondary)
                .padding(8)
            
            switch status {
            case .idle:
                IdleView()
            case .loading:
                LoadingView()
            case .success:
                SuccessView(result: result, action: addBook)
            case .failure:
                FailureView(errorText: errorText)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            focused = true
        }
    }
    
    func search() {
        status = .loading
        let searcher = ISBNSearcher()
        let normalizedSearchTerm = searchTerm.cleanedNumeric()
        searcher.findBook(for: normalizedSearchTerm, success: {
            result = $0["ISBN:\(normalizedSearchTerm)"]
            status = .success
        }, failure: {
            errorText = $0
            status = .failure
        })
    }
    
    func addBook() {
        title = result?.title ?? ""
        author = result?.authors?.first?.name ?? ""
        pageCount = "\(result?.numberOfPages ?? 0)"
        isbn = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        presentationMode.wrappedValue.dismiss()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(title: .constant(""), author: .constant(""), pageCount: .constant(""), isbn: .constant(""))
    }
}
