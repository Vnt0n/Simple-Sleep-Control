//
//  Simple_Sleep_ModeApp.swift
//  Simple Sleep Mode
//
//  Created by Antoine on 08/10/2024.
//

import SwiftUI
import IOKit.pwr_mgt

@main
struct SimpleSleepModeApp: App {
    @StateObject private var viewModel = SimpleSleepModeViewModel()

    var body: some Scene {
        WindowGroup {
            AboutMeView()
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
                        Text("About Simple Sleep Mode")
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
                        Text("Quit Simple Sleep Mode")
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
    @Environment(\.dismiss) var dismiss  // Ajoute l'action dismiss

    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Simple Sleep Mode")
                .font(.title)
                .padding()
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("OK")
                    .font(.title3)
                    .bold()
                    .padding()
                    .frame(width: 70)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .frame(minWidth: 400, minHeight: 200)
    }
}

// Vue pour les Settings
struct SettingsView: View {
    @ObservedObject var viewModel: SimpleSleepModeViewModel
    @Environment(\.dismiss) var dismiss  // Ajoute l'action dismiss

    var body: some View {
        Form {
            VStack {
                
                Spacer()

                Text("Settings")
                    .font(.system(size: 30))

                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("OK")
                        .font(.title3)
                        .bold()
                        .padding()
                        .frame(width: 70)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }

        }
        .frame(minWidth: 400, minHeight: 200)
        .padding()
    }
}

// VueModel
class SimpleSleepModeViewModel: ObservableObject {
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
    
    func setDisplaySleepMode(isDisabled: Bool) {
        if isDisabled {
            disableDisplaySleep()
            isSystemSleepDisabled = false // Exclusion mutuelle
        } else {
            enableDisplaySleep()
        }
        updateMenuIcon()
    }

    func setSystemSleepMode(isDisabled: Bool) {
        if isDisabled {
            disableSystemSleep()
            isDisplaySleepDisabled = false // Exclusion mutuelle
        } else {
            enableSystemSleep()
        }
        updateMenuIcon()
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
        aboutWindow.title = "About Simple Sleep Mode"
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
