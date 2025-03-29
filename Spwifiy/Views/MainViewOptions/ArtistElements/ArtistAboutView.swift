//
//  ArtistAboutView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/29/25.
//

import SwiftUI

struct ArtistAboutView: View {

    var geom: GeometryProxy

    @Binding var biography: String?
    @Binding var followers: Int?
    @Binding var monthlyListeners: Int?
    @Binding var externalLinks: [(String, String)]

    var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                Text(biography ?? "No biography provided.")
                    .font(.title3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: geom.size.width * 2 / 3, alignment: .leading)

                Spacer()

                VStack(alignment: .leading) {
                    Text(followers?.formatted() ?? "-")
                        .font(.satoshiBlack(40))
                        .fontWeight(.black)

                    Spacer()
                        .frame(height: 10)

                    Text("Followers")
                        .font(.title3)
                        .foregroundStyle(.fgSecondary)

                    Spacer()
                        .frame(height: 25)

                    Text(monthlyListeners?.formatted() ?? "-")
                        .font(.satoshiBlack(40))
                        .fontWeight(.black)

                    Spacer()
                        .frame(height: 10)

                    Text("Monthly Listeners")
                        .font(.title3)
                        .foregroundStyle(.fgSecondary)

                    Spacer()
                        .frame(height: 25)

                    ForEach(externalLinks, id: \.1) { item in
                        Text(item.0.capitalizeFirst())
                            .font(.title3)
                            .fontWeight(.black)

                        Spacer()
                            .frame(height: 10)

                        Text("[\(item.1)](\(item.1))")
                            .font(.title3)
                            .foregroundStyle(.fgSecondary)

                        if item != (externalLinks.last ?? ("", "")) {
                            Spacer()
                                .frame(height: 25)
                        }
                    }
                }
                .frame(width: 250)
            }
        }
        .foregroundStyle(.fgPrimary)
    }

}
