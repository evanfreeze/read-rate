//
//  NowReadingList.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/1/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

struct NowReadingList: View {
    @ObservedObject var bookStore: BookStore
    
    @State var showDetails = false
    @State var isEditing = false
    @State var isAdding = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookStore.books) { index in
                    BookRow(book: self.$bookStore.books[index])
                }
                .onDelete { indexSet in
                    self.bookStore.books.remove(atOffsets: indexSet)
                }
                .onMove { indiciesToMove, destinationIndex in
                    self.bookStore.books.move(fromOffsets: indiciesToMove, toOffset: destinationIndex)
                }
            }
            .onAppear() {
                self.bookStore.setTodaysTargets()
            }
            .navigationBarTitle("Now Reading")
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: { self.isAdding = true }) { Image(systemName: "plus") }
            )
        }
        .sheet(isPresented: $isAdding) {
            AddBookView(bookStore: self.bookStore)
        }
    }
}

struct NowReadingList_Previews: PreviewProvider {
    static var previews: some View {
        NowReadingList(bookStore: BookStore())
    }
}
