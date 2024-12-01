//
//  CroppedCachedAsyncImage.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/30/24.
//

import SwiftUI
import CachedAsyncImage

struct CroppedCachedAsyncImage<GenericShape: Shape>: View {

    var url: URL?

    var width: CGFloat
    var height: CGFloat

    var alignment: Alignment

    var clipShape: GenericShape

    var onLoadTask: ((Image) -> Void)?

    var body: some View {
        CachedAsyncImage(url: url, urlCache: .imageCache) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.small)
            case .success(let image):
                image
                    .resizable()
                    .task {
                        onLoadTask?(image)
                    }
            default:
                Image("spwifiy.profile.default")
                    .resizable()
            }
        }
        .scaledToFill()
        .frame(width: width, height: height, alignment: alignment)
        .clipped()
        .clipShape(clipShape)
    }

}
