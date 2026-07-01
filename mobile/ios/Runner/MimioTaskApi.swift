import Foundation

enum MimioTaskApiError: Error, LocalizedError {
    case notAuthenticated
    case invalidConfiguration
    case networkError(String)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Önce Mimio'da oturum açman gerekiyor."
        case .invalidConfiguration:
            return "Mimio yapılandırması eksik. Uygulamayı bir kez aç."
        case .networkError(let message):
            return "Bağlantı hatası: \(message)"
        case .serverError:
            return "Görev eklenemedi. Biraz sonra tekrar dene."
        }
    }
}

enum MimioTaskApi {
    static func createTask(title: String) async throws {
        guard let token = MimioSharedStorage.authToken else {
            throw MimioTaskApiError.notAuthenticated
        }
        guard let baseUrl = MimioSharedStorage.apiBaseUrl,
              let url = URL(string: "\(baseUrl)/tasks") else {
            throw MimioTaskApiError.invalidConfiguration
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "title": title,
            "color": "#6C63FF",
            "icon": "task",
            "durationMinutes": 30,
            "isInbox": false,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response): (Data, URLResponse)
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MimioTaskApiError.networkError(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw MimioTaskApiError.networkError("Geçersiz yanıt")
        }

        switch http.statusCode {
        case 200...299:
            return
        case 401:
            throw MimioTaskApiError.notAuthenticated
        default:
            throw MimioTaskApiError.serverError(http.statusCode)
        }
    }
}
