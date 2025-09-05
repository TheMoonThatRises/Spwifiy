//
//  IPAddress.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 9/5/25.
//

import Foundation

class IPAddress {

    // wifi = ["en0"]
    // wired = ["en2", "en3", "en4"]
    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
    private static let validNames: [String] = [
        "en0", "en2", "en3", "en4", "pdp_ip0", "pdp_ip1", "pdp_ip2", "pdp_ip3"
    ]

    private static var hiddenIpAddress: String?
    public static var ipAddress: String? {
        if hiddenIpAddress == nil {
            hiddenIpAddress = getIPAddress()
        }

        return hiddenIpAddress
    }

    // https://stackoverflow.com/a/73853838
    private static func getIPAddress() -> String? {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  validNames.contains(name) {

                    // Convert interface address to a human readable string
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

                    getnameinfo(interface.ifa_addr,
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname,
                                socklen_t(hostname.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)

                    address = String(cString: hostname)
                }
            }
        }

        freeifaddrs(ifaddr)

        return address
    }

}
