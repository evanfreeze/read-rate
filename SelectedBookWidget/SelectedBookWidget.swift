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
                .frame(width: circleProgressSize, height: circleProgressSize)
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
        if let firstBook = BookStore().activeBooks.first {
            return SimpleEntry(date: Date(), book: firstBook, details: firstBook.progressDescription)
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
            
            return SimpleEntry(date: Date(), book: placeholderBook, details: placeholderBook.progressDescription)
        }
        
    }

    func getSnapshot(for configuration: SelectedBookIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        var entry: SimpleEntry
        
        if let selectedBook = BookStore().books.first(where: { $0.title == configuration.selectedBook?.displayString }) {
            
            entry = SimpleEntry(date: Date(), book: selectedBook, details: selectedBook.progressDescription)
        } else {
            let firstBook = BookStore().activeBooks.first
            entry = SimpleEntry(date: Date(), book: firstBook!, details: firstBook!.progressDescription)
        }
        
        completion(entry)
    }

    func getTimeline(for configuration: SelectedBookIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        
        if let selectedBook = BookStore().books.first(where: { $0.title == configuration.selectedBook?.displayString }) {
            let details = getWidgetDetails(for: configuration.details, book: selectedBook)
            let entry = SimpleEntry(date: Date(), book: selectedBook, details: details)
            entries.append(entry)
        } else {
            let firstBook = BookStore().activeBooks.first!
            let details = getWidgetDetails(for: configuration.details, book: firstBook)
            let entry = SimpleEntry(date: Date(), book: firstBook, details: details)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
    
    func getWidgetDetails(for detailsEnum: WidgetDetails, book: Book) -> String {
        switch detailsEnum {
        case .currentPage:
            return "You're on page \(book.currentPage)"
        case .percentage:
            return "You've read \(book.percentComplete)"
        case .todaysTarget:
            return "Read to page \(book.dailyTargets.last?.targetPage ?? book.pageCount)"
        case .pagesLeft:
            return "\(book.pagesRemainingToday) pages left today"
        case .unknown:
            return "Read to page \(book.dailyTargets.last?.targetPage ?? book.pageCount)"
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let book: Book
    let details: String
}

struct SelectedBookWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                HStack {
                    VStack(alignment: .leading) {
                        ProgressCircle(progress: entry.book.progressBarFillAmount, progressColor: entry.book.progressColor, centerContent: entry.book.progressIcon)
                        Spacer()
                        Text(entry.book.title)
                            .rounded(.subheadline)
                        Text(entry.book.author)
                            .rounded(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 1.0)
                        Text(entry.details)
                            .rounded(.caption2, bold: false)
                            .foregroundColor(.secondary)
                            .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                    }
                    Spacer(minLength: 0)
                }
                .padding()
            case .systemMedium:
                HStack {
                    ProgressCircle(progress: entry.book.progressBarFillAmount, progressColor: entry.book.progressColor, centerContent: entry.book.progressIcon)
                    VStack(alignment: .leading, spacing: 4.0) {
                        VStack(alignment: .leading) {
                            Text(entry.book.title)
                                .rounded(.title3)
                            Text(entry.book.author)
                                .rounded(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Text(entry.book.progressDescription)
                            .rounded(.caption, bold: false)
                            .foregroundColor(.secondary)
                            .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                    }
                    .padding(.leading, 10)
                    Spacer()
                }
                .padding()
            default:
                HStack {
                    
                }
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
        .supportedFamilies([.systemSmall])
    }
}

struct SelectedBookWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), book: bookTwo, details: bookTwo.progressDescription))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SelectedBookWidgetEntryView(entry: SimpleEntry(date: Date(), book: bookTwo, details: bookTwo.progressDescription))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
