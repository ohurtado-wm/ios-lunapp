import SwiftUI

@main
struct MoonPhaseAppApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var logStore = ActivityLogStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(viewModel: MoonPhaseViewModel())
                    .environmentObject(settings)
                    .environmentObject(logStore)
            }
        }
    }
}
