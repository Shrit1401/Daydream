//
//  HomeWidget.swift
//  HomeWidget
//
//  Created by Shrit Shrivastava on 20/05/25.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "No note for today")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = getDataFromFlutter()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = getDataFromFlutter()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func getDataFromFlutter() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.homeScreenApp")
        let textFromFlutterApp = userDefaults?.string(forKey: "text_from_flutter") ?? ""
        return SimpleEntry(date: Date(), text: textFromFlutterApp)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let text: String
}

struct HomeWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d'th' MMMM"  // e.g., 20th May
        return formatter
    }()
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    var body: some View {
        ZStack {
            // Background image
            Image("background")
                .resizable()
                .scaledToFill()

            VStack(alignment: .leading, spacing: 8) {
                // Date
                Text(Self.dateFormatter.string(from: entry.date))
                    .font(.custom("Georgia-Italic", size: family == .systemSmall ? 30 : 40))
                    .foregroundColor(.white)
                    .padding(.top, 8)
                    .padding(.bottom, 2)

                // Note text
                Text(entry.text.isEmpty ? "No note for today" : entry.text)
                    .font(.system(size: family == .systemSmall ? 15 : 18))
                    .foregroundColor(.white)
                    .lineLimit(family == .systemSmall ? 6 : 12)
                    .padding(.bottom, 4)

                Spacer()

                // Time
                Text(Self.timeFormatter.string(from: entry.date).lowercased())
                    .font(.custom("Georgia-Italic", size: family == .systemSmall ? 16 : 20))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

struct HomeWidget: Widget {
    let kind: String = "HomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Note")
        .description("Shows your note for today.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    HomeWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        text:
            "This is a sample note for today. You can write more and see more in the medium or large widget!"
    )
}
