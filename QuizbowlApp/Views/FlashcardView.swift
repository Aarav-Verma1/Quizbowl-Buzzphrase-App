import SwiftUI

struct FlashcardView: View {
    let phrase: Buzzphrase
    let answer: String

    @State private var showingAnswer = false
    @State private var explanation = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Buzzphrase")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(phrase.phrase)
                .font(.title2)
                .multilineTextAlignment(.center)

            Divider()

            if showingAnswer {
                VStack(spacing: 12) {
                    Text("Answer")
                        .font(.headline)

                    Text(answer)
                        .font(.title3)

                    Text("Explanation")
                        .font(.headline)
                        .padding(.top, 8)

                    if isLoading {
                        ProgressView("Loading explanation...")
                    } else {
                        Text(
                            explanation.isEmpty
                                ? "No explanation available."
                                : explanation
                        )
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Button(showingAnswer ? "Hide Answer" : "Flip Card") {
                showingAnswer.toggle()

                if showingAnswer && explanation.isEmpty {
                    Task {
                        await loadExplanation()
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("Practice")
    }

    private func loadExplanation() async {
        isLoading = true

        do {
            explanation = try await QuizBowlAPI.shared.getExplanation(
                phrase: phrase.phrase,
                answer: answer
            )
        } catch {
            explanation = "Could not load the explanation."
        }

        isLoading = false
    }
}
