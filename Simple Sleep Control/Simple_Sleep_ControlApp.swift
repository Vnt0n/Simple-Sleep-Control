//
//  Simple_Sleep_ControlApp.swift
//  Simple Sleep Control
//
//  Created by Antoine on 09/10/2024.
//

import SwiftUI
import IOKit.pwr_mgt
import ServiceManagement

@main
struct SimpleSleepControlApp: App {
    @StateObject private var viewModel = SimpleSleepControlViewModel()

    var body: some Scene {
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
                    let launchAtLogin = !viewModel.isLoginItemEnabled
                    viewModel.setLoginItem(enabled: launchAtLogin)
                }) {
                    HStack {
                        if viewModel.isLoginItemEnabled {
                            Image(systemName: "checkmark")
                        }
                        Text("Launch at login")
                    }
                }

                Divider()

                Button(action: {
                    viewModel.showAboutMe()
                }) {
                    HStack {
                        Text("About me")
                    }
                }
                
                
                Button(action: {
                    viewModel.showAboutSimpleSleepControl()
                }) {
                    HStack {
                        Text("About Simple Sleep control")
                    }
                }

                Divider()

                Button(action: {
                    NSApp.terminate(nil)
                }) {
                    HStack {
                        Text("Quit Simple Sleep Control")
                    }
                }
                
// //////////////////////////// Bouton pour afficher WhatsNewView ////////////////////////////////////////////////
                Divider()
                Button(action: {
                    viewModel.showWhatsNewWindow()
                }) {
                    HStack {
                        Text("Afficher WhatsNew")
                    }
                }
// //////////////////////////// Bouton pour réinitialiser OpeningView UserDefaults ////////////////////////////////////////////////
                Button(action: {
                    viewModel.resetOnboarding()
                }) {
                    Text("Reset Onboarding")
                }
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
            }
        } label: {
            Image(systemName: viewModel.menuIcon)
        }
        .onChange(of: viewModel.showOpeningView) { oldValue, newValue in
            if newValue {
                viewModel.showOpeningWindow()
            }
        }
    }
}

// VueModel
class SimpleSleepControlViewModel: ObservableObject {
    @Published var menuIcon: String = "zzz"
    private var sleepAssertionID: IOPMAssertionID = 0
    private var systemSleepAssertionID: IOPMAssertionID = 0
    @Published var isLoginItemEnabled: Bool = false

    @Published var isDisplaySleepDisabled: Bool = false
    @Published var isSystemSleepDisabled: Bool = false
    @Published var showOpeningView: Bool = !UserDefaults.standard.bool(forKey: "DontShowOpeningViewAgain")
    @Published var showWhatsNewView: Bool = !UserDefaults.standard.bool(forKey: "DontShowWhatsNewViewAgain")

    init() {
        isLoginItemEnabled = SMAppService.mainApp.status == .enabled
        
        // Vérifier si l'OpeningView doit être affichée
        DispatchQueue.main.async {
            if self.showOpeningView {
                self.showOpeningWindow()
            }
        }
    }

    func setLoginItem(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            isLoginItemEnabled = enabled
        } catch {
            print("Failed to toggle login item: \(error)")
        }
    }

    // Afficher la fenêtre d'ouverture
    func showOpeningWindow() {
        let openingView = NSHostingController(rootView: OpeningView())
        let openingWindow = NSWindow(contentViewController: openingView)
        openingWindow.styleMask = [.titled, .closable]
        openingWindow.title = "Welcome to Simple Sleep Control"
        openingWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // Gérer la mise en veille de l'écran avec exclusion mutuelle
    func toggleDisplaySleepMode() {
        if isDisplaySleepDisabled {
            enableDisplaySleep()
        } else {
            disableDisplaySleep()

            if isSystemSleepDisabled {
                // Libérer l'assertion de mise en veille du système si elle est encore active
                enableSystemSleep()
            }
            isSystemSleepDisabled = false // Assurer l'exclusion mutuelle et synchroniser l'état
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

            if isDisplaySleepDisabled {
                // Libérer l'assertion de mise en veille de l'écran si elle est encore active
                enableDisplaySleep()
            }
            isDisplaySleepDisabled = false // Assurer l'exclusion mutuelle et synchroniser l'état
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
        if isSystemSleepDisabled {
            menuIcon = "moon.zzz.fill"
        } else if isDisplaySleepDisabled {
            menuIcon = "moon.zzz"
        } else {
            menuIcon = "zzz"
        }
    }

    // Afficher la fenêtre About Me
    func showAboutMe() {
        let aboutView = NSHostingController(rootView: AboutMeView())
        let aboutWindow = NSWindow(contentViewController: aboutView)
        aboutWindow.styleMask = [.titled, .closable]
        aboutWindow.title = "Simple Sleep Control"
        aboutWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // Afficher la fenêtre About Simple Sleep control
    func showAboutSimpleSleepControl() {
        let aboutAppView = NSHostingController(rootView: AboutSimpleSleepControlView())
        let aboutWindow = NSWindow(contentViewController: aboutAppView)
        aboutWindow.styleMask = [.titled, .closable]
        aboutWindow.title = "Simple Sleep Control"
        aboutWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // Afficher la fenêtre "What's New"
    func showWhatsNewWindow() {
        let whatsNewView = NSHostingController(rootView: WhatsNewView())
        let whatsNewWindow = NSWindow(contentViewController: whatsNewView)
        whatsNewWindow.styleMask = [.titled, .closable]
        whatsNewWindow.title = "What's New"
        whatsNewWindow.setContentSize(NSSize(width: 400, height: 200))
        whatsNewWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
// //////////////////////////// Fonction pour réinitialiser OpeningView UserDefaults ////////////////////////////////////////////////
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "DontShowOpeningViewAgain")
        showOpeningView = true // Réinitialiser l'état pour afficher l'OpeningView
    }
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}
