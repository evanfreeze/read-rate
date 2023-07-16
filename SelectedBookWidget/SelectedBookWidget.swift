//
//  SelectedBookWidget.swift
//  SelectedBookWidget
//
//  Created by Evan Freeze on 1/3/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func getBooksForWidgetFamily(for family: WidgetFamily, withPlaceholders: Bool) -> [Book] {
        var books = [Book]()
        let store = BookStore()
        
        let firstBookOrSample = [store.activeBooks.first ?? BookStore.generateRandomSampleBooks().first!]
        
        switch family {
        case .systemSmall:
            books = firstBookOrSample
        case .systemMedium:
            if store.activeBooks.count >= 2 {
                books = Array(store.activeBooks.prefix(2))
            } else {
                books += store.activeBooks
                if withPlaceholders {
                    let placeholdersNeeded = 2 - store.activeBooks.count
                    books += BookStore.generateRandomSampleBooks().prefix(placeholdersNeeded)
                }
            }
        case .systemLarge:
            if store.activeBooks.count >= 4 {
                books = Array(store.activeBooks.prefix(4))
            } else {
                books += store.activeBooks
                if withPlaceholders {
                    let placeholdersNeeded = 4 - store.activeBooks.count
                    books += BookStore.generateRandomSampleBooks().prefix(placeholdersNeeded)
                }
            }
        case .systemExtraLarge:
            if store.activeBooks.count >= 4 {
                books = Array(store.activeBooks.prefix(4))
            } else {
                books += store.activeBooks
                if withPlaceholders {
                    let placeholdersNeeded = 4 - store.activeBooks.count
                    books += BookStore.generateRandomSampleBooks().prefix(placeholdersNeeded)
                }
            }
        case .accessoryCircular:
            books = firstBookOrSample
        case .accessoryRectangular:
            books = firstBookOrSample
        case .accessoryInline:
            books = store.activeBooks
        @unknown default:
            books = store.activeBooks
        }
        
        return books
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let booksForPlaceholder = getBooksForWidgetFamily(for: context.family, withPlaceholders: true)
        return SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: booksForPlaceholder)
    }

    func getSnapshot(for configuration: SelectedBookIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        var selectedBooks = [Book]()
        
        if let selectedTitles = configuration.selectedBook?.map({ $0.displayString }) {
            selectedBooks = BookStore().books.filter({ selectedTitles.contains($0.title) })
        } else {
            selectedBooks = getBooksForWidgetFamily(for: context.family, withPlaceholders: true)
        }
        
        let entry = SimpleEntry(date: Date(), selectedDetails: configuration.details, selectedBooks: selectedBooks)
        
        completion(entry)
    }

    func getTimeline(for configuration: SelectedBookIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var selectedBooks = [Book]()
        let bookStore = BookStore()
        bookStore.setTodaysTargets()
        
        if let legacyBook = configuration.selectedBook as Any as? BookSelection  {
            if let book = bookStore.activeBooks.first(where: { legacyBook.displayString == $0.title }) {
                selectedBooks.append(book)
            }
        } else {
            if let selectedTitles = configuration.selectedBook?.map({ $0.displayString }) {
                for title in selectedTitles {
                    let book = bookStore.activeBooks.first(where: { title == $0.title })!
                    selectedBooks.append(book)
                }
            } else {
                selectedBooks = getBooksForWidgetFamily(for: context.family, withPlaceholders: false)
            }
        }
        
        let entry = SimpleEntry(date: Date(), selectedDetails: configuration.details, selectedBooks: selectedBooks.filter { book in !book.isFuture })
        let tomorrowAtMidnight = Calendar.current.startOfDay(for: Date()).advanced(by: 60*60*24+60)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrowAtMidnight))
        
        completion(timeline)
    }
}

func getWidgetDetails(for detailsEnum: WidgetDetails, book: Book) -> String {
    switch detailsEnum {
    case .currentPage:
        return "You're on page \(book.currentPage)"
    case .percentage:
        return "You've read \(book.completionPercentage.asRoundedPercent())"
    case .todaysTarget:
        return book.progressDescriptionShort
    case .pagesLeft:
        return "\(book.displayPagesRemainingToday) pages left today"
    case .unknown:
        return book.progressDescriptionShort
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let selectedDetails: WidgetDetails
    let selectedBooks: [Book]
}

struct SquareBookView: View {
    let book: Book
    let selectedDetails: WidgetDetails
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                ProgressCircle(
                    progress: book.progressBarFillAmount,
                    progressColor: book.progressColor,
                    centerContent: book.progressIcon
                )
                Spacer()
                Text(book.title)
                    .rounded(.subheadline)
                Text(book.author)
                    .rounded(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 1.0)
                Text(getWidgetDetails(for: selectedDetails, book: book))
                    .rounded(.caption2, bold: false)
                    .foregroundColor(.secondary)
                    .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
            }
            Spacer(minLength: 0)
        }
    }
}

struct RowBookView: View {
    let book: Book
    let selectedDetails: WidgetDetails
    
    var body: some View {
        HStack(spacing: 20) {
            ProgressCircle(
                progress: book.progressBarFillAmount,
                progressColor: book.progressColor,
                centerContent: book.progressIcon
            )
            VStack(alignment: .leading, spacing: 4.0) {
                VStack(alignment: .leading) {
                    Text(book.title)
                        .rounded(.subheadline)
                    Text(book.author)
                        .rounded(.caption)
                        .foregroundColor(.secondary)
                }
                Text(getWidgetDetails(for: selectedDetails, book: book))
                    .rounded(.caption2, bold: false)
                    .foregroundColor(.secondary)
                    .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
            }
            Spacer(minLength: 0)
        }
    }
}

struct AccessoryInlineView: View {
    let books: [Book]
    
    var body: some View {
        let (pageCount, bookCount) = getPagesInBooksRemaining(in: books)
        let pageWord = pageCount == 1 ? "page" : "pages"
        let bookWord = bookCount == 1 ? "book" : "books"
        
        if (pageCount > 0) {
            return Text("📖 \(pageCount) \(pageWord) in \(bookCount) \(bookWord)")
        }
        return Text("☑️ Read enough")
    }
    
    func getPagesInBooksRemaining(in books: [Book]) -> (Int, Int) {
        let pageCounts = books.map{
            (book) -> Int in
            return book.readEnoughToday ? 0 : book.pagesRemainingToday
        }
        let bookCount = books.filter{
            (book) -> Bool in
            return !book.readEnoughToday
        }.count
        return (pageCounts.reduce(0, +), bookCount)
    }
}

struct AccessoryCircularView: View {
    let book: Book
    
    var body: some View {
        ProgressCircle(
            progress: book.progressBarFillAmount,
            progressColor: book.progressColor,
            centerContent: book.progressIcon
        )
    }
}

struct AccessoryRectangleView: View {
    let book: Book
    let selectedDetails: WidgetDetails
    
    var body: some View {
        HStack {
            ProgressView(value: book.progressBarFillAmount, total: 1.0) {
                book.progressIcon
            }
                .progressViewStyle(.circular)
                .frame(width: 40, height: 40)
            
            
            VStack(alignment: .leading) {
                Text(book.title).rounded().lineSpacing(-2).lineLimit(2)
                Text(getWidgetDetails(for: selectedDetails, book: book)).font(.footnote).rounded().lineLimit(1).truncationMode(.tail)
            }
            Spacer(minLength: 0)
        }
    }
}

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct SelectedBookWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SquareBookView(
                    book: entry.selectedBooks.first!,
                    selectedDetails: entry.selectedDetails
                )
                .padding()
            case .accessoryInline:
                AccessoryInlineView(books: entry.selectedBooks)
            case .accessoryCircular:
                AccessoryCircularView(book: entry.selectedBooks.first!)
            case .accessoryRectangular:
                AccessoryRectangleView(book: entry.selectedBooks.first!, selectedDetails: entry.selectedDetails)
            default:
                VStack(spacing: 1.0) {
                    Spacer()
                    ForEach(entry.selectedBooks) { book in
                        RowBookView(book: book, selectedDetails: entry.selectedDetails)
                        if book != entry.selectedBooks.last! {
                            Spacer()
                            Divider()
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }.widgetBackground(backgroundView: Color("BookBG"))
    }
}

@main
struct SelectedBookWidget: Widget {
    let kind: String = "SelectedBookWidget"
    let enableLockScreenWidgets = false
    
    let getWidgetFamilies: () -> [WidgetFamily] = {
        let families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
        if #available(iOSApplicationExtension 16.0, *) {
            let accessoryFamilies: [WidgetFamily] = [.accessoryInline, .accessoryCircular, .accessoryRectangular]
            return families + accessoryFamilies
        } else {
            return families
        }
    }

    var body: some WidgetConfiguration {
            IntentConfiguration(kind: kind, intent: SelectedBookIntent.self, provider: Provider()) { entry in
                SelectedBookWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("Book Progress")
            .description("Track a book's progress and choose which information appears")
            .supportedFamilies(getWidgetFamilies())
            .contentMarginsDisabled()
    }
}

struct SelectedBookWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookTwo]))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookThree, bookTwo]))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookThree, bookTwo, bookOne, bookFour]))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            if #available(iOSApplicationExtension 16.0, *) {
                SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookOne]))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookOne]))
                    .previewContext(WidgetPreviewContext(family: .accessoryInline))
                
                SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookOne]))
                    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            }

        }
    }
}
