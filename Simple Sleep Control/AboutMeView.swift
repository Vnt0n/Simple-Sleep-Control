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
            
            Text("You like my work?")
                .font(.system(size: 25))
                .padding()
            
            Spacer()
            
            Text("I'm an independent French developer.")
                .font(.system(size: 15))
            
            Spacer()

            Text("I like to make free apps, with no ads, lightweight,")
                .font(.system(size: 15))
            Text("and really simple to use, straight to the point.")
                .font(.system(size: 15))
            
            Spacer()

            Text("If you value my work, please consider ")
                .font(.system(size: 15))
            Text("to donate a small amount for my job. ❤️")
                .font(.system(size: 15))
            
            Spacer()
            Spacer()

                        Button(action: {
                if let url = URL(string: "https://vnton.xyz/donate") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Text("Donate with PayPal")
                    .font(.system(size: 14))
                    .bold()
                    .frame(width: 150)
                    .frame(height: 5)
                    .padding()
                    .foregroundColor(Color(red: 0.0/255.0, green: 48.0/255.0, blue: 135.0/255.0)) // #003087
                    .background(Color(red: 255.0/255.0, green: 209.0/255.0, blue: 64.0/255.0))  // #FFD140
                    .cornerRadius(70)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            Spacer()
            Spacer()

            Divider()
            
            Spacer()
            Spacer()

            Text("You can also share your love by writing me an email")
                .font(.system(size: 14))

            Text("and see my other apps here:")
                .font(.system(size: 14))

            Spacer()
            
            Link("vnton.xyz", destination: URL(string: "https://vnton.xyz/apps")!)
                .font(.system(size: 15))
                .bold()
                .foregroundColor(.blue)
                .padding(.bottom, 1)
            
            Spacer()
            Spacer()
            Spacer()

//            Button(action: {
//                dismiss()
//            }) {
//                Text("OK")
//                    .font(.system(size: 12))
//                    .padding()
//                    .frame(width: 60)
//                    .frame(height: 30)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(7)
//            }
//            .buttonStyle(PlainButtonStyle())
            
//            Spacer()
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}

#Preview {
    AboutMeView()
}
