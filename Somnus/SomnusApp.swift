//
//  SomnusApp.swift
//  Somnus
//
//  Created by Antoine on 08/10/2024.
//

import SwiftUI
import IOKit.pwr_mgt
import AppKit

@main
struct SomnusApp: App {
    @StateObject private var viewModel = SomnusViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        MenuBarExtra {
            // Contenu du menu déroulant
            
            VStack {
                Button(action: {
                    viewModel.toggleDisplaySleepMode() // Gérer la mise en veille de l'écran
                }) {
                    HStack {
                        if viewModel.isDisplaySleepDisabled {
                            Image(systemName: "checkmark")
                        }
                        Text("Prevent Display sleep")
                    }
                }

                Divider() // Séparation pour les options du menu

                Button(action: {
                    viewModel.toggleSystemSleepMode() // Gérer la mise en veille du système
                }) {
                    HStack {
                        if viewModel.isSystemSleepDisabled {
                            Image(systemName: "checkmark")
                        }
                        Text("Prevent System sleep")
                    }
                }

                Divider() // Séparation pour les options du menu
                
                Button(action: {
                    NSApp.terminate(nil) // Quitte l'application
                }) {
                    HStack {
                        Text("Quit Somnus")
                    }
                }
                
                Divider() // Séparation pour les options du menu

                Button(action: {
                    print("Go to ContentView")
                }) {
                    HStack {
                        Text("About me")
                    }
                }
                
            }
            
        } label: {
            // Label pour la barre de menu (icône dynamique)
            Image(systemName: viewModel.menuIcon)
        }
    }
}

class SomnusViewModel: ObservableObject {
    // Propriétés pour la mise en veille de l'écran
    @Published var menuIcon: String = "bolt" // Icône dans la barre de menu
    private var sleepAssertionID: IOPMAssertionID = 0
    @Published var isDisplaySleepDisabled: Bool = false

    // Propriétés pour la mise en veille du système
    private var systemSleepAssertionID: IOPMAssertionID = 0
    @Published var isSystemSleepDisabled: Bool = false

    // Fonction pour gérer la mise en veille de l'écran
    func toggleDisplaySleepMode() {
        if isDisplaySleepDisabled {
            enableDisplaySleep()
        } else {
            disableDisplaySleep()
            // Désactive la mise en veille du système si l'écran reste éveillé
            if isSystemSleepDisabled {
                enableSystemSleep()
            }
        }
        menuIcon = isDisplaySleepDisabled ? "bolt.fill" : "bolt"
    }

    private func disableDisplaySleep() {
        let result = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                 IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                 "Prevent Display Sleep" as CFString,
                                                 &sleepAssertionID)
        if result == kIOReturnSuccess {
            isDisplaySleepDisabled = true
            // Désactive la mise en veille du système si l'écran reste éveillé
            if isSystemSleepDisabled {
                enableSystemSleep()
            }
        }
    }

    private func enableDisplaySleep() {
        let result = IOPMAssertionRelease(sleepAssertionID)
        if result == kIOReturnSuccess {
            isDisplaySleepDisabled = false
        }
    }

    // Fonction pour gérer la mise en veille du système
    func toggleSystemSleepMode() {
        if isSystemSleepDisabled {
            enableSystemSleep()
        } else {
            disableSystemSleep()
            // Désactive la mise en veille de l'écran si le système reste éveillé
            if isDisplaySleepDisabled {
                enableDisplaySleep()
            }
        }
        menuIcon = isSystemSleepDisabled ? "bolt.fill" : "bolt"
    }

    private func disableSystemSleep() {
        let result = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoIdleSleep as CFString,
                                                 IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                 "Prevent System Sleep" as CFString,
                                                 &systemSleepAssertionID)
        if result == kIOReturnSuccess {
            isSystemSleepDisabled = true
            // Désactive la mise en veille de l'écran si le système reste éveillé
            if isDisplaySleepDisabled {
                enableDisplaySleep()
            }
        }
    }

    private func enableSystemSleep() {
        let result = IOPMAssertionRelease(systemSleepAssertionID)
        if result == kIOReturnSuccess {
            isSystemSleepDisabled = false
        }
    }
}
