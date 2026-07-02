import ActivityKit
import SwiftUI
import WidgetKit

private let appGroupId = "group.com.mimio.mimio"

struct MimioWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let taskCount: Int
    let taskCountLabel: String
}

struct MimioWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MimioWidgetEntry {
        MimioWidgetEntry(
            date: Date(),
            title: "Breakfast",
            subtitle: "Up next · 08:00",
            taskCount: 3,
            taskCountLabel: "3 tasks"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MimioWidgetEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MimioWidgetEntry>) -> Void) {
        let entry = readEntry()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }

    private func readEntry() -> MimioWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let active = defaults?.string(forKey: "active_task_title")
        let next = defaults?.string(forKey: "next_task_title")
        let title = active ?? next ?? defaults?.string(forKey: "widget_title") ?? "Mimio"
        let subtitle = defaults?.string(forKey: "widget_subtitle") ?? "Mimio"
        let count = defaults?.integer(forKey: "task_count") ?? 0
        let countLabel = defaults?.string(forKey: "task_count_label") ?? "\(count)"
        return MimioWidgetEntry(
            date: Date(),
            title: title,
            subtitle: subtitle,
            taskCount: count,
            taskCountLabel: countLabel
        )
    }
}

struct MimioWidgetView: View {
    let entry: MimioWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Mimio")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.42, green: 0.39, blue: 1.0))
                Spacer()
                Text(entry.taskCountLabel)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text(entry.title)
                .font(.headline)
                .lineLimit(2)
            Text(entry.subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

@main
struct MimioWidgetBundle: WidgetBundle {
    var body: some Widget {
        MimioWidget()
        if #available(iOS 16.1, *) {
            MimioLiveActivityWidget()
        }
    }
}

struct MimioWidget: Widget {
    let kind: String = "MimioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MimioWidgetProvider()) { entry in
            MimioWidgetView(entry: entry)
        }
        .configurationDisplayName("Mimio Plan")
        .description("Günlük planını ana ekrandan takip et.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Live Activities

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable {}

    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        "\(id)_\(key)"
    }
}

@available(iOS 16.1, *)
struct MimioLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let defaults = UserDefaults(suiteName: appGroupId)
            let title = defaults?.string(forKey: context.attributes.prefixedKey("taskTitle")) ?? "Mimio"
            let remaining = defaults?.string(forKey: context.attributes.prefixedKey("remaining")) ?? "--:--"
            let status = defaults?.string(forKey: context.attributes.prefixedKey("statusLabel")) ?? "Mimio"

            VStack(alignment: .leading, spacing: 6) {
                Text(status)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.headline)
                Text(remaining)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.42, green: 0.39, blue: 1.0))
            }
            .padding()
        } dynamicIsland: { context in
            let defaults = UserDefaults(suiteName: appGroupId)
            let title = defaults?.string(forKey: context.attributes.prefixedKey("taskTitle")) ?? "Mimio"
            let remaining = defaults?.string(forKey: context.attributes.prefixedKey("remaining")) ?? "--:--"

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Mimio").font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(remaining).font(.headline)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(title).lineLimit(1)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(remaining).font(.caption2)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}
