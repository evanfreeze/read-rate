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
    let shelf = BookStore()
    
    func getBooksForWidgetFamily(for family: WidgetFamily, withPlaceholders: Bool) -> [Book] {
        var booksForWidget = [Book]()
        
        let firstBookOrSample = [shelf.activeBooks.first ?? BookStore.generateRandomSampleBooks().first!]
        
        switch family {
        case .systemSmall:
            booksForWidget = firstBookOrSample
        case .systemMedium:
            if shelf.activeBooks.count >= 2 {
                booksForWidget = Array(shelf.activeBooks.prefix(2))
            } else {
                booksForWidget += shelf.activeBooks
                if withPlaceholders {
                    let placeholdersNeeded = 2 - shelf.activeBooks.count
                    booksForWidget += BookStore.generateRandomSampleBooks().prefix(placeholdersNeeded)
                }
            }
        case .systemLarge:
            if shelf.activeBooks.count >= 4 {
                booksForWidget = Array(shelf.activeBooks.prefix(4))
            } else {
                booksForWidget += shelf.activeBooks
                if withPlaceholders {
                    let placeholdersNeeded = 4 - shelf.activeBooks.count
                    booksForWidget += BookStore.generateRandomSampleBooks().prefix(placeholdersNeeded)
                }
            }
        case .systemExtraLarge:
            if shelf.activeBooks.count >= 4 {
                booksForWidget = Array(shelf.activeBooks.prefix(4))
            } else {
                booksForWidget += shelf.activeBooks
                if withPlaceholders {
                    let placeholdersNeeded = 4 - shelf.activeBooks.count
                    booksForWidget += BookStore.generateRandomSampleBooks().prefix(placeholdersNeeded)
                }
            }
        case .accessoryCircular:
            booksForWidget = firstBookOrSample
        case .accessoryRectangular:
            booksForWidget = firstBookOrSample
        case .accessoryInline:
            booksForWidget = shelf.activeBooks
        @unknown default:
            booksForWidget = shelf.activeBooks
        }
        
        return booksForWidget
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let booksForPlaceholder = getBooksForWidgetFamily(for: context.family, withPlaceholders: true)
        return SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: booksForPlaceholder)
    }

    func getSnapshot(for configuration: SelectedBookIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        var selectedBooks = [Book]()
        
        if let selectedTitles = configuration.selectedBook?.map({ $0.displayString }) {
            selectedBooks = shelf.books.filter({ selectedTitles.contains($0.title) })
        } else {
            selectedBooks = getBooksForWidgetFamily(for: context.family, withPlaceholders: true)
        }
        
        let entry = SimpleEntry(date: Date(), selectedDetails: configuration.details, selectedBooks: selectedBooks)
        
        completion(entry)
    }

    func getTimeline(for configuration: SelectedBookIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        shelf.readBooksAndSyncFromJSON()
        shelf.setTodaysTargets()
        var selectedBooks = [Book]()
        
        if let legacyBook = configuration.selectedBook as Any as? BookSelection  {
            if let book = shelf.activeBooks.first(where: { legacyBook.displayString == $0.title }) {
                selectedBooks.append(book)
            }
        } else {
            if let selectedTitles = configuration.selectedBook?.map({ $0.displayString }) {
                for title in selectedTitles {
                    if let book = shelf.activeBooks.first(where: { title == $0.title }) {
                        selectedBooks.append(book)
                    }
                }
            } else {
                selectedBooks = getBooksForWidgetFamily(for: context.family, withPlaceholders: false)
            }
        }
        
        let firstEntry = SimpleEntry(date: Date(), selectedDetails: configuration.details, selectedBooks: selectedBooks)

        let tomorrowAtMidnight = Calendar.current.startOfDay(for: Date()).advanced(by: 60*60*24+30)
        let lastEntry = SimpleEntry(date: tomorrowAtMidnight, selectedDetails: configuration.details, selectedBooks: selectedBooks)
        
        let timeline = Timeline(entries: [firstEntry, lastEntry], policy: .atEnd)
        
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
                    .foregroundStyle(Color.secondary)
                    .padding(.bottom, 1.0)
                Text(getWidgetDetails(for: selectedDetails, book: book))
                    .rounded(.caption2, bold: false)
                    .foregroundStyle(Color.secondary)
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
                        .foregroundStyle(Color.secondary)
                }
                Text(getWidgetDetails(for: selectedDetails, book: book))
                    .rounded(.caption2, bold: false)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
            }
            Spacer(minLength: 0)
        }
    }
}

struct AccessoryInlineView: View {
    let books: [Book]
    
    var body: some View {
        let (pageCount, bookCount) = getPagesInBooksRemaining(in: books.filter { !$0.isFuture })
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
        .padding(4.25)
        .background(.thinMaterial)
        .clipShape(Circle())
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
                Text(book.title).bold().rounded().lineLimit(2).lineSpacing(-4).widgetAccentable().padding(.bottom, 0.1)
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

extension View { 
    func widgetPadding() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return padding(4)
        } else {
            return padding()
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
                .widgetPadding()
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
                .widgetPadding()
            }
        }.widgetBackground(backgroundView: Color(.systemBackground))
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
