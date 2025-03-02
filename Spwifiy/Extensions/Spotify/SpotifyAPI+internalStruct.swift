//
//  SpotifyAPI+internalStruct.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/14/24.
//

import Foundation
import Combine
import SpotifyWebAPI
import SwiftyJSON

extension SpotifyAPI {

    public struct MadeForDailyXHub {
        init?(_ data: Data) {
            if let json = try? JSON(data: data) {
                print(json)
            } else {
                return nil
            }
        }
    }

}
