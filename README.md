# DynamicTypeWebViewDemo

iOS の **Dynamic Type** を WKWebView 上でも正しくスケールさせる方法を示すデモアプリです。

<img width="350" alt="Simulator Screenshot - iPhone 17e - 2026-05-09 at 14 35 23" src="https://github.com/user-attachments/assets/62114729-7208-4a38-8f5d-b4616ed9c729" />
<br/><br/>

👇からTestFlight版をインストールできます。<br/>
https://testflight.apple.com/join/HZCGWkfa

<img width="180" height="180" alt="image" src="https://github.com/user-attachments/assets/6435a871-71e8-405f-90d4-337f4ec13ea4" />

## 概要

ネイティブ SwiftUI コンポーネントは Dynamic Type に自動対応しますが、WebView 内の HTML/CSS はデフォルトでは追従しません。  
このアプリでは、2 つのシンプルな実装ポイントを使って WebView 内のテキストを Dynamic Type に連動させる方法を示します。

## 実装のポイント

### ① Swift: Dynamic Type 変更を検知してフォントサイズを JS で注入

```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(dynamicTypeDidChange),
    name: UIContentSizeCategory.didChangeNotification,
    object: nil
)

@objc private func dynamicTypeDidChange() {
    applyFontSize()
}

func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    applyFontSize() // ページロード完了時にも適用
}

private func applyFontSize() {
    let size = UIFont.preferredFont(forTextStyle: .body).pointSize
    webView?.evaluateJavaScript(
        "document.documentElement.style.fontSize = '\(size)px'",
        completionHandler: nil
    )
}
```

`UIContentSizeCategory.didChangeNotification` を受信したら、Swift 側で body サイズを取得し `evaluateJavaScript` で `:root` の `font-size` を直接書き換えます。  
リロードが不要なため即時反映され、注入する値を変えれば独自のスケール（上限キャップなど）にも対応できます。

### ② CSS: `font-size` は `rem` 単位で指定

```css
:root {
  font-size: 17px; /* フォールバック。Swift が evaluateJavaScript で上書きする */
}

.title       { font-size: 1.143rem; } /* ✅ :root 基準でスケールする */
.description { font-size: 0.857rem; } /* ✅ :root 基準でスケールする */

.bad-title   { font-size: 16px; }     /* ❌ 固定値のためスケールしない */
```

Swift が `:root` の `font-size` を書き換えるため、`rem` 指定の要素がすべて連動してスケールします。

## 動作確認方法

1. Xcode でプロジェクトを開いてシミュレーターまたは実機で起動
2. **設定 → アクセシビリティ → 画面表示とテキストサイズ → さらに大きな文字** でフォントサイズを変更
3. アプリに戻ると（リロードなしで）`rem` 指定のテキストのみサイズが変化することを確認できる

## 参考: より楽な代替案

`font: -apple-system-body` を CSS に指定し、通知受信時に `webView.reload()` を呼ぶだけでも同様の効果が得られます。  
実装はシンプルですが、**リロードが発生する**点と **Apple のスケールに固定される**点が `evaluateJavaScript` 方式との違いです。

```css
/* CSS: -apple-system-body を指定するだけでよい */
:root, body { font: -apple-system-body; }
```

```swift
// Swift: リロードで CSS を再評価させる
@objc private func dynamicTypeDidChange() {
    webView?.reload()
}
```

## 動作環境

- iOS 16.0+
- Xcode 15+
- Swift 5.9+
