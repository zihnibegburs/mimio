import AppIntents

@available(iOS 16.0, *)
struct MimioShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddMimioTaskIntent(),
            phrases: [
                "Mimio'ya \(\.$taskTitle) ekle",
                "\(.applicationName)'da görev ekle \(\.$taskTitle)",
                "Mimio'ya görev ekle \(\.$taskTitle)",
                "Add \(\.$taskTitle) in \(.applicationName)",
            ],
            shortTitle: "Görev Ekle",
            systemImageName: "plus.circle.fill"
        )
    }
}
