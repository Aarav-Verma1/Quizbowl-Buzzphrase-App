import Foundation

final class QuizBowlAPI {
    static let shared = QuizBowlAPI()

    private init() {}

    // iOS Simulator:
    private let baseURL = "http://127.0.0.1:8000"

    // Physical iPhone example:
    // private let baseURL = "http://192.168.1.25:8000"

    func extract(
        answer: String,
        category: String
    ) async throws -> ExtractionResponse {
        guard let url = URL(
            string: "\(baseURL)/extract"
        ) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let requestBody = ExtractionRequest(
            answer: answer,
            category: category == "All" ? "" : category,
            maxQuestions: 50
        )

        request.httpBody = try JSONEncoder().encode(requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                let serverMessage = String(
                    data: data,
                    encoding: .utf8
                ) ?? "No server message"

                throw APIError.serverError(
                    statusCode: httpResponse.statusCode,
                    message: serverMessage
                )
            }

            do {
                return try JSONDecoder().decode(
                    ExtractionResponse.self,
                    from: data
                )
            } catch {
                throw APIError.invalidData(
                    String(data: data, encoding: .utf8) ?? "Unreadable response"
                )
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.connectionFailed(error.localizedDescription)
        }
    }

    func getExplanation(
        phrase: String,
        answer: String
    ) async throws -> String {
        guard let url = URL(
            string: "\(baseURL)/generate-explanation"
        ) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let requestBody: [String: String] = [
            "buzzword": phrase,
            "topic": answer
        ]

        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await URLSession.shared.data(
                for: request
            )
        } catch {
            throw APIError.connectionFailed(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let serverMessage = String(
                data: data,
                encoding: .utf8
            ) ?? "No server message"

            throw APIError.serverError(
                statusCode: httpResponse.statusCode,
                message: serverMessage
            )
        }

        let explanationResponse = try JSONDecoder().decode(
            ExplanationResponse.self,
            from: data
        )

        return explanationResponse.explanation
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case connectionFailed(String)
    case serverError(statusCode: Int, message: String)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The backend URL is invalid."

        case .invalidResponse:
            return "The backend returned an invalid response."

        case .connectionFailed(let message):
            return "Could not connect to server: \(message)"

        case .serverError(let statusCode, let message):
            return "Server error \(statusCode): \(message)"

        case .invalidData(let message):
            return "The server returned unexpected data: \(message)"
        }
    }
}
