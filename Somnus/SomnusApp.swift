//
//  SomnusApp.swift
//  Somnus
//
//  Created by Antoine on 08/10/2024.
//

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
                    viewModel.isDisplaySleepDisabled.toggle() // Gérer la mise en veille de l'écran
                }) {
                    HStack {
                        if viewModel.isDisplaySleepDisabled {
                            Image(systemName: "checkmark")
                        }
                        Text("Prevent Display sleep")
                    }
                }

                Button(action: {
                    viewModel.isSystemSleepDisabled.toggle() // Gérer la mise en veille du système
                }) {
                    HStack {
                        if viewModel.isSystemSleepDisabled {
                            Image(systemName: "checkmark")
                        }
                        Text("Prevent System sleep")
                    }
                }

                Divider()

                Button(action: {
                    viewModel.showAboutMe() // Ouvre la fenêtre AboutMe
                }) {
                    HStack {
                        Text("About Somnus")
                    }
                }

                Divider()

                Button(action: {
                    viewModel.showSettings() // Ouvre la fenêtre Settings
                }) {
                    HStack {
                        Text("Settings")
                    }
                }

                Divider()

                Button(action: {
                    NSApp.terminate(nil) // Quitte l'application
                }) {
                    HStack {
                        Text("Quit Somnus")
                    }
                }
            }
        } label: {
            Image(systemName: viewModel.menuIcon) // Icône de la barre de menu
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
                Toggle("Prevent Display Sleep", isOn: $viewModel.isDisplaySleepDisabled)
                Toggle("Prevent System Sleep", isOn: $viewModel.isSystemSleepDisabled)
            }
        }
        .frame(minWidth: 400, minHeight: 200)
        .padding()
    }
}

class SomnusViewModel: ObservableObject {
    @Published var menuIcon: String = "bolt" // Icône dans la barre de menu
    private var sleepAssertionID: IOPMAssertionID = 0
    private var systemSleepAssertionID: IOPMAssertionID = 0

    @Published var isDisplaySleepDisabled: Bool = false {
        didSet {
            if isDisplaySleepDisabled {
                isSystemSleepDisabled = false // Désactiver l'autre option
            }
            toggleDisplaySleepMode()
        }
    }

    @Published var isSystemSleepDisabled: Bool = false {
        didSet {
            if isSystemSleepDisabled {
                isDisplaySleepDisabled = false // Désactiver l'autre option
            }
            toggleSystemSleepMode()
        }
    }

    // Mise à jour de l'icône de la barre de menu en fonction des états
    private func updateMenuIcon() {
        menuIcon = (isDisplaySleepDisabled || isSystemSleepDisabled) ? "bolt.fill" : "bolt"
    }

    // Gérer la mise en veille de l'écran
    func toggleDisplaySleepMode() {
        if isDisplaySleepDisabled {
            disableDisplaySleep()
        } else {
            enableDisplaySleep()
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

    // Gérer la mise en veille du système
    func toggleSystemSleepMode() {
        if isSystemSleepDisabled {
            disableSystemSleep()
        } else {
            enableSystemSleep()
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

    // Affichage de la fenêtre "About"
    func showAboutMe() {
        let aboutView = NSHostingController(rootView: AboutMeView())
        let aboutWindow = NSWindow(contentViewController: aboutView)
        aboutWindow.setContentSize(NSSize(width: 300, height: 200))
        aboutWindow.styleMask = [.titled, .closable, .miniaturizable]
        aboutWindow.title = "About Somnus"
        aboutWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // Affichage de la fenêtre "Settings"
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
