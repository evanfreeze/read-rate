//
//  ForEach.swift
//  ReadRate
//
//  Created by Evan Freeze on 6/6/20.
//  Copyright © 2020 Evan Freeze. All rights reserved.
//

import SwiftUI

public extension ForEach where Content: View {
    init<Base: RandomAccessCollection>(
        _ base: Base,
        @ViewBuilder content: @escaping (Base.Index) -> Content
    )
    where Data == IndexedCollection<Base>, Base.Element: Identifiable, ID == Base.Element.ID {
        self.init(IndexedCollection(base), id: \.element.id) {
              index, _ in content(index)
        }
    }
}
