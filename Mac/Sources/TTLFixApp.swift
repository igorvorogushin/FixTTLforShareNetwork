import AppKit
import SwiftUI

private enum TTLTheme {
    static let accent = Color(red: 0.27, green: 0.48, blue: 0.96)
    static let window = Color(red: 0.965, green: 0.969, blue: 0.98)
    static let surface = Color.white
    static let surfaceSecondary = Color(red: 0.94, green: 0.949, blue: 0.969)
    static let border = Color.black.opacity(0.10)
    static let green = Color(red: 0.20, green: 0.70, blue: 0.39)
    static let red = Color(red: 0.92, green: 0.31, blue: 0.31)
}

@main
struct TTLFixApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 560, height: 260)
                .preferredColorScheme(.light)
        }
        .defaultSize(width: 560, height: 260)
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @StateObject private var model = TTLViewModel()
    @AppStorage("language") private var language = "ru"
    @State private var showExplanation = false

    private func t(_ key: String) -> String { L10n.t(key, language) }

    private var hasError: Bool {
        model.statusKey == "cancelled" || model.statusKey == "failed"
    }

    private var isEnabled: Bool { model.isApplied }

    private var buttonTitle: String {
        guard model.currentTTL != nil else { return t("ttl_unknown_button") }
        return isEnabled ? t("ttl_active_button") : t("ttl_inactive_button")
    }

    private var statusTitle: String {
        isEnabled ? t("active_status") : t("inactive_status")
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(t("title"))
                        .font(.system(size: 28, weight: .semibold))
                    Text(t("subtitle"))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Picker(t("language"), selection: $language) {
                    Text(t("russian")).tag("ru")
                    Text(t("english")).tag("en")
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 104)
            }

            VStack(spacing: 10) {
                Button(action: model.toggle) {
                    HStack(spacing: 10) {
                        if model.isWorking {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        }
                        Text(buttonTitle)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(isEnabled ? TTLTheme.green : TTLTheme.red, in: RoundedRectangle(cornerRadius: 8))
                .disabled(model.isWorking)

                if hasError {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(t("error_title")).font(.callout.weight(.semibold))
                        Text(t(model.statusKey)).font(.callout)
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2)
                } else {
                    HStack(spacing: 7) {
                        Circle().fill(isEnabled ? TTLTheme.green : TTLTheme.red).frame(width: 8, height: 8)
                        Text(model.isWorking ? t(model.statusKey) : statusTitle)
                            .foregroundStyle(.secondary)
                    }
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2)
                }
            }

            HStack {
                Button(t("route")) { showExplanation = true }
                    .buttonStyle(.plain)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(TTLTheme.accent)
                Spacer()
                Text(t("footer"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(20)
        .background(TTLTheme.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(TTLTheme.border))
        .padding(24)
        .background(TTLTheme.window)
        .sheet(isPresented: $showExplanation) {
            TTLExplanationSheet(language: language)
        }
    }
}

private struct TTLExplanationSheet: View {
    let language: String
    @Environment(\.dismiss) private var dismiss

    private func t(_ key: String) -> String { L10n.t(key, language) }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(TTLTheme.accent)
                    .frame(width: 46, height: 46)
                    .background(TTLTheme.accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text(t("route")).font(.title2.bold())
                    Text(t("diagram_intro")).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .background(TTLTheme.surfaceSecondary, in: Circle())
                .help(t("close"))
            }
            .padding(20)
            .background(TTLTheme.surface)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ScenarioCard(
                        title: t("scenario_off_title"),
                        explanation: t("scenario_off_text"),
                        macTTL: 64,
                        carrierTTL: 63,
                        color: TTLTheme.red,
                        language: language
                    )

                    ScenarioCard(
                        title: t("scenario_on_title"),
                        explanation: t("scenario_on_text"),
                        macTTL: 65,
                        carrierTTL: 64,
                        color: TTLTheme.green,
                        language: language
                    )
                }
                .padding(20)
            }
        }
        .frame(width: 600, height: 500)
        .background(TTLTheme.window)
    }
}

private struct ScenarioCard: View {
    let title: String
    let explanation: String
    let macTTL: Int
    let carrierTTL: Int
    let color: Color
    let language: String

    private func t(_ key: String) -> String { L10n.t(key, language) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Circle().fill(color).frame(width: 9, height: 9)
                Text(title).font(.headline)
            }
            HStack(spacing: 0) {
                FlowStep(icon: "laptopcomputer", title: t("device"), value: macTTL)
                FlowArrow(label: t("phone_decrements"))
                FlowStep(icon: "iphone", title: t("hotspot"), value: carrierTTL)
                FlowArrow(label: nil)
                FlowStep(icon: "network", title: t("carrier"), value: carrierTTL)
            }
            Text(explanation)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct FlowStep: View {
    let icon: String
    let title: String
    let value: Int

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.title3)
            Text(title).font(.caption)
            Text("TTL \(value)").font(.caption.monospaced()).foregroundStyle(.secondary)
        }
        .frame(width: 82)
    }
}

private struct FlowArrow: View {
    let label: String?

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "arrow.right").foregroundStyle(.secondary)
            if let label {
                Text(label).font(.caption2).foregroundStyle(.secondary).fixedSize()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Russian") {
    ContentView()
}
