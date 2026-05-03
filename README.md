# DynamicTypeWebViewDemo

iOS の **Dynamic Type** を WKWebView 上でも正しくスケールさせる方法を示すデモアプリです。

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

## デモ画面の構成

| セクション | 内容 |
|---|---|
| ステータスバー | 現在の Dynamic Type サイズ名を表示（SwiftUI） |
| ✅ 対応済み | `em` 単位で指定したテキスト。Dynamic Type 変更に連動してスケール |
| ❌ 未対応 | `px` 固定のテキスト。Dynamic Type を変更してもサイズが変わらない |
| 実装コード | CSS のポイントをシンタックスハイライト付きで表示 |

## 動作確認方法

1. Xcode でプロジェクトを開いてシミュレーターまたは実機で起動
2. **設定 → アクセシビリティ → 画面表示とテキストサイズ → さらに大きな文字** でフォントサイズを変更
3. アプリに戻ると WebView がリロードされ、`em` 指定のテキストのみサイズが変化することを確認できる

## 動作環境

- iOS 16.0+
- Xcode 15+
- Swift 5.9+

## ファイル構成

```
DynamicTypeWebViewDemo/
├── DynamicTypeWebViewDemoApp.swift   # エントリーポイント
├── ContentView.swift                 # ステータスバー + WebView のレイアウト
├── WebViewContainer.swift            # WKWebView ラッパー / Dynamic Type 変更検知
└── demo.html                         # em vs px を比較するデモページ
```
