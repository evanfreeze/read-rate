//
//  WebImage.swift
//  ReadRate
//
//  Created by Evan Freeze on 1/14/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct WebImage: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
                case .failure:
                    Image(systemName: "text.book.closed")
                        .resizable()
                        .foregroundStyle(Color("PlaceholderBook"))
                case .success(let image):
                    image
                        .resizable()
                default:
                    Image(systemName: "text.book.closed")
                        .resizable()
                        .foregroundStyle(Color("PlaceholderBook"))
            }
        }
    }
}

struct WebImage_Previews: PreviewProvider {
    static var previews: some View {
        WebImage(url: "https://daringfireball.net/graphics/logos/")
    }
}
