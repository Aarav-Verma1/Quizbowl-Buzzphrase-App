import Foundation

struct Buzzphrase: Codable, Identifiable {
    var id: String {
        phrase
    }

    let phrase: String
    let score: Double?
    let celerity: Double?
}
