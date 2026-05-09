# DynamicTypeWebViewDemo

iOS の **Dynamic Type** を WKWebView 上でも正しくスケールさせる方法を示すデモアプリです。

<img width="350" alt="Simulator Screenshot - iPhone 17e - 2026-05-03 at 12 59 37" src="https://github.com/user-attachments/assets/e233e997-03bc-4a0c-9b25-7eeba180ef12" />
<br/><br/>

👇からTestFlight版をインストールできます。<br/>
https://testflight.apple.com/join/HZCGWkfa

<img width="180" height="180" alt="image" src="https://github.com/user-attachments/assets/6435a871-71e8-405f-90d4-337f4ec13ea4" />

## 概要

ネイティブ SwiftUI コンポーネントは Dynamic Type に自動対応しますが、WebView 内の HTML/CSS はデフォルトでは追従しません。  
このアプリでは、2 つのシンプルな実装ポイントを使って WebView 内のテキストを Dynamic Type に連動させる方法を示します。

## 実装のポイント

### ① CSS: `body` に `-apple-system-body` を指定

```css
body {
  font: -apple-system-body; /* iOS WebKit が Dynamic Type サイズを body に反映 */
}
```

これだけで iOS WebKit が Dynamic Type の設定値を `body` のフォントサイズに反映します。

### ② CSS: `font-size` は `em` 単位で指定

```css
.title       { font-size: 1.143em; } /* ✅ body 基準でスケールする */
.description { font-size: 0.857em; } /* ✅ body 基準でスケールする */

.bad-title   { font-size: 16px; }    /* ❌ 固定値のためスケールしない */
```

`px` 固定ではなく `em` を使うことで、`body` のサイズ変化に追従します。

### ③ Swift: Dynamic Type 変更を検知して WebView をリロード

```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(dynamicTypeDidChange),
    name: UIContentSizeCategory.didChangeNotification,
    object: nil
)

@objc private func dynamicTypeDidChange() {
    webView?.reload() // リロード後、CSS が新しいサイズで再評価される
}
```

`UIContentSizeCategory.didChangeNotification` を受信したら WebView をリロードし、CSS を再評価させます。

## 動作確認方法

1. Xcode でプロジェクトを開いてシミュレーターまたは実機で起動
2. **設定 → アクセシビリティ → 画面表示とテキストサイズ → さらに大きな文字** でフォントサイズを変更
3. アプリに戻ると WebView がリロードされ、`em` 指定のテキストのみサイズが変化することを確認できる

## 動作環境

- iOS 16.0+
- Xcode 15+
- Swift 5.9+
