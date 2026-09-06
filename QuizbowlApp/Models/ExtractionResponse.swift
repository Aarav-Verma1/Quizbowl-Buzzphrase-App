import Foundation

struct ExtractionResponse: Decodable {
    let answer: String
    let category: String
    let buzzwords: [Buzzphrase]
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case answer
        case category
        case buzzwords
        case totalCount = "total_count"
    }
}
