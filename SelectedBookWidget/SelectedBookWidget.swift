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
    
    func getFirstBook(withPlaceholders: Bool) -> [Book] {
        if let firstBook = shelf.activeBooks.first {
            return [firstBook]
        } else if withPlaceholders {
            return [BookStore.generateRandomSampleBooks().first!]
        } else {
            return []
        }
    }
    
    func getBooksForWidgetFamily(for family: WidgetFamily, withPlaceholders: Bool) -> [Book] {
        var booksForWidget = [Book]()
        
        let firstBookOrSample = getFirstBook(withPlaceholders: withPlaceholders)
        
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
            selectedBooks = getBooksForWidgetFamily(for: context.family, withPlaceholders: context.isPreview)
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
    let book: Book?
    let selectedDetails: WidgetDetails
    
    var body: some View {
        if let book = book {
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
        } else {
            VStack(alignment: .center) {
                Spacer()
                Image(systemName: "bookmark.slash").font(.title).bold().foregroundStyle(.secondary).padding(4.0)
                Text("No Active Books").multilineTextAlignment(.center).font(.callout).bold()
                Text("You don't have any books in progress.").multilineTextAlignment(.center).font(.caption).foregroundStyle(.secondary).padding(.top, 0.25)
                Spacer()
            }
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
        .padding(4)
    }
}

struct AccessoryInlineView: View {
    let books: [Book?]
    
    var body: some View {
        let currentBooks = books.filter { optionalBook in
            if let book = optionalBook {
                return !book.isFuture
            } else {
                return false
            }
        }
        
        if currentBooks.count == 0 {
            return Text("No active books")
        }
        
        let (pageCount, bookCount) = getPagesInBooksRemaining(in: currentBooks)
        let pageWord = pageCount == 1 ? "page" : "pages"
        let bookWord = bookCount == 1 ? "book" : "books"
        
        if (pageCount > 0) {
            return Text("\(pageCount) \(pageWord) in \(bookCount) \(bookWord)")
        }
        return Text("Read enough today")
    }
    
    func getPagesInBooksRemaining(in books: [Book?]) -> (Int, Int) {
        let pageCounts = books.map{
            (book) -> Int in
            if let book = book {
                return book.readEnoughToday ? 0 : book.pagesRemainingToday
            } else {
                return 0;
            }
        }
        let bookCount = books.filter{
            (book) -> Bool in
            if let book = book {
                return !book.readEnoughToday
            } else {
                return false;
            }
        }.count
        return (pageCounts.reduce(0, +), bookCount)
    }
}

struct AccessoryCircularView: View {
    let book: Book?
    
    var body: some View {
        if let book = book {
            ProgressCircle(
                progress: book.progressBarFillAmount,
                progressColor: book.progressColor,
                centerContent: book.progressIcon
            )
            .padding(4.25)
            .background(.thinMaterial)
            .clipShape(Circle())
        } else {
            ProgressCircle(
                progress: 0,
                progressColor: .gray,
                centerContent: Image(systemName: "bookmark.slash")
                    .foregroundStyle(.gray)
                    .font(Font.system(.body).bold())
            )
            .padding(4.25)
            .background(.thinMaterial)
            .clipShape(Circle())
        }
    }
}

struct AccessoryRectangleView: View {
    let book: Book?
    let selectedDetails: WidgetDetails
    
    var body: some View {
        if let book = book {
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
        } else {
            HStack(alignment: .center) {
                Image(systemName: "bookmark.slash").font(.subheadline).bold().foregroundStyle(.gray).padding(4.0)
                Text("No Active Books").multilineTextAlignment(.center).font(.caption).bold()
            }
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
                    book: entry.selectedBooks.first,
                    selectedDetails: entry.selectedDetails
                )
            case .accessoryInline:
                AccessoryInlineView(books: entry.selectedBooks)
            case .accessoryCircular:
                AccessoryCircularView(book: entry.selectedBooks.first)
            case .accessoryRectangular:
                AccessoryRectangleView(book: entry.selectedBooks.first, selectedDetails: entry.selectedDetails)
            default:
                if entry.selectedBooks.count > 0 {
                    VStack(spacing: 1.0) {
                        Spacer()
                        ForEach(entry.selectedBooks) { book in
                            RowBookView(book: book, selectedDetails: entry.selectedDetails)
                            if book != entry.selectedBooks.last {
                                Spacer()
                                Divider()
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding(4)
                } else {
                    VStack {
                        Spacer()
                        ContentUnavailableView("No Active Books", systemImage: "bookmark.slash", description: Text("You don't have any books in progress."))
                        Spacer()
                    }
                }
            }
        }.containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

@main
struct SelectedBookWidget: Widget {
    let kind: String = "SelectedBookWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectedBookIntent.self, provider: Provider()) { entry in
            SelectedBookWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Book Progress")
        .description("Track a book's progress and choose which information appears")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

struct SelectedBookWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookTwo]))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: []))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookThree, bookTwo]))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: []))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookThree, bookTwo, bookOne, bookFour]))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: []))
                .previewContext(WidgetPreviewContext(family: .systemLarge))

            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookOne]))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: []))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))

            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookOne]))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: []))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [bookOne]))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: []))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))

        }
    }
}
