//
//  WKWebViewer.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/30/24.
//

import Foundation
import WebKit

@MainActor
class WKWebViewer: NSObject {

    private let webView: WKWebView

    override init() {
        self.webView = WKWebView()

        super.init()

        self.webView.navigationDelegate = self
    }

    private var continuation: CheckedContinuation<String?, Error>?

    func getHTML(from url: URL) async throws -> String? {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            webView.load(URLRequest(url: url))
        }
    }
}

extension WKWebViewer: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.outerHTML") { [weak self] (result, error) in
            if let error = error {
                self?.continuation?.resume(throwing: error)
            }

            self?.continuation?.resume(returning: result as? String)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
    }
}
