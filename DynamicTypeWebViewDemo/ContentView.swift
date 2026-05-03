import SwiftUI

struct ContentView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            statusBar
            Divider()
            WebViewContainer()
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var statusBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "textformat.size")
                .font(.title3)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 1) {
                Text("Dynamic Type")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(dynamicTypeSize.displayName)
                    .font(.subheadline.bold())
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text("ネイティブUI")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("自動スケール中")
                    .font(.caption2.bold())
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
    }
}

extension DynamicTypeSize {
    var displayName: String {
        switch self {
        case .xSmall:       return "XSmall"
        case .small:        return "Small"
        case .medium:       return "Medium"
        case .large:        return "Large（標準）"
        case .xLarge:       return "XLarge"
        case .xxLarge:      return "XXLarge"
        case .xxxLarge:     return "XXXLarge"
        case .accessibility1: return "Accessibility L"
        case .accessibility2: return "Accessibility XL"
        case .accessibility3: return "Accessibility XXL"
        case .accessibility4: return "Accessibility XXXL"
        case .accessibility5: return "Accessibility XXXXL"
        @unknown default:   return "Unknown"
        }
    }
}
