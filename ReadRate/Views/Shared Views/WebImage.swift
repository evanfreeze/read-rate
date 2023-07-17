//
//  WebImage.swift
//  ReadRate
//
//  Created by Evan Freeze on 1/14/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct WebImage: View {
    private enum LoadingState {
        case loading, succeeded, failed
    }
    
    private class ImageLoader: ObservableObject {
        var data = Data()
        var state: LoadingState = .loading
        
        init(url: String) {
            guard let parsedUrl = URL(string: url) else {
                self.state = .failed
                return
            }
            
            URLSession.shared.dataTask(with: parsedUrl) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .succeeded
                } else {
                    self.state = .failed
                }
                
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }
    
    @StateObject private var loader: ImageLoader
    var failureImage: Image
    
    init(url: String, failureImage: Image = Image(systemName: "text.book.closed")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.failureImage = failureImage
    }
    
    var body: some View {
        Group {
            switch loader.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                
            case .failed:
                failureImage
                    .resizable()
                    .foregroundColor(Color(.secondarySystemFill))
            default:
                if let image = UIImage(data: loader.data) {
                    Image(uiImage: image).resizable()
                } else {
                    failureImage
                        .resizable()
                        .foregroundColor(Color(.secondarySystemFill))
                }
            }
        }
    }
}

struct WebImage_Previews: PreviewProvider {
    static var previews: some View {
        WebImage(url: "https://daringfireball.net/graphics/logos/")
    }
}
