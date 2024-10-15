//
//  Simple_Sleep_ControlApp.swift
//  Simple Sleep Control
//
//  Created by Antoine on 09/10/2024.
//

import SwiftUI
import IOKit.pwr_mgt
import ServiceManagement
import Foundation
import IOKit.ps

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
                    viewModel.lockScreenAndPreventDisplaySleep()
                }) {
                    HStack {
                        Text("Lock Screen and Prevent Display Sleep")
                    }
                }
                
                Button(action: {
                    viewModel.lockScreenAndPreventSystemSleep()
                }) {
                    HStack {
                        Text("Lock Screen and Prevent System Sleep")
                    }
                }

                Divider()
                
                Button(action: {
                    viewModel.launchScreensaverAndPreventDisplaySleep()
                }) {
                    HStack {
                        Text("Launch Screensaver and Prevent Display Sleep")
                    }
                }
                
                Button(action: {
                    viewModel.launchScreensaverAndPreventSystemSleep()
                }) {
                    HStack {
                        Text("Launch Screensaver and Prevent System Sleep")
                    }
                }
                
                Divider()
                
                Button(action: {
                    viewModel.toggleDeactivateIfLowBattery()
                }) {
                    HStack {
                        if viewModel.isCriticalbatteryCharge {
                            Image(systemName: "checkmark")
                        }
                        Text("Deactivate all if 10% battery charge")
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
                    NSApp.terminate(nil)
                }) {
                    HStack {
                        Text("Quit Simple Sleep Control")
                    }
                }
                
// //////////////////////////// Bouton pour afficher WhatsNewView ////////////////////////////////////////////////
//                Divider()
//                Button(action: {
//                    viewModel.showWhatsNewWindow()
//                }) {
//                    HStack {
//                        Text("Afficher WhatsNew")
//                    }
//                }
// //////////////////////////// Bouton pour réinitialiser First Launch UserDefaults ////////////////////////////////////////////////
                Button(action: {
                    viewModel.resetFirstLaunch()
                }) {
                    Text("Reset First Launch")
                }
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
            }
        } label: {
            if viewModel.isCustomImage {
                Image(viewModel.menuIcon)
            } else {
                Image(systemName: viewModel.menuIcon)
            }        }
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
    @Published var showOpeningView: Bool = false
    @Published var showWhatsNewView: Bool = false
    @Published var isCriticalbatteryCharge: Bool = false
    
    var isCustomImage: Bool {
        return isSystemSleepDisabled || isDisplaySleepDisabled
    }

    private let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"

    init() {
        isLoginItemEnabled = SMAppService.mainApp.status == .enabled
        
        checkForFirstLaunch()
        checkForAppUpdate()

        DispatchQueue.main.async {
            if self.showOpeningView {
                self.showOpeningWindow()
            }
        }

        // Abonner aux notifications de déverrouillage de l'écran
        subscribeToScreenUnlockNotifications()
    }

    private func subscribeToScreenUnlockNotifications() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleScreenUnlock),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )
    }

    @objc private func handleScreenUnlock() {
        deactivateAllFeatures()
        updateMenuIcon()
        print("Screen unlocked, deactivating all features")
    }

    // Désactiver toutes les fonctionnalités
    private func deactivateAllFeatures() {
        enableDisplaySleep()
        enableSystemSleep()
    }

    // Activation/désactivation de la veille de l'écran
    private func enableDisplaySleep() {
        if isDisplaySleepDisabled {
            let result = IOPMAssertionRelease(sleepAssertionID)
            if result == kIOReturnSuccess {
                isDisplaySleepDisabled = false
            }
        }
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

    // Activation/désactivation de la veille du système
    private func enableSystemSleep() {
        if isSystemSleepDisabled {
            let result = IOPMAssertionRelease(systemSleepAssertionID)
            if result == kIOReturnSuccess {
                isSystemSleepDisabled = false
            }
        }
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

    // Méthode utilitaire pour désactiver toutes les assertions en cours
    private func resetSleepAssertions() {
        enableDisplaySleep()
        enableSystemSleep()
    }

    // Gérer la mise en veille de l'écran avec exclusion mutuelle
    func toggleDisplaySleepMode() {
        if isDisplaySleepDisabled {
            enableDisplaySleep()
        } else {
            disableDisplaySleep()
            if isSystemSleepDisabled {
                enableSystemSleep()
            }
            isSystemSleepDisabled = false
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
                enableDisplaySleep()
            }
            isDisplaySleepDisabled = false
        }
        updateMenuIcon()
    }

    // Actions combinées pour verrouiller l'écran ou lancer l'écran de veille
    func lockScreenAndPreventDisplaySleep() {
        resetSleepAssertions() // Désactiver toutes les assertions avant de verrouiller l'écran
        lockScreen()
        disableDisplaySleep()
    }

    func lockScreenAndPreventSystemSleep() {
        resetSleepAssertions() // Désactiver toutes les assertions avant de verrouiller l'écran
        lockScreen()
        disableSystemSleep()
    }

    func launchScreensaverAndPreventDisplaySleep() {
        resetSleepAssertions() // Désactiver toutes les assertions avant de lancer l'écran de veille
        launchScreensaver()
        disableDisplaySleep()
    }

    func launchScreensaverAndPreventSystemSleep() {
        resetSleepAssertions() // Désactiver toutes les assertions avant de lancer l'écran de veille
        launchScreensaver()
        disableSystemSleep()
    }

    // Fonction pour verrouiller l'écran
    private func lockScreen() {
        let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
        let sym = dlsym(libHandle, "SACLockScreenImmediate")
        typealias myFunction = @convention(c) () -> Void
        let SACLockScreenImmediate = unsafeBitCast(sym, to: myFunction.self)
        SACLockScreenImmediate()
    }

    // Fonction pour lancer l'écran de veille
    private func launchScreensaver() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["/System/Library/CoreServices/ScreenSaverEngine.app"]
        task.launch()
    }

    // Vérification du premier lancement
    private func checkForFirstLaunch() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "IsFirstLaunch")
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "IsFirstLaunch")
            showOpeningView = true
        }
    }

    // Vérification de mise à jour de l'application et réinitialisation de l'affichage "What's New"
    private func checkForAppUpdate() {
        // Récupérer le numéro de version actuel de l'app
        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        
        // Vérifier si l'application a déjà été lancée auparavant
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
        
        // Récupérer la dernière version connue de l'application stockée dans UserDefaults
        let lastKnownVersion = UserDefaults.standard.string(forKey: "LastKnownAppVersion")

        if !hasLaunchedBefore {
            // Si c'est le premier lancement après installation, ne pas afficher la vue "What's New"
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UserDefaults.standard.set(currentAppVersion, forKey: "LastKnownAppVersion")
            return
        }
        
        // Si l'app a été lancée auparavant, vérifier si la version a changé (indiquant une mise à jour)
        if lastKnownVersion != currentAppVersion {
            // Si la version a changé, afficher la vue "What's New"
            UserDefaults.standard.set(currentAppVersion, forKey: "LastKnownAppVersion")
            showWhatsNewView = true
        }

        if showWhatsNewView {
            DispatchQueue.main.async {
                self.showWhatsNewWindow()
            }
        }
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("App Version: \(appVersion)")
        } else {
            print("App Version not found")
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

    // Gérer la batterie
    func deactivateIfLowBattery() {
        if let batteryInfo = getBatteryInfo() {
            if let currentCapacity = batteryInfo[kIOPSCurrentCapacityKey] as? Int,
               let maxCapacity = batteryInfo[kIOPSMaxCapacityKey] as? Int, maxCapacity > 0 {
                
                let batteryPercentage = (Double(currentCapacity) / Double(maxCapacity)) * 100
                print("Battery level: \(batteryPercentage)%")
                if batteryPercentage <= 10 {
                    print("Battery level is \(batteryPercentage)%, deactivating all features")
                    deactivateAllFeatures()
                    updateMenuIcon()
                } else {
                    print("Battery level is sufficient: \(batteryPercentage)%")
                }
            } else {
                print("Battery capacity information is missing or invalid.")
            }
        } else {
            print("Unable to retrieve battery information.")
        }
    }

    private func getBatteryInfo() -> [String: AnyObject]? {
        let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(blob).takeRetainedValue() as NSArray

        for source in sources {
            let powerSource = source as CFTypeRef
            let description = IOPSGetPowerSourceDescription(blob, powerSource).takeUnretainedValue() as! [String: AnyObject]
            if let powerSourceType = description[kIOPSPowerSourceStateKey] as? String, powerSourceType == kIOPSBatteryPowerValue {
                return description
            }
        }

        print("No battery source found.")
        return nil
    }

    var batteryCheckTimer: Timer?

    func toggleDeactivateIfLowBattery() {
        isCriticalbatteryCharge.toggle()
        if isCriticalbatteryCharge {
            batteryCheckTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                self.deactivateIfLowBattery()
            }
            print("Battery level monitoring activated")
        } else {
            batteryCheckTimer?.invalidate()
            batteryCheckTimer = nil
            enableDisplaySleep()
            enableSystemSleep()
            print("Battery level monitoring deactivated")
        }
    }

    // Mise à jour de l'icône de la barre de menu
    private func updateMenuIcon() {
        if isSystemSleepDisabled || isDisplaySleepDisabled {
            menuIcon = "zzz.custom.slash"
        } else {
            menuIcon = "zzz"
        }
    }

    // Fonctions pour afficher les fenêtres "About" et "What's New"
    func showAboutMe() {
        let aboutView = NSHostingController(rootView: AboutMeView())
        let aboutWindow = NSWindow(contentViewController: aboutView)
        aboutWindow.styleMask = [.titled, .closable]
        aboutWindow.title = "Simple Sleep Control"
        aboutWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showAboutSimpleSleepControl() {
        let aboutAppView = NSHostingController(rootView: AboutSimpleSleepControlView())
        let aboutWindow = NSWindow(contentViewController: aboutAppView)
        aboutWindow.styleMask = [.titled, .closable]
        aboutWindow.title = "Simple Sleep Control"
        aboutWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showWhatsNewWindow() {
        let whatsNewView = NSHostingController(rootView: WhatsNewView())
        let whatsNewWindow = NSWindow(contentViewController: whatsNewView)
        whatsNewWindow.styleMask = [.titled, .closable]
        whatsNewWindow.title = "What's New"
        whatsNewWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        UserDefaults.standard.set(true, forKey: "DontShowWhatsNewViewAgain")
    }
    
    func showOpeningWindow() {
        let openingView = NSHostingController(rootView: OpeningView())
        let openingWindow = NSWindow(contentViewController: openingView)
        openingWindow.styleMask = [.titled, .closable]
        openingWindow.title = "Welcome to Simple Sleep Control"
        openingWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // Fonction pour réinitialiser First Launch UserDefaults
    func resetFirstLaunch() {
        UserDefaults.standard.set(false, forKey: "IsFirstLaunch")
        showOpeningView = true
    }
}
