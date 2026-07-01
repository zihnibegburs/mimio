import WidgetKit
import SwiftUI

private let appGroupId = "group.com.mimio.mimio"

struct MimioWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let taskCount: Int
}

struct MimioWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MimioWidgetEntry {
        MimioWidgetEntry(date: Date(), title: "Kahvaltı", subtitle: "Sıradaki · 08:00", taskCount: 3)
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
        let title = active ?? next ?? "Bugün plan yok"
        let subtitle = defaults?.string(forKey: "widget_subtitle") ?? "Mimio"
        let count = defaults?.integer(forKey: "task_count") ?? 0
        return MimioWidgetEntry(date: Date(), title: title, subtitle: subtitle, taskCount: count)
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
                Text("\(entry.taskCount) görev")
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
        MimioLiveActivityWidget()
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

struct MimioLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let defaults = UserDefaults(suiteName: appGroupId)
            let title = defaults?.string(forKey: context.attributes.prefixedKey("taskTitle")) ?? "Mimio"
            let remaining = defaults?.string(forKey: context.attributes.prefixedKey("remaining")) ?? "--:--"
            let paused = defaults?.bool(forKey: context.attributes.prefixedKey("paused")) ?? false

            VStack(alignment: .leading, spacing: 6) {
                Text(paused ? "Duraklatıldı" : "Odak modu")
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
