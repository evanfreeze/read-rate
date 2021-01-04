//
//  IntentHandler.swift
//  SelectedBookIntentsExtension
//
//  Created by Evan Freeze on 1/3/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import Intents

class IntentHandler: INExtension, SelectedBookIntentHandling {
    func resolveParameter(for intent: SelectedBookIntent, with completion: @escaping (BookSelectionResolutionResult) -> Void) {
        
    }
    
    func provideParameterOptionsCollection(for intent: SelectedBookIntent, with completion: @escaping (INObjectCollection<BookSelection>?, Error?) -> Void) {
        let bookOptions: [BookSelection] = BookStore().activeBooks.map { book in
            BookSelection(identifier: book.title, display: book.title)
        }
        
        let collection = INObjectCollection(items: bookOptions)
        
        completion(collection, nil)
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
