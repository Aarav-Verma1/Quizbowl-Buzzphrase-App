import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("Backend") {
                    Text("http://127.0.0.1:8000")
                        .font(.caption)
                }

                Section("About") {
                    Text("QuizBowl helps you study important clues from quiz bowl questions.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
