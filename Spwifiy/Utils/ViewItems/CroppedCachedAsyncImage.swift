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

    var width: CGFloat?
    var height: CGFloat?

    var maxWidth: CGFloat?
    var maxHeight: CGFloat?

    var alignment: Alignment

    var clipShape: GenericShape

    var onLoadTask: ((Image) -> Void)?

    var body: some View {
        generateCroppedImage()
    }

    private func generateCroppedImage() -> AnyView {
        var image: any View = CachedAsyncImage(url: url, urlCache: .imageCache) { phase in
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

        if let width = width, let height = height {
            image = image.frame(width: width, height: height, alignment: alignment)
        } else if let maxWidth = maxWidth, let maxHeight = maxHeight {
            image = image.frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: alignment)
        }

        return AnyView(
            image
                .clipped()
                .clipShape(clipShape)
        )
    }

}
