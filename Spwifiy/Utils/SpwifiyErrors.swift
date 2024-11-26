//
//  SpwifiyErrors.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import Foundation

enum SpwifiyErrors: LocalizedError {
    case authAccessDenied
    case spotifyNoViewModel
    case unknownError(String)
}

extension SpwifiyErrors {
    public var errorDescription: String {
        switch self {
        case .authAccessDenied:
            return "Authorization access denined"
        case .spotifyNoViewModel:
            return "No view model for Spotify API"
        case .unknownError(let error):
            return error
        }
    }
}
