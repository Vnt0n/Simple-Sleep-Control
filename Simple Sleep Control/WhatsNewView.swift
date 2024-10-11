//
//  WhatsNewView.swift
//  Simple Sleep Control
//
//  Created by Antoine on 10/10/2024.
//

import SwiftUI

struct WhatsNewView: View {
    var body: some View {
        VStack {
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

#Preview {
    WhatsNewView()
}
