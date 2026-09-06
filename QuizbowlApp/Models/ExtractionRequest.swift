import Foundation

struct ExtractionRequest: Encodable {
    let answer: String
    let category: String
    let maxQuestions: Int

    enum CodingKeys: String, CodingKey {
        case answer
        case category
        case maxQuestions = "max_questions"
    }
}
