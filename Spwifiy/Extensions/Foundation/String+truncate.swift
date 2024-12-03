//
//  String+truncate.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/2/24.
//

import Foundation

extension String {

    func truncate(_ maxLength: Int) -> String {
        String(self.prefix(maxLength))
    }

}
