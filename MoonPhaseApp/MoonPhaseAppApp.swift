import SwiftUI

@main
struct MoonPhaseAppApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(viewModel: MoonPhaseViewModel())
                    .environmentObject(settings)
            }
        }
    }
}
