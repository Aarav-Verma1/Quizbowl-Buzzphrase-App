import SwiftUI

struct SearchView: View {
    @State private var answer = ""
    @State private var category = "All"
    @State private var results: ExtractionResponse?
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Topic") {
                    TextField(
                        "Enter an answer",
                        text: $answer
                    )

                    Picker(
                        "Category",
                        selection: $category
                    ) {
                        Text("All").tag("All")
                        Text("History").tag("History")
                        Text("Literature").tag("Literature")
                        Text("Science").tag("Science")
                    }
                }

                Section {
                    Button("Find Buzzphrases") {
                        Task {
                            await search()
                        }
                    }
                    .disabled(
                        answer.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )

                    if isLoading {
                        ProgressView("Searching...")
                    }
                }

                if !errorMessage.isEmpty {
                    Section("Error") {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                if let results {
                    Section("Buzzphrases") {
                        ForEach(results.buzzwords) { phrase in
                            NavigationLink {
                                FlashcardView(
                                    phrase: phrase,
                                    answer: results.answer
                                )
                            } label: {
                                BuzzphraseRow(
                                    buzzword: phrase
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("QuizBowl")
        }
    }

    private func search() async {
        isLoading = true
        errorMessage = ""
        results = nil

        do {
            results = try await QuizBowlAPI.shared.extract(
                answer: answer,
                category: category
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
