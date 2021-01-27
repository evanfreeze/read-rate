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

struct RoundedText: ViewModifier {
    let style: Font.TextStyle
    let bold: Bool
    
    func body(content: Content) -> some View {
        if bold {
            return content
                .font(Font.system(style, design: .rounded).bold())
        } else {
            return content
                .font(Font.system(style, design: .rounded))
        }
    }
}

public extension Text {
    func rounded(_ style: Font.TextStyle = .body, bold: Bool = true) -> some View {
        self.modifier(RoundedText(style: style, bold: bold))
    }
}

struct ProgressCircle<T: View>: View {
    let progress: Double
    let progressColor: Color
    let centerContent: T
    
    let circleProgressSize: CGFloat = 52.0
    let circleLineWidth: CGFloat = 6.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: circleLineWidth)
                .opacity(0.1)
                .foregroundColor(progressColor)
                .frame( width: circleProgressSize, height: circleProgressSize)
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: circleLineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
                .frame(width: circleProgressSize, height: circleProgressSize)
                .rotationEffect(Angle(degrees: 270.0))
            centerContent
        }
    }
}



// JUST WIDGET STUFF

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        if BookStore().activeBooks.count > 0 {
            return SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: BookStore().activeBooks)
        } else {
            let tomorrow = Date().advanced(by: TimeInterval(60 * 60 * 24))
            
            var placeholderBook = Book(
                title: "The Great Gatsby",
                author: "F. Scott Fitzgerald",
                pageCount: 30,
                currentPage: 15,
                startDate: Date(),
                targetDate: tomorrow
            )
            placeholderBook.dailyTargets.append(
                DailyTarget(
                    targetPage: 30,
                    calcTime: Date(),
                    meta: DailyTargetMeta(pageCount: 30, currentPage: 15, targetDate: tomorrow)
                )
            )
            
            return SimpleEntry(date: Date(), selectedDetails: .todaysTarget, selectedBooks: [placeholderBook, bookThree])
        }
        
    }

    func getSnapshot(for configuration: SelectedBookIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        var selectedBooks: [Book]
        
        if let selectedTitles = configuration.selectedBook?.map({ $0.displayString }) {
            selectedBooks = BookStore().books.filter({ selectedTitles.contains($0.title) })
        } else {
            switch context.family {
            case .systemSmall:
                selectedBooks = [BookStore().activeBooks.first!]
            case .systemMedium:
                selectedBooks = Array(BookStore().activeBooks.prefix(upTo: 2))
            case .systemLarge:
                selectedBooks = Array(BookStore().activeBooks.prefix(upTo: 4))
            @unknown default:
                selectedBooks = BookStore().activeBooks
            }
        }
        
        let entry = SimpleEntry(date: Date(), selectedDetails: configuration.details, selectedBooks: selectedBooks)
        
        completion(entry)
    }

    func getTimeline(for configuration: SelectedBookIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var selectedBooks = [Book]()
        
        if let selectedTitles = configuration.selectedBook?.map({ $0.displayString }) {
            for title in selectedTitles {
                let book = BookStore().activeBooks.first(where: { title == $0.title })!
                selectedBooks.append(book)
            }
        } else {
            switch context.family {
            case .systemSmall:
                selectedBooks = [BookStore().activeBooks.first!]
            case .systemMedium:
                selectedBooks = Array(BookStore().activeBooks.prefix(upTo: 2))
            case .systemLarge:
                selectedBooks = Array(BookStore().activeBooks.prefix(upTo: 4))
            @unknown default:
                selectedBooks = BookStore().activeBooks
            }
        }
        
        let entry = SimpleEntry(date: Date(), selectedDetails: configuration.details, selectedBooks: selectedBooks)
        let timeline = Timeline(entries: [entry], policy: .never)
        
        completion(timeline)
    }
}

func getWidgetDetails(for detailsEnum: WidgetDetails, book: Book) -> String {
    switch detailsEnum {
    case .currentPage:
        return "You're on page \(book.currentPage)"
    case .percentage:
        return "You've read \(book.percentComplete)"
    case .todaysTarget:
        return book.progressDescriptionShort
    case .pagesLeft:
        return "\(book.pagesRemainingToday) pages left today"
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
        }
    }
}

@main
struct SelectedBookWidget: Widget {
    let kind: String = "SelectedBookWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectedBookIntent.self, provider: Provider()) { entry in
            SelectedBookWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Target")
        .description("Displays your daily target for the chosen book")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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
        }
    }
}
