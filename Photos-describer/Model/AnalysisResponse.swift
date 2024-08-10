import Foundation

// MARK: - AnalysisResponse
struct AnalysisResponse: Codable {
    let transcribedText: TranscribedText
}

// MARK: - TranscribedText
struct TranscribedText: Codable {
    let text: String
}
