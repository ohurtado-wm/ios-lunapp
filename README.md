# MoonPhaseApp (iOS Native)

A basic native iOS SwiftUI app that shows today's moon phase and its corresponding image.

## Project Structure

- `MoonPhaseApp.xcodeproj` - Xcode project
- `MoonPhaseApp/MoonPhaseAppApp.swift` - app entry point
- `MoonPhaseApp/ContentView.swift` - single page UI
- `MoonPhaseApp/MoonPhaseCalculator.swift` - moon phase calculation logic + view model
- `MoonPhaseApp/Assets.xcassets/*.imageset` - all moon phase images

## Included Moon Images

- `new_moon`
- `waxing_crescent`
- `first_quarter`
- `waxing_gibbous`
- `full_moon`
- `waning_gibbous`
- `last_quarter`
- `waning_crescent`

## Open and Run

1. Open `MoonPhaseApp.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Run (`Cmd+R`).

The app computes today's moon phase from the current date and shows the corresponding phase image.
