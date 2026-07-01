import AppIntents
import Foundation

@available(iOS 16.0, *)
struct AddMimioTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Görev Ekle"
    static var description = IntentDescription("Mimio'ya yeni bir görev ekler.")
    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Görev",
        requestValueDialog: IntentDialog("Ne eklemek istiyorsun?")
    )
    var taskTitle: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let title = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw $taskTitle.needsValueDialog("Görev adını söyle.")
        }

        do {
            try await MimioTaskApi.createTask(title: title)
            return .result(dialog: "Tamam, \"\(title)\" görevini ekledim.")
        } catch let error as LocalizedError {
            throw MimioIntentFailure(message: error.errorDescription ?? "Görev eklenemedi.")
        } catch {
            throw MimioIntentFailure(message: "Görev eklenemedi. Biraz sonra tekrar dene.")
        }
    }
}

@available(iOS 16.0, *)
struct MimioIntentFailure: Error, CustomLocalizedStringResourceConvertible {
    let message: String

    var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: message)
    }
}
