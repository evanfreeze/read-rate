//
//  App.swift
//  ReadRate
//
//  Created by Evan Freeze on 7/17/23.
//  Copyright © 2023 Evan Freeze. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct ReadRateApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var bookStore = BookStore()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NowReadingList(bookStore: bookStore)
                    .tabItem {
                        Label("Now Reading", systemImage: "books.vertical")
                    }
                ArchivedBooks(shelf: bookStore)
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                bookStore.readBooksAndSyncFromJSON()
                bookStore.setTodaysTargets()
            } else {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
