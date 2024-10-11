//
//  AboutSimpleSleepControlView.swift
//  Simple Sleep Control
//
//  Created by Antoine on 09/10/2024.
//

import SwiftUI

struct AboutSimpleSleepControlView: View {
    @Environment(\.dismiss) var dismiss  // Ajoute l'action dismiss

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

            Text("Free, lightweight, straight to the point.")
                .font(.system(size: 14))
                .padding(.bottom, 10)
            
            Spacer()

            Text("An app by")
                .font(.system(size: 14))

            Link("vnton.xyz", destination: URL(string: "https://vnton.xyz/apps")!)
                .font(.system(size: 15))
                .bold()
                .foregroundColor(.blue)
            
            Spacer()
            
            Button(action: {
                dismiss()
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
        .frame(minWidth: 600, minHeight: 300)
    }
}

#Preview {
    AboutSimpleSleepControlView()
}
