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
        // allowingReadAccessTo でローカルCSSなども読み込み可能にする
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?

        override init() {
            super.init()
            // ダイナミックタイプ変更を検知して WebView をリロードする
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
            // リロード後、CSSの font: -apple-system-body が新しいサイズで再評価される
            webView?.reload()
        }
    }
}
