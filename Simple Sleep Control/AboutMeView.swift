//
//  AboutMeView.swift
//  Simple Sleep Control
//
//  Created by Antoine on 09/10/2024.
//

import SwiftUI

struct AboutMeView: View {
    @Environment(\.dismiss) var dismiss  // Ajoute l'action dismiss

    var body: some View {
        VStack {
            
            Spacer()
            
            Text("About me")
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

#Preview {
    AboutMeView()
}
