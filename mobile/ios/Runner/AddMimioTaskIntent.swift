import AppIntents
import Foundation

@available(iOS 16.0, *)
struct AddMimioTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.add_task.title"
    static var description = IntentDescription(LocalizedStringResource("intent.add_task.description"))
    static var openAppWhenRun: Bool = false

    @Parameter(
        title: LocalizedStringResource("intent.add_task.parameter.title"),
        requestValueDialog: IntentDialog(LocalizedStringResource("intent.add_task.parameter.prompt"))
    )
    var taskTitle: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let title = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw MimioIntentFailure(messageKey: "intent.add_task.error.empty")
        }

        do {
            try await MimioTaskApi.createTask(title: title)
            let format = String(localized: LocalizedStringResource("intent.add_task.success"))
            return .result(dialog: IntentDialog(stringLiteral: String(format: format, title)))
        } catch let error as LocalizedError {
            throw MimioIntentFailure(message: error.errorDescription ?? String(localized: LocalizedStringResource("intent.add_task.error.failed")))
        } catch {
            throw MimioIntentFailure(messageKey: "intent.add_task.error.retry")
        }
    }
}

@available(iOS 16.0, *)
struct MimioIntentFailure: Error, CustomLocalizedStringResourceConvertible {
    let message: String?

    init(message: String) {
        self.message = message
    }

    init(messageKey: String) {
        self.message = String(localized: LocalizedStringResource(stringLiteral: messageKey))
    }

    var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: message ?? "")
    }
}
