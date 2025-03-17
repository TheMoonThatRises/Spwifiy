//
//  RandomUserAgent.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/16/25.
//

class RandomUserAgent {

    private static func random(_ lower: Int, _ upper: Int) -> Int {
        Int.random(in: lower...upper)
    }

    public static func generate() -> String {
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_\(random(11, 15))_\(random(4, 9))) " +
        "AppleWebKit/\(random(530, 537)).\(random(30, 37)) (KHTML, like Gecko) " +
        "Chrome/\(random(80, 105)).0.\(random(3000, 4500)).\(random(60, 125)) " +
        "Safari/\(random(530, 537)).\(random(30, 36))"
    }

}
