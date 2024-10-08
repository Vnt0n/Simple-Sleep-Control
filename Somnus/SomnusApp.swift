import SwiftUI
import IOKit.pwr_mgt

@main
struct SomnusApp: App {
    @StateObject private var viewModel = SomnusViewModel()

    var body: some Scene {
        WindowGroup {
            SettingsView(viewModel: viewModel)
        }
        MenuBarExtra {
            VStack {
                Button(action: {
                    viewModel.toggleDisplaySleepMode()
                }) {
                    HStack {
                        if viewModel.isDisplaySleepDisabled {
                            Image(systemName: "checkmark")
                        }
                        Text("Prevent Display Sleep")
                    }
                }

                Button(action: {
                    viewModel.toggleSystemSleepMode()
                }) {
                    HStack {
                        if viewModel.isSystemSleepDisabled {
                            Image(systemName: "checkmark")
                        }
                        Text("Prevent System Sleep")
                    }
                }

                Divider()

                Button(action: {
                    viewModel.showAboutMe()
                }) {
                    HStack {
                        Text("About Somnus")
                    }
                }

                Divider()

                Button(action: {
                    viewModel.showSettings()
                }) {
                    HStack {
                        Text("Settings")
                    }
                }

                Divider()

                Button(action: {
                    NSApp.terminate(nil)
                }) {
                    HStack {
                        Text("Quit Somnus")
                    }
                }
            }
        } label: {
            Image(systemName: viewModel.menuIcon)
        }
    }
}

// Vue pour l'onglet "About me"
struct AboutMeView: View {
    var body: some View {
        VStack {
            Text("About Somnus")
                .font(.title)
                .padding()
            Text("This app prevents your Mac from sleeping.")
                .padding()
        }
        .frame(width: 300, height: 200)
    }
}

// Vue pour les Settings
struct SettingsView: View {
    @ObservedObject var viewModel: SomnusViewModel

    var body: some View {
        Form {
            Section(header: Text("Sleep Settings")) {
                Toggle("Prevent Display Sleep", isOn: Binding(
                    get: { viewModel.isDisplaySleepDisabled },
                    set: { newValue in
                        viewModel.toggleDisplaySleepMode()
                    }
                ))

                Toggle("Prevent System Sleep", isOn: Binding(
                    get: { viewModel.isSystemSleepDisabled },
                    set: { newValue in
                        viewModel.toggleSystemSleepMode()
                    }
                ))
            }
        }
        .frame(minWidth: 400, minHeight: 200)
        .padding()
    }
}

// VueModel
class SomnusViewModel: ObservableObject {
    @Published var menuIcon: String = "bolt"
    private var sleepAssertionID: IOPMAssertionID = 0
    private var systemSleepAssertionID: IOPMAssertionID = 0

    @Published var isDisplaySleepDisabled: Bool = false
    @Published var isSystemSleepDisabled: Bool = false

    // Gérer la mise en veille de l'écran avec exclusion mutuelle
    func toggleDisplaySleepMode() {
        if isDisplaySleepDisabled {
            enableDisplaySleep()
        } else {
            disableDisplaySleep()
            isSystemSleepDisabled = false // Assurer l'exclusion mutuelle
        }
        updateMenuIcon()
    }

    private func disableDisplaySleep() {
        let result = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                 IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                 "Prevent Display Sleep" as CFString,
                                                 &sleepAssertionID)
        if result == kIOReturnSuccess {
            isDisplaySleepDisabled = true
        }
    }

    private func enableDisplaySleep() {
        let result = IOPMAssertionRelease(sleepAssertionID)
        if result == kIOReturnSuccess {
            isDisplaySleepDisabled = false
        }
    }

    // Gérer la mise en veille du système avec exclusion mutuelle
    func toggleSystemSleepMode() {
        if isSystemSleepDisabled {
            enableSystemSleep()
        } else {
            disableSystemSleep()
            isDisplaySleepDisabled = false // Assurer l'exclusion mutuelle
        }
        updateMenuIcon()
    }

    private func disableSystemSleep() {
        let result = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoIdleSleep as CFString,
                                                 IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                 "Prevent System Sleep" as CFString,
                                                 &systemSleepAssertionID)
        if result == kIOReturnSuccess {
            isSystemSleepDisabled = true
        }
    }

    private func enableSystemSleep() {
        let result = IOPMAssertionRelease(systemSleepAssertionID)
        if result == kIOReturnSuccess {
            isSystemSleepDisabled = false
        }
    }

    // Mise à jour de l'icône de la barre de menu
    private func updateMenuIcon() {
        menuIcon = (isDisplaySleepDisabled || isSystemSleepDisabled) ? "bolt.fill" : "bolt"
    }

    // Afficher la fenêtre About
    func showAboutMe() {
        let aboutView = NSHostingController(rootView: AboutMeView())
        let aboutWindow = NSWindow(contentViewController: aboutView)
        aboutWindow.setContentSize(NSSize(width: 300, height: 200))
        aboutWindow.styleMask = [.titled, .closable, .miniaturizable]
        aboutWindow.title = "About Somnus"
        aboutWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // Afficher la fenêtre Settings
    func showSettings() {
        let settingsView = NSHostingController(rootView: SettingsView(viewModel: self))
        let settingsWindow = NSWindow(contentViewController: settingsView)
        settingsWindow.setContentSize(NSSize(width: 400, height: 200))
        settingsWindow.styleMask = [.titled, .closable, .miniaturizable]
        settingsWindow.title = "Settings"
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
