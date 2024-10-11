//
//  WhatsNewView.swift
//  Simple Sleep Control
//
//  Created by Antoine on 10/10/2024.
//

import SwiftUI

struct WhatsNewView: View {
    
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var body: some View {
        VStack {
            Spacer()

            Text("Simple Sleep Control")
                .font(.system(size: 25))
                .padding(.bottom, 10)
            
            Text("V \(appVersion)")
                .font(.system(size: 10))
                .padding(.bottom, 10)
            
            Spacer()
            
            Text("What's New in Simple Sleep Control")
                .font(.title)
                .padding()

            Text("Here are the latest updates and features...")
                .font(.body)
                .padding()

            Spacer()

            Button(action: {
                // Fermer la fenêtre après que l'utilisateur clique sur OK
                NSApp.keyWindow?.close()
            }) {
                Text("OK")
                    .font(.system(size: 13))
                    .padding()
                    .frame(width: 60)
                    .frame(height: 30)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(7)
                }
                .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .frame(minWidth: 500, minHeight: 300)
    }
}

#Preview {
    WhatsNewView()
}
