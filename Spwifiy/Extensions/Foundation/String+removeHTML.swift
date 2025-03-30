//
//  String+removeHTML.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/30/25.
//

import HTMLEntities

extension String {
    func removeHTML() -> String {
        self.htmlUnescape()
            .replacingOccurrences(of: #"<a href=(.+?)>(.+?)</a>"#,
                                  with: "$2",
                                  options: .regularExpression,
                                  range: nil)
    }
}
