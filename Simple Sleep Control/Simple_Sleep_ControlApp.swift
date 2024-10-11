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
//                Button(action: {
//                    viewModel.resetFirstLaunch()
//                }) {
//                    Text("Reset First Launch")
//                }
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
    @Published var showOpeningView: Bool = false
    @Published var showWhatsNewView: Bool = false
    @Published var isCriticalbatteryCharge: Bool = false


    private let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"

    init() {
        isLoginItemEnabled = SMAppService.mainApp.status == .enabled
        
        checkForFirstLaunch()
        checkForAppUpdate()
        
        // Vérifier si l'OpeningView doit être affichée
        DispatchQueue.main.async {
            if self.showOpeningView {
                self.showOpeningWindow()
            }
        }
    }
    
    // Vérification du premier lancement
    private func checkForFirstLaunch() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "IsFirstLaunch")
        
        if isFirstLaunch {
            // Marquer que l'application a été lancée pour la première fois
            UserDefaults.standard.set(true, forKey: "IsFirstLaunch")
            // Afficher OpeningView lors du premier lancement
            showOpeningView = true
        }
    }
    
    // Vérification de la mise à jour de l'application et réinitialisation de l'affichage du "What's New"
    private func checkForAppUpdate() {
        let lastKnownVersion = UserDefaults.standard.string(forKey: "LastKnownAppVersion")

        if lastKnownVersion != currentAppVersion {
            // Si la version a changé, réinitialiser l'état de la vue "What's New"
            UserDefaults.standard.set(false, forKey: "DontShowWhatsNewViewAgain")
            UserDefaults.standard.set(currentAppVersion, forKey: "LastKnownAppVersion")
            
            // Ne pas afficher "What's New" si c'est le premier lancement
            if !showOpeningView {
                showWhatsNewView = true
            }
        } else {
            // Si la vue ne doit pas être affichée, vérifier l'état du UserDefault
            showWhatsNewView = !UserDefaults.standard.bool(forKey: "DontShowWhatsNewViewAgain") && !showOpeningView
        }

        // Afficher la fenêtre "What's New" si nécessaire
        if showWhatsNewView {
            DispatchQueue.main.async {
                self.showWhatsNewWindow()
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

    // Fonction pour afficher la fenêtre d'ouverture (OpeningView)
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

                enableSystemSleep()
            }
            isSystemSleepDisabled = false
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
    
    func lockScreenAndPreventDisplaySleep() {
        // Verrouiller l'écran
        let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
        let sym = dlsym(libHandle, "SACLockScreenImmediate")
        typealias myFunction = @convention(c) () -> Void

        let SACLockScreenImmediate = unsafeBitCast(sym, to: myFunction.self)
        SACLockScreenImmediate()

        // Désactiver la mise en veille de l'écran
        disableDisplaySleep()
    }
    
    func lockScreenAndPreventSystemSleep() {
        // Verrouiller l'écran
        let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
        let sym = dlsym(libHandle, "SACLockScreenImmediate")
        typealias myFunction = @convention(c) () -> Void

        let SACLockScreenImmediate = unsafeBitCast(sym, to: myFunction.self)
        SACLockScreenImmediate()

        disableSystemSleep()
    }
    
    func launchScreensaverAndPreventDisplaySleep() {
        // Lancer l'écran de veille en utilisant la commande "open"
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["/System/Library/CoreServices/ScreenSaverEngine.app"]
        task.launch()
        
        // Empêcher la mise en veille de l'écran
        disableDisplaySleep()
    }
    
    func launchScreensaverAndPreventSystemSleep() {
        // Lancer l'écran de veille en utilisant la commande "open"
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["/System/Library/CoreServices/ScreenSaverEngine.app"]
        task.launch()
        
        disableSystemSleep()
    }
    
    func deactivateIfLowBattery() {
        // Récupérer les informations sur la batterie
        if let batteryInfo = getBatteryInfo() {
            // Vérifier que les capacités actuelles et maximales sont présentes
            if let currentCapacity = batteryInfo["Current Capacity"] as? Int,
               let maxCapacity = batteryInfo["Max Capacity"] as? Int {
               
                let batteryPercentage = (Double(currentCapacity) / Double(maxCapacity)) * 100
                print("Battery level: \(batteryPercentage)%")
                
                // Si le pourcentage de batterie est inférieur ou égal à 10 %, désactiver les fonctionnalités
                if batteryPercentage <= 10 {
                    print("Battery level is \(batteryPercentage)%, deactivating all features")
                    deactivateAllFeatures()
                } else {
                    print("Battery level is sufficient: \(batteryPercentage)%")
                }
            } else {
                // Si les capacités ne sont pas présentes, afficher un message d'erreur plus spécifique
                print("Missing battery capacity information")
            }
        } else {
            // Si aucune information sur la batterie n'est disponible
            print("Unable to retrieve battery information")
        }
    }
    private func deactivateAllFeatures() {
        enableDisplaySleep()  // Remettre la mise en veille de l'écran
        enableSystemSleep()   // Remettre la mise en veille du système
    }
    
    private func getBatteryInfo() -> [String: AnyObject]? {
        let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(blob).takeRetainedValue() as NSArray
        
        if sources.count == 0 {
            print("No power sources found.")
            return nil
        }
        
        if let powerSource = sources.firstObject as? CFTypeRef {
            if let description = IOPSGetPowerSourceDescription(blob, powerSource).takeUnretainedValue() as? [String: AnyObject] {
                print("Battery info: \(description)")
                return description
            } else {
                print("Unable to retrieve power source description.")
                return nil
            }
        } else {
            print("No valid power source found.")
            return nil
        }
    }
    
    func toggleDeactivateIfLowBattery() {
        // Inverser l'état de la variable
        isCriticalbatteryCharge.toggle()

        if isCriticalbatteryCharge {
            // Si activé, vérifier immédiatement la batterie et désactiver si nécessaire
            deactivateIfLowBattery()
            print("Battery level monitoring activated")
        } else {
            // Si désactivé, réactiver toutes les fonctionnalités
            enableDisplaySleep()
            enableSystemSleep()
            print("Battery level monitoring deactivated")
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
    
    // Fonction pour afficher la fenêtre "What's New"
    func showWhatsNewWindow() {
        let whatsNewView = NSHostingController(rootView: WhatsNewView())
        let whatsNewWindow = NSWindow(contentViewController: whatsNewView)
        whatsNewWindow.styleMask = [.titled, .closable]
        whatsNewWindow.title = "What's New"
        whatsNewWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Marquer la vue comme vue
        UserDefaults.standard.set(true, forKey: "DontShowWhatsNewViewAgain")
    }
    
// //////////////////////////// Fonction pour réinitialiser First Launch UserDefaults ////////////////////////////////////////////////
    func resetFirstLaunch() {
        UserDefaults.standard.set(false, forKey: "IsFirstLaunch")
        showOpeningView = true
    }
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}
