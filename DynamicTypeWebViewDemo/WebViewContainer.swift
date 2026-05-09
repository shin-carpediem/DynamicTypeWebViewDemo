import SwiftUI
import WebKit

struct WebViewContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { .init() }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.bounces = true
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        loadPage(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func loadPage(in webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: "demo", withExtension: "html") else { return }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?
        private var changeCount = 0

        override init() {
            super.init()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(dynamicTypeDidChange),
                name: UIContentSizeCategory.didChangeNotification,
                object: nil
            )
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        @objc private func dynamicTypeDidChange() {
            changeCount += 1
            applyFontSize()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            applyFontSize()
        }

        // Swift 側で body サイズを取得し、JS で :root の font-size を上書きする。
        // CSS の em / rem 指定が root のサイズを起点にスケールする。
        private func applyFontSize() {
            let size = UIFont.preferredFont(forTextStyle: .body).pointSize
            let countText = changeCount == 0 ? "0（まだ変更なし）" : String(changeCount)
            let js = """
            document.documentElement.style.fontSize = '\(size)px';
            var rootEl = document.getElementById('root-font-size-value');
            if (rootEl) rootEl.textContent = '\(size)px';
            var countEl = document.getElementById('change-count-value');
            if (countEl) countEl.textContent = '\(countText)';
            """
            webView?.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
