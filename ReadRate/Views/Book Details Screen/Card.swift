//
//  Card.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/12/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct ExpandableCard<T: View>: View {
    let title: String
    let content: String
    var isOpen: Binding<Bool>
    let openContent: T
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isOpen.wrappedValue.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center) {
                            Text(title).rounded(.title3).foregroundColor(.primary)
                            Spacer()
                        }
                        Text(content).rounded(.body).foregroundColor(.secondary)
                    }
                    
                    Spacer(minLength: 1)
                    
                    Image(systemName: "chevron.forward")
                        .font(.headline)
                        .rotationEffect(Angle(degrees: isOpen.wrappedValue ? 90.0 : 0.0))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .padding(.horizontal, 20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
            
            VStack {
                if isOpen.wrappedValue {
                    openContent
                }
            }
            
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20.0)
    }
}

struct Card: View {
    let title: String
    let content: String
    let subtitle: String?
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center) {
                        Text(title).rounded(.title3)
                        Spacer()
                    }
                    Text(content).rounded(.body).foregroundColor(.secondary)
                    if subtitle != nil {
                        Divider()
                            .padding(.top, 8)
                        Text(subtitle!)
                            .rounded(.caption2, bold: false)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                Spacer(minLength: 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .padding(.horizontal, 20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
        }
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        CardList()
    }
    
    struct CardList: View {
        @State var isOpen = false
        
        var body: some View {
            VStack {
                Card(title: "Some info in a card", content: "This is the content", subtitle: "A subtitle!")
                    .padding(.vertical)
                ExpandableCard(title: "Some info in a card", content: "This is the content", isOpen: $isOpen, openContent: content)
            }
        }
        
        var content: some View {
            Text("Hey this is the expanded content!")
        }
    }
}
