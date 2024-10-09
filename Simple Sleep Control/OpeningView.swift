//
//  OpeningView2.swift
//  Simple Sleep Control
//
//  Created by Antoine on 09/10/2024.
//

import SwiftUI

struct OpeningView: View {
    @Environment(\.dismiss) var dismiss  // Ajoute l'action dismiss
    @State private var dontShowAgain = false

    var body: some View {
        VStack {
            Spacer()

            Text("Simple Sleep Control")
                .font(.title)
                .padding()

            Spacer()

            Toggle("Don't show again", isOn: $dontShowAgain)
                .padding()

            Button(action: {
                UserDefaults.standard.set(dontShowAgain, forKey: "DontShowOpeningViewAgain")
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

#Preview {
    OpeningView()
}
